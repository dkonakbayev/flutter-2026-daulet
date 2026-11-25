enum AppEnvironment { development, staging, production }

class AppConfig {
  const AppConfig({required this.environment, required this.apiHost});

  final AppEnvironment environment;
  final String apiHost;

  static const development = AppConfig(
    environment: AppEnvironment.development,
    apiHost: 'jsonplaceholder.typicode.com',
  );

  static const staging = AppConfig(
    environment: AppEnvironment.staging,
    apiHost: 'jsonplaceholder.typicode.com',
  );

  static const production = AppConfig(
    environment: AppEnvironment.production,
    apiHost: 'jsonplaceholder.typicode.com',
  );
}
