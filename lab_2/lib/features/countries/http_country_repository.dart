import 'dart:developer';
import 'dart:io';

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import '../../core/api/json_read.dart';
import 'countries_cache.dart';
import 'country.dart';
import 'country_repository.dart';

/// REST Countries v5 (`api.restcountries.com/countries/v5`). Search and the
/// region filter go through the API's own endpoints, never
/// fetch-all-then-filter. Every answer is `{"data": {"objects": [...]}}`.
class HttpCountryRepository implements CountryRepository {
  HttpCountryRepository(this._api, this._cache);

  final ApiClient _api;
  final CountriesCache _cache;

  static const _base = '/countries/v5';

  // Only what the app shows; the free plan allows up to 100 per page.
  static const _query = {
    'limit': '100',
    'response_fields':
        'names.common,names.official,codes.alpha_3,capitals,region,'
        'subregion,population,area,flag.url_png,links.google_maps,'
        'currencies,languages,timezones,borders',
  };

  @override
  Future<CountryList> search({String query = '', String? region}) async {
    try {
      final fresh = await _fetch(query.trim(), region);
      try {
        await _cache.save(fresh);
      } on FileSystemException catch (e) {
        log('cache save failed: $e', name: 'cache');
      }
      return (items: fresh, fromCache: false);
    } on NoConnectionException {
      final saved = await _cache.load();
      if (saved == null) rethrow;
      return (items: saved, fromCache: true);
    }
  }

  Future<List<Country>> _fetch(String query, String? region) async {
    // Uri.https percent-encodes the path segments itself
    final Object? body;
    try {
      body = query.isNotEmpty
          ? await _api.get('$_base/name', query: {..._query, 'q': query})
          : await _api.get(
              region != null ? '$_base/region/$region' : _base,
              query: _query,
            );
    } on NotFoundException {
      // nothing matched the search: the empty state, not an error
      if (query.isNotEmpty) return const [];
      rethrow;
    }
    return _parse('countries', () => _objects(body));
  }

  @override
  Future<Country> getByCode(String code) async {
    final body = await _api.get('$_base/codes.alpha_3/$code', query: _query);
    final list = _parse('countries/$code', () => _objects(body));
    if (list.isEmpty) throw const NotFoundException();
    return list.first;
  }

  List<Country> _objects(Object? body) {
    final data = (body as Map<String, dynamic>).read<Map<String, dynamic>>(
      'data',
    );
    return [
      for (final j in data.read<List<dynamic>>('objects'))
        Country.fromJson(j as Map<String, dynamic>),
    ];
  }

  T _parse<T>(String resource, T Function() parse) {
    try {
      return parse();
    } on FormatException catch (e) {
      throw BadResponseException('$resource: ${e.message}');
    } on TypeError catch (e) {
      throw BadResponseException('$resource: $e');
    }
  }
}
