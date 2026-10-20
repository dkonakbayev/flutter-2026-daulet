import 'package:flutter/material.dart';

import 'models/shift.dart';
import 'screens/detail_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/shift_form_screen.dart';

abstract final class Routes {
  static const home = '/';
  static const detail = '/detail';
  static const form = '/form';
}

class DetailArgs {
  const DetailArgs({
    required this.shift,
    required this.profileName,
    required this.onChanged,
    required this.onDelete,
    required this.onShowProfile,
  });

  final Shift shift;
  final String profileName;
  final ValueChanged<Shift> onChanged;
  final ValueChanged<Shift> onDelete;
  final VoidCallback onShowProfile;
}

class FormArgs {
  const FormArgs([this.shift]);

  final Shift? shift;
}

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  return switch ((settings.name, settings.arguments)) {
    (Routes.detail, final DetailArgs args) => MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => DetailScreen(args: args),
    ),
    (Routes.form, final FormArgs args) => MaterialPageRoute<Shift>(
      settings: settings,
      builder: (_) => ShiftFormScreen(shift: args.shift),
    ),
    _ => null,
  };
}

Route<dynamic> onUnknownRoute(RouteSettings settings) {
  return MaterialPageRoute<void>(
    settings: settings,
    builder: (_) => const NotFoundScreen(),
  );
}
