import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../trips/trip.dart';
import 'country.dart';
import 'country_facts.dart';
import 'country_flag.dart';
import 'maps_button.dart';

class CountryDetailBody extends StatelessWidget {
  const CountryDetailBody(this.country, {super.key, this.loadingMore = false});

  final Country country;
  final bool loadingMore;

  Future<void> _addTrip(BuildContext context) async {
    final draft = Trip.draft(
      countryCode: country.code,
      countryName: country.name.common,
    );
    final saved = await Navigator.of(context)
        .pushNamed<Trip>(AppRoutes.tripForm, arguments: draft);
    if (saved == null || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Trip to ${saved.countryName} saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (loadingMore) const LinearProgressIndicator(),
        Center(child: CountryFlag(country.flagUrl, width: 200)),
        const SizedBox(height: 16),
        Text(country.name.official, style: text.headlineSmall),
        const SizedBox(height: 16),
        CountryFacts(country),
        const SizedBox(height: 16),
        if (country.mapsUrl case final url?) MapsButton(url),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: () => _addTrip(context),
          icon: const Icon(Icons.add),
          label: const Text('Add to my trips'),
        ),
      ],
    );
  }
}
