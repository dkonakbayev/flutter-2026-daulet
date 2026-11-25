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
  static Route<dynamic>? generate(RouteSettings settings) {
    final Widget? page = switch (settings.name) {
      AppRoutes.login => const LoginScreen(),
      AppRoutes.home => const HomeScreen(),
      AppRoutes.countryDetail => CountryDetailScreen(
        country: settings.arguments as Country,
      ),
      AppRoutes.tripForm => TripFormScreen(trip: settings.arguments as Trip?),
      AppRoutes.about => const AboutScreen(),
      _ => null,
    };
    if (page == null) return null;
    return MaterialPageRoute<dynamic>(settings: settings, builder: (_) => page);
  }

  /// One first route, chosen by the stored token — not '/' + '/login'.
  static List<Route<dynamic>> initial(String name) => [
    ?generate(RouteSettings(name: name)),
  ];
}
