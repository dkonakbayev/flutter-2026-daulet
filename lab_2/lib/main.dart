import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/api/api_client.dart';
import 'core/env.dart';
import 'core/routes/app_router.dart';
import 'core/routes/app_routes.dart';
import 'core/storage/secure_store.dart';
import 'features/account/auth_model.dart';
import 'features/account/fake_auth_repository.dart';
import 'features/account/settings_model.dart';
import 'features/countries/countries_cache.dart';
import 'features/countries/countries_model.dart';
import 'features/countries/country_repository.dart';
import 'features/countries/fake_country_repository.dart';
import 'features/countries/http_country_repository.dart';
import 'features/trips/fake_trip_repository.dart';
import 'features/trips/http_trip_repository.dart';
import 'features/trips/trip_repository.dart';
import 'features/trips/trips_model.dart';

/// The composition root: the only file that names an Http… class.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // read before runApp: the first frame already has the right theme
  final settings = await SettingsModel.load(SharedPreferencesAsync());
  final store = SecureStore();
  final signedIn = await store.readToken() != null;

  const delay = Duration(milliseconds: 400);
  final CountryRepository countries = Env.useFakes
      ? FakeCountryRepository(delay: delay)
      : HttpCountryRepository(
          ApiClient.live(host: Env.countriesHost),
          CountriesCache(),
        );
  final TripRepository trips = Env.useFakes
      ? FakeTripRepository(delay: delay)
      : HttpTripRepository(ApiClient.live(host: Env.host, store: store));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider(
          create: (_) => AuthModel(
            FakeAuthRepository(delay: delay),
            store,
            signedIn: signedIn,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              CountriesModel(countries, region: settings.defaultRegion),
        ),
        ChangeNotifierProvider(create: (_) => TripsModel(trips)),
      ],
      child: App(initialRoute: signedIn ? AppRoutes.home : AppRoutes.login),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key, required this.initialRoute});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    final dark = context.select<SettingsModel, bool>((s) => s.dark);
    return MaterialApp(
      title: 'Trip Planner',
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      initialRoute: initialRoute,
      onGenerateRoute: AppRouter.generate,
      onGenerateInitialRoutes: AppRouter.initial,
    );
  }
}
