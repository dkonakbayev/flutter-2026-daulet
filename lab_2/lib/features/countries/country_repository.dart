import 'country.dart';

/// A page of the catalogue; [fromCache] is true when it is the saved copy.
typedef CountryList = ({List<Country> items, bool fromCache});

abstract interface class CountryRepository {
  /// [query] searches by name through the API; otherwise [region] filters.
  Future<CountryList> search({String query = '', String? region});

  Future<Country> getByCode(String code);
}
