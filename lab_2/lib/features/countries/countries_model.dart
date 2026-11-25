import 'package:flutter/foundation.dart';

import '../../core/api/api_exception.dart';
import 'country.dart';
import 'country_repository.dart';

/// State of the catalogue list. No BuildContext, no Navigator, no SnackBar.
class CountriesModel extends ChangeNotifier {
  CountriesModel(this._repo, {this.region});

  final CountryRepository _repo;

  List<Country> items = const [];
  bool loading = false;
  bool fromCache = false;
  ApiException? error;
  String query = '';
  String? region;

  int _request = 0;

  Future<void> load() async {
    final id = ++_request;
    loading = true;
    error = null;
    notifyListeners();
    try {
      final r = await _repo.search(query: query, region: region);
      // A slower, older search must not overwrite a newer one.
      if (id != _request) return;
      items = r.items;
      fromCache = r.fromCache;
    } on ApiException catch (e) {
      if (id != _request) return;
      error = e;
      items = const [];
    } finally {
      if (id == _request) {
        loading = false;
        notifyListeners();
      }
    }
  }

  Future<void> search(String text) {
    query = text.trim();
    return load();
  }

  /// Full data of one country for the detail screen.
  Future<Country> details(String code) => _repo.getByCode(code);

  Future<void> filterRegion(String? value) {
    region = value;
    return load();
  }
}
