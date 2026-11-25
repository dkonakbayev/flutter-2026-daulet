import 'trip.dart';

abstract interface class TripRepository {
  Future<List<Trip>> getAll();

  Future<Trip> getById(String id);

  /// [draft] has an empty id; the server assigns one.
  Future<Trip> create(Trip draft);

  Future<Trip> update(Trip trip);

  Future<void> delete(String id);
}
