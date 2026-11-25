import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'trips_model.dart';

/// The trips icon with a count on the navigation bar.
class TripsCountBadge extends StatelessWidget {
  const TripsCountBadge({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    // select, not watch: the badge rebuilds only when the count changes,
    // not on every loading/error flip of TripsModel.
    final count = context.select<TripsModel, int>((m) => m.items.length);
    return Badge.count(
      count: count,
      isLabelVisible: count > 0,
      child: Icon(icon),
    );
  }
}
