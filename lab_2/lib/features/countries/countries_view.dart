import 'package:flutter/material.dart';

import 'country.dart';
import 'country_tile.dart';

/// The data state: a list on a phone, a grid from 600 px.
class CountriesView extends StatelessWidget {
  const CountriesView(this.countries, {super.key, required this.onRefresh});

  final List<Country> countries;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: onRefresh,
    child: LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          return GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 320,
              mainAxisExtent: 80,
            ),
            itemCount: countries.length,
            itemBuilder: (context, i) => Card(child: CountryTile(countries[i])),
          );
        }
        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: countries.length,
          separatorBuilder: (context, i) => const Divider(height: 1),
          itemBuilder: (context, i) => CountryTile(countries[i]),
        );
      },
    ),
  );
}
