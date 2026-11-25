import 'package:flutter_test/flutter_test.dart';
import 'package:trip_planner/core/api/api_exception.dart';
import 'package:trip_planner/features/trips/fake_trip_repository.dart';
import 'package:trip_planner/features/trips/trip.dart';
import 'package:trip_planner/features/trips/trips_model.dart';

void main() {
  test('load fills items', () async {
    final m = TripsModel(FakeTripRepository());
    await m.load();
    expect(m.items, hasLength(2));
    expect(m.error, isNull);
    expect(m.loading, isFalse);
  });

  test('NoConnection → error, no items', () async {
    final m = TripsModel(
      FakeTripRepository()..failWith = const NoConnectionException(),
    );
    await m.load();
    expect(m.error, isA<NoConnectionException>());
    expect(m.items, isEmpty);
  });

  test('save of a draft creates it and the list is reloaded', () async {
    final repo = FakeTripRepository();
    final m = TripsModel(repo);
    final saved = await m.save(
      Trip.draft(countryCode: 'KAZ', countryName: 'Kazakhstan'),
    );
    expect(saved.id, isNotEmpty);
    expect(m.items.map((t) => t.id), contains(saved.id));
  });

  test('save of an existing trip updates it, not a duplicate', () async {
    final m = TripsModel(FakeTripRepository());
    await m.load();
    await m.save(m.items.first.copyWith(rating: 1));
    expect(m.items, hasLength(2));
    expect(m.items.first.rating, 1);
  });

  test('a failed delete throws and keeps the list', () async {
    final repo = FakeTripRepository();
    final m = TripsModel(repo);
    await m.load();
    repo.failWith = const ServerException(500);
    await expectLater(m.delete('1'), throwsA(isA<ServerException>()));
    expect(m.items, hasLength(2));
  });

  test('delete removes the trip on the server', () async {
    final m = TripsModel(FakeTripRepository());
    await m.delete('1');
    expect(m.items.map((t) => t.id), ['2']);
  });
}
