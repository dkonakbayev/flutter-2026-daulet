import 'package:flutter/material.dart';

import '../../core/format/date_text.dart';

/// A read-only text field that opens [showDatePicker] on tap.
class DateField extends StatelessWidget {
  const DateField({
    super.key,
    required this.label,
    required this.value,
    required this.onPicked,
    this.validator,
  });

  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onPicked;
  final String? Function()? validator;

  Future<void> _pick(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) onPicked(picked); // Cancel → null, nothing changes
  }

  @override
  Widget build(BuildContext context) {
    final check = validator;
    return TextFormField(
      // the key makes the field show a newly picked date
      key: ValueKey('$label $value'),
      initialValue: DateText.of(value),
      readOnly: true,
      onTap: () => _pick(context),
      validator: check == null ? null : (_) => check(),
      autovalidateMode: AutovalidateMode.always,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.calendar_today),
      ),
    );
  }
}
