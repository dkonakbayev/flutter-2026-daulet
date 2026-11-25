import 'package:flutter_test/flutter_test.dart';
import 'package:trip_planner/core/api/api_exception.dart';
import 'package:trip_planner/features/countries/countries_model.dart';
import 'package:trip_planner/features/countries/fake_country_repository.dart';

void main() {
  test('load fills items and clears loading', () async {
    final m = CountriesModel(FakeCountryRepository());
    await m.load();
    expect(m.items, hasLength(FakeCountryRepository.countries.length));
    expect(m.loading, isFalse);
    expect(m.error, isNull);
  });

  test('NoConnection → error, no items', () async {
    final repo = FakeCountryRepository()
      ..failWith = const NoConnectionException();
    final m = CountriesModel(repo);
    await m.load();
    expect(m.error, isA<NoConnectionException>());
    expect(m.items, isEmpty);
  });

  test('a cached answer sets fromCache for the banner', () async {
    final m = CountriesModel(FakeCountryRepository()..fromCache = true);
    await m.load();
    expect(m.fromCache, isTrue);
  });

  test('search and region filter go to the repository', () async {
    final m = CountriesModel(FakeCountryRepository());
    await m.search('jap');
    expect(m.items.single.code, 'JPN');
    await m.search('');
    await m.filterRegion('Asia');
    expect(m.items.map((c) => c.code), ['JPN', 'KAZ']);
  });
}
