import 'package:flutter/material.dart';

enum Cause {
  animals('Animals', Icons.pets),
  environment('Environment', Icons.park),
  seniors('Seniors', Icons.elderly),
  children('Children', Icons.child_care),
  food('Food bank', Icons.restaurant);

  const Cause(this.label, this.icon);

  final String label;
  final IconData icon;

  Color color(ColorScheme scheme) => switch (this) {
    Cause.animals => scheme.tertiary,
    Cause.environment => scheme.primary,
    Cause.seniors => scheme.secondary,
    Cause.children => scheme.error,
    Cause.food => scheme.outline,
  };
}
