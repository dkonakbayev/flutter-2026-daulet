import 'dart:developer';
import 'dart:io';

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'countries_cache.dart';
import 'country.dart';
import 'country_repository.dart';

/// REST Countries v3.1. Search and region filter go through the API's own
/// endpoints (`/name/{q}`, `/region/{r}`), never fetch-all-then-filter.
class HttpCountryRepository implements CountryRepository {
  HttpCountryRepository(this._api, this._cache);

  final ApiClient _api;
  final CountriesCache _cache;

  // /all refuses requests without `fields` (max 10).
  static const _fields = {
    'fields': 'name,cca3,capital,region,population,area,flags,maps,currencies,languages',
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
    final path = query.isNotEmpty
        ? '/v3.1/name/$query'
        : region != null
        ? '/v3.1/region/$region'
        : '/v3.1/all';
    final Object? body;
    try {
      body = await _api.get(path, query: _fields);
    } on NotFoundException {
      // REST Countries answers 404 when a name search matches nothing.
      if (query.isNotEmpty) return const [];
      rethrow;
    }
    return _parse('countries', () {
      final list = body as List<dynamic>;
      return [
        for (final j in list) Country.fromJson(j as Map<String, dynamic>),
      ];
    });
  }

  @override
  Future<Country> getByCode(String code) async {
    final body = await _api.get('/v3.1/alpha/$code');
    return _parse('countries/$code', () {
      // v3.1 answers /alpha with a one-element list
      final json = body is List<dynamic> ? body.first : body;
      return Country.fromJson(json as Map<String, dynamic>);
    });
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
