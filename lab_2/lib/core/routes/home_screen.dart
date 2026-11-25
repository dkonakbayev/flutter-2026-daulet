import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/account/settings_screen.dart';
import '../../features/countries/countries_model.dart';
import '../../features/countries/countries_screen.dart';
import '../../features/trips/trips_count_badge.dart';
import '../../features/trips/trips_model.dart';
import '../../features/trips/trips_screen.dart';

/// The signed-in shell: Countries · My trips · Settings.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    unawaited(context.read<CountriesModel>().load());
    unawaited(context.read<TripsModel>().load());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(
      index: _tab,
      children: const [CountriesScreen(), TripsScreen(), SettingsScreen()],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _tab,
      onDestinationSelected: (i) => setState(() => _tab = i),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.public), label: 'Countries'),
        NavigationDestination(
          icon: TripsCountBadge(icon: Icons.luggage_outlined),
          label: 'My trips',
        ),
        NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    ),
  );
}
