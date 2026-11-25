import 'package:flutter_test/flutter_test.dart';
import 'package:trip_planner/features/countries/country.dart';

Map<String, dynamic> franceJson() => {
  'cca3': 'FRA',
  'name': {'common': 'France', 'official': 'French Republic'},
  'capital': ['Paris'],
  'region': 'Europe',
  'population': 67000000,
  'area': 551695,
  'flags': {'png': 'https://flagcdn.com/w320/fr.png'},
  'maps': {'googleMaps': 'https://maps.example/fr'},
  'currencies': {
    'EUR': {'name': 'Euro', 'symbol': '€'},
  },
  'languages': {'fra': 'French'},
};

void main() {
  test('fromJson reads the nested name, currencies and an int area', () {
    final c = Country.fromJson(franceJson());
    expect(c.code, 'FRA');
    expect(c.name.official, 'French Republic');
    expect(c.capital, 'Paris');
    expect(c.area, 551695.0);
    expect(c.currencies.single.symbol, '€');
    expect(c.languages, {'fra': 'French'});
    expect(c.subregion, isNull);
  });

  test('a wrong type fails with the field name', () {
    final json = franceJson()..['population'] = 'many';
    expect(
      () => Country.fromJson(json),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('population'),
        ),
      ),
    );
  });

  test('toJson round-trips through fromJson', () {
    final c = Country.fromJson(franceJson());
    expect(Country.fromJson(c.toJson()).toJson(), c.toJson());
  });

  test('density is population per km²', () {
    final c = Country.fromJson(franceJson());
    expect(c.density, closeTo(121.4, 0.1));
  });
}
