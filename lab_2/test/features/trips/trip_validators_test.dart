import 'package:flutter_test/flutter_test.dart';
import 'package:trip_planner/features/trips/trip_validators.dart';

void main() {
  test('country is required', () {
    expect(TripValidators.country('  '), isNotNull);
    expect(TripValidators.country('Japan'), isNull);
  });

  test('code is three letters', () {
    expect(TripValidators.code('JP'), isNotNull);
    expect(TripValidators.code('jpn'), isNull);
  });

  test('budget is a non-negative number', () {
    expect(TripValidators.budget('abc'), isNotNull);
    expect(TripValidators.budget('-1'), isNotNull);
    expect(TripValidators.budget('0'), isNull);
  });

  test('end date cannot be before the start date', () {
    final start = DateTime(2027, 4, 10);
    expect(TripValidators.endDate(start, DateTime(2027, 4, 9)), isNotNull);
    expect(TripValidators.endDate(start, start), isNull);
  });
}
