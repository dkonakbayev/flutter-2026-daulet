import 'package:flutter_test/flutter_test.dart';
import 'package:trip_planner/features/trips/trip.dart';
import 'package:trip_planner/features/trips/trip_status.dart';

Map<String, dynamic> tripJson() => {
  'id': '7',
  'countryCode': 'JPN',
  'countryName': 'Japan',
  'startDate': '2027-04-01T00:00:00.000',
  'endDate': '2027-04-14T00:00:00.000',
  'budget': 3000,
  'rating': 5,
  'notes': null,
};

void main() {
  test('fromJson reads ints as doubles, null notes, parsed dates', () {
    final t = Trip.fromJson(tripJson());
    expect(t.id, '7');
    expect(t.budget, 3000.0);
    expect(t.notes, isNull);
    expect(t.startDate, DateTime(2027, 4, 1));
  });

  test('a wrong type fails with the field name', () {
    final json = tripJson()..['budget'] = 'cheap';
    expect(
      () => Trip.fromJson(json),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('budget'),
        ),
      ),
    );
  });

  test('a bad date fails with the field name', () {
    final json = tripJson()..['endDate'] = 'soon';
    expect(
      () => Trip.fromJson(json),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('endDate'),
        ),
      ),
    );
  });

  test('toJson round-trips through fromJson', () {
    final t = Trip.fromJson(tripJson()..['notes'] = 'sakura');
    expect(Trip.fromJson(t.toJson()).toJson(), t.toJson());
  });

  test('days counts both ends', () {
    expect(Trip.fromJson(tripJson()).days, 14);
  });

  test('status depends on today', () {
    final t = Trip.fromJson(tripJson());
    expect(t.statusOn(DateTime(2027, 3, 31)), TripStatus.upcoming);
    expect(t.statusOn(DateTime(2027, 4, 14, 23)), TripStatus.ongoing);
    expect(t.statusOn(DateTime(2027, 4, 15)), TripStatus.past);
  });
}
