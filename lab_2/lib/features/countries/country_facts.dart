import 'package:flutter/material.dart';

import 'country.dart';

/// The nested objects rendered: currencies, languages, borders, timezones.
class CountryFacts extends StatelessWidget {
  const CountryFacts(this.country, {super.key});

  final Country country;

  @override
  Widget build(BuildContext context) {
    final c = country;
    final rows = <(String, String)>[
      ('Capital', c.capital ?? '—'),
      ('Region', [c.region, ?c.subregion].join(' · ')),
      ('Population', '${c.population}'),
      ('Area', '${c.area.toStringAsFixed(0)} km²'),
      ('Density', '${c.density.toStringAsFixed(1)} people/km²'),
      ('Currencies', c.currencies.join(', ')),
      ('Languages', c.languages.values.join(', ')),
      if (c.timezones.isNotEmpty) ('Timezones', c.timezones.join(', ')),
      if (c.borders.isNotEmpty) ('Borders', c.borders.join(', ')),
    ];
    return Column(
      children: [
        for (final (label, value) in rows)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(label),
            subtitle: Text(value.isEmpty ? '—' : value),
          ),
      ],
    );
  }
}
