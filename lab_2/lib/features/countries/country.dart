import '../../core/api/json_read.dart';
import 'country_name.dart';
import 'currency.dart';

/// One country of the catalogue (REST Countries v3.1).
class Country {
  const Country({
    required this.code,
    required this.name,
    required this.region,
    required this.population,
    required this.area,
    this.capital,
    this.subregion,
    this.flagUrl,
    this.mapsUrl,
    this.currencies = const [],
    this.languages = const {},
    this.timezones = const [],
    this.borders = const [],
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    final capitals = json.read<List<dynamic>?>('capital') ?? const [];
    final currencies = json.read<Map<String, dynamic>?>('currencies') ?? {};
    final languages = json.read<Map<String, dynamic>?>('languages') ?? {};
    return Country(
      code: json.read<String>('cca3'),
      name: CountryName.fromJson(json.read<Map<String, dynamic>>('name')),
      region: json.read<String>('region'),
      population: json.read<num>('population').toInt(),
      area: json.read<num>('area').toDouble(),
      capital: capitals.isEmpty ? null : _string(capitals.first, 'capital'),
      subregion: json.read<String?>('subregion'),
      flagUrl: json.read<Map<String, dynamic>?>('flags')?.read<String?>('png'),
      mapsUrl: json
          .read<Map<String, dynamic>?>('maps')
          ?.read<String?>('googleMaps'),
      currencies: [
        for (final e in currencies.entries)
          Currency.fromJson(e.key, _map(e.value, 'currencies')),
      ],
      languages: {
        for (final e in languages.entries) e.key: _string(e.value, 'languages'),
      },
      timezones: _strings(json.read<List<dynamic>?>('timezones'), 'timezones'),
      borders: _strings(json.read<List<dynamic>?>('borders'), 'borders'),
    );
  }

  final String code;
  final CountryName name;
  final String region;
  final int population;
  final double area;
  final String? capital;
  final String? subregion;
  final String? flagUrl;
  final String? mapsUrl;
  final List<Currency> currencies;
  final Map<String, String> languages;
  final List<String> timezones;
  final List<String> borders;

  /// People per km² — derived here, never in `build`.
  double get density => area == 0 ? 0 : population / area;

  Country copyWith({
    CountryName? name,
    String? capital,
    String? region,
    int? population,
  }) => Country(
    code: code,
    name: name ?? this.name,
    region: region ?? this.region,
    population: population ?? this.population,
    area: area,
    capital: capital ?? this.capital,
    subregion: subregion,
    flagUrl: flagUrl,
    mapsUrl: mapsUrl,
    currencies: currencies,
    languages: languages,
    timezones: timezones,
    borders: borders,
  );

  Map<String, dynamic> toJson() => {
    'cca3': code,
    'name': name.toJson(),
    'region': region,
    'population': population,
    'area': area,
    'capital': [?capital],
    'subregion': ?subregion,
    'flags': {'png': ?flagUrl},
    'maps': {'googleMaps': ?mapsUrl},
    'currencies': {for (final c in currencies) c.code: c.toJson()},
    'languages': languages,
    'timezones': timezones,
    'borders': borders,
  };

  static String _string(Object? value, String field) {
    if (value is String) return value;
    throw FormatException('field "$field": expected String, got $value');
  }

  static Map<String, dynamic> _map(Object? value, String field) {
    if (value is Map<String, dynamic>) return value;
    throw FormatException('field "$field": expected an object, got $value');
  }

  static List<String> _strings(List<dynamic>? list, String field) => [
    for (final v in list ?? const []) _string(v, field),
  ];
}
