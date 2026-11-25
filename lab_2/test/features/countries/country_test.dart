import 'package:flutter_test/flutter_test.dart';
import 'package:trip_planner/features/countries/country.dart';

/// A REST Countries v5 object, trimmed to the fields the app asks for.
Map<String, dynamic> franceJson() => {
  'codes': {'alpha_3': 'FRA'},
  'names': {'common': 'France', 'official': 'French Republic'},
  'capitals': [
    {
      'name': 'Paris',
      'coordinates': {'lat': 48.87, 'lng': 2.33},
    },
  ],
  'region': 'Europe',
  'population': 67000000,
  'area': {'kilometers': 551695},
  'flag': {'url_png': 'https://flags.restcountries.com/v5/w640/fr.png'},
  'links': {'google_maps': 'https://maps.example/fr'},
  'currencies': [
    {'code': 'EUR', 'name': 'Euro', 'symbol': '€'},
  ],
  'languages': [
    {'iso639_3': 'fra', 'name': 'French', 'native_name': 'français'},
  ],
};

/// The v5 envelope around a list of objects.
Map<String, dynamic> v5(List<Object> objects) => {
  'data': {
    'objects': objects,
    'meta': {'total': objects.length},
  },
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
