import 'package:flutter/material.dart';

import 'models/shift.dart';

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
