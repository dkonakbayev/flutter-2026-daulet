/// The only file that reads `--dart-define` values.
///
///   flutter run --dart-define-from-file=env/prod.json
///   flutter run --dart-define=USE_FAKES=true
abstract final class Env {
  /// dev / prod — shown on the About screen.
  static const name = String.fromEnvironment('ENV', defaultValue: 'dev');

  /// The MockAPI.io host of the trips collection.
  static const host = String.fromEnvironment(
    'HOST',
    defaultValue: 'example.mockapi.io',
  );

  /// The public catalogue API.
  static const countriesHost = String.fromEnvironment(
    'COUNTRIES_HOST',
    defaultValue: 'restcountries.com',
  );

  /// true → the whole app runs on Fake… repositories, no network.
  static const useFakes = bool.fromEnvironment('USE_FAKES');
}
