import 'package:flutter/material.dart';

import '../../features/account/about_screen.dart';
import '../../features/account/login_screen.dart';
import '../../features/countries/country.dart';
import '../../features/countries/country_detail_screen.dart';
import '../../features/trips/trip.dart';
import '../../features/trips/trip_form_screen.dart';
import 'app_routes.dart';
import 'home_screen.dart';

abstract final class AppRouter {
  static Route<dynamic>? generate(RouteSettings settings) =>
      switch (settings.name) {
        AppRoutes.login => _page(settings, const LoginScreen()),
        AppRoutes.home => _page(settings, const HomeScreen()),
        AppRoutes.countryDetail => _page(
          settings,
          CountryDetailScreen(country: settings.arguments as Country),
        ),
        // typed: the caller awaits pushNamed<Trip>, which casts the route
        // to Route<Trip?> — a Route<dynamic> would throw there
        AppRoutes.tripForm => _page<Trip>(
          settings,
          TripFormScreen(trip: settings.arguments as Trip?),
        ),
        AppRoutes.about => _page(settings, const AboutScreen()),
        _ => null,
      };

  static MaterialPageRoute<T> _page<T>(RouteSettings settings, Widget page) =>
      MaterialPageRoute<T>(settings: settings, builder: (_) => page);

  /// One first route, chosen by the stored token — not '/' + '/login'.
  static List<Route<dynamic>> initial(String name) => [
    ?generate(RouteSettings(name: name)),
  ];
}
