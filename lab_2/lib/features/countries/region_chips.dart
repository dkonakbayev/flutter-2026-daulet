import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'countries_model.dart';
import 'regions.dart';

/// Region filter; the request goes to `/v3.1/region/{name}`.
class RegionChips extends StatelessWidget {
  const RegionChips({super.key});

  @override
  Widget build(BuildContext context) {
    // select: only a region change rebuilds the chips, not every list update
    final region = context.select<CountriesModel, String?>((m) => m.region);
    void pick(String? value) =>
        unawaited(context.read<CountriesModel>().filterRegion(value));
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        spacing: 8,
        children: [
          ChoiceChip(
            label: const Text('All'),
            selected: region == null,
            onSelected: (_) => pick(null),
          ),
          for (final r in Regions.all)
            ChoiceChip(
              label: Text(r),
              selected: region == r,
              onSelected: (_) => pick(r),
            ),
        ],
      ),
    );
  }
}
