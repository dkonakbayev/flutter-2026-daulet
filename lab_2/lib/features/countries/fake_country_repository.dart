import '../../core/api/api_exception.dart';
import 'country.dart';
import 'country_name.dart';
import 'country_repository.dart';
import 'currency.dart';

/// Deterministic, offline catalogue for tests and `USE_FAKES=true`.
/// Set [failWith] to make the next calls fail; [fromCache] to pretend the
/// list came from the offline cache.
class FakeCountryRepository implements CountryRepository {
  FakeCountryRepository({this.delay = Duration.zero});

  final Duration delay;
  ApiException? failWith;
  bool fromCache = false;
  int calls = 0;

  static const countries = [
    Country(
      code: 'FRA',
      name: CountryName(common: 'France', official: 'French Republic'),
      region: 'Europe',
      subregion: 'Western Europe',
      population: 66351959,
      area: 551695,
      capital: 'Paris',
      flagUrl: 'https://flagcdn.com/w320/fr.png',
      mapsUrl: 'https://goo.gl/maps/g7QxxSFsWyTPKuzd7',
      currencies: [Currency(code: 'EUR', name: 'Euro', symbol: '€')],
      languages: {'fra': 'French'},
      timezones: ['UTC+01:00'],
      borders: ['AND', 'BEL', 'DEU', 'ITA', 'ESP', 'CHE'],
    ),
    Country(
      code: 'JPN',
      name: CountryName(common: 'Japan', official: 'Japan'),
      region: 'Asia',
      subregion: 'Eastern Asia',
      population: 125836021,
      area: 377930,
      capital: 'Tokyo',
      flagUrl: 'https://flagcdn.com/w320/jp.png',
      mapsUrl: 'https://goo.gl/maps/NGTLSCSrA8bMrvnX9',
      currencies: [Currency(code: 'JPY', name: 'Japanese yen', symbol: '¥')],
      languages: {'jpn': 'Japanese'},
      timezones: ['UTC+09:00'],
    ),
    Country(
      code: 'KAZ',
      name: CountryName(
        common: 'Kazakhstan',
        official: 'Republic of Kazakhstan',
      ),
      region: 'Asia',
      subregion: 'Central Asia',
      population: 18754440,
      area: 2724900,
      capital: 'Astana',
      flagUrl: 'https://flagcdn.com/w320/kz.png',
      mapsUrl: 'https://goo.gl/maps/8VohJGu7ShuzZYyeA',
      currencies: [
        Currency(code: 'KZT', name: 'Kazakhstani tenge', symbol: '₸'),
      ],
      languages: {'kaz': 'Kazakh', 'rus': 'Russian'},
      timezones: ['UTC+05:00'],
      borders: ['CHN', 'KGZ', 'RUS', 'TKM', 'UZB'],
    ),
    Country(
      code: 'BRA',
      name: CountryName(
        common: 'Brazil',
        official: 'Federative Republic of Brazil',
      ),
      region: 'Americas',
      subregion: 'South America',
      population: 212559409,
      area: 8515767,
      capital: 'Brasília',
      flagUrl: 'https://flagcdn.com/w320/br.png',
      mapsUrl: 'https://goo.gl/maps/waCKk21HeeqFzkNC9',
      currencies: [
        Currency(code: 'BRL', name: 'Brazilian real', symbol: r'R$'),
      ],
      languages: {'por': 'Portuguese'},
      timezones: ['UTC-03:00'],
    ),
  ];

  Future<void> _call() async {
    calls++;
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    final e = failWith;
    if (e != null) throw e;
  }

  @override
  Future<CountryList> search({String query = '', String? region}) async {
    await _call();
    final q = query.trim().toLowerCase();
    final items = [
      for (final c in countries)
        if (q.isNotEmpty
            ? c.name.common.toLowerCase().contains(q)
            : region == null || c.region == region)
          c,
    ];
    return (items: items, fromCache: fromCache);
  }

  @override
  Future<Country> getByCode(String code) async {
    await _call();
    for (final c in countries) {
      if (c.code == code) return c;
    }
    throw const NotFoundException();
  }
}
