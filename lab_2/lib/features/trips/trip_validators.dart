/// Form rules — each one has a test in test/features/trips.
abstract final class TripValidators {
  static String? country(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Enter a country' : null;

  static String? code(String? v) {
    final s = v?.trim() ?? '';
    return RegExp(r'^[A-Za-z]{3}$').hasMatch(s) ? null : '3 letters, e.g. FRA';
  }

  static String? budget(String? v) {
    final n = double.tryParse(v?.trim() ?? '');
    if (n == null) return 'Enter a number';
    if (n < 0) return 'Cannot be negative';
    return null;
  }

  static String? endDate(DateTime start, DateTime end) =>
      end.isBefore(start) ? 'Must be on or after the start date' : null;
}
