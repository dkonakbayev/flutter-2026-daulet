import '../../core/api/json_read.dart';
import 'country_name.dart';
import 'currency.dart';

/// One country of the catalogue (REST Countries v5).
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

  /// REST Countries v5 object: `names`, `codes`, `capitals`, `area`,
  /// `flag`, `links`, `currencies`, `languages` are nested.
  factory Country.fromJson(Map<String, dynamic> json) {
    final capitals = json.read<List<dynamic>?>('capitals') ?? const [];
    final currencies = json.read<List<dynamic>?>('currencies') ?? const [];
    final languages = json.read<List<dynamic>?>('languages') ?? const [];
    return Country(
      code: json.read<Map<String, dynamic>>('codes').read<String>('alpha_3'),
      name: CountryName.fromJson(json.read<Map<String, dynamic>>('names')),
      region: json.read<String>('region'),
      population: json.read<num>('population').toInt(),
      area: json
          .read<Map<String, dynamic>>('area')
          .read<num>('kilometers')
          .toDouble(),
      capital: capitals.isEmpty
          ? null
          : _map(capitals.first, 'capitals').read<String>('name'),
      subregion: json.read<String?>('subregion'),
      flagUrl: json
          .read<Map<String, dynamic>?>('flag')
          ?.read<String?>('url_png'),
      mapsUrl: json
          .read<Map<String, dynamic>?>('links')
          ?.read<String?>('google_maps'),
      currencies: [
        for (final c in currencies) Currency.fromJson(_map(c, 'currencies')),
      ],
      languages: {
        for (final l in languages)
          _map(l, 'languages').read<String>('iso639_3'): _map(
            l,
            'languages',
          ).read<String>('name'),
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
    'codes': {'alpha_3': code},
    'names': name.toJson(),
    'region': region,
    'population': population,
    'area': {'kilometers': area},
    'capitals': [
      if (capital != null) {'name': capital},
    ],
    'subregion': ?subregion,
    'flag': {'url_png': ?flagUrl},
    'links': {'google_maps': ?mapsUrl},
    'currencies': [for (final c in currencies) c.toJson()],
    'languages': [
      for (final e in languages.entries) {'iso639_3': e.key, 'name': e.value},
    ],
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
