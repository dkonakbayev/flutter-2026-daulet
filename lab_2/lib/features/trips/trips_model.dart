import 'package:flutter/foundation.dart';

import '../../core/api/api_exception.dart';
import 'trip.dart';
import 'trip_repository.dart';

/// State of "My trips". After every change the list is reloaded, so it
/// shows the server's answer, never a local guess.
class TripsModel extends ChangeNotifier {
  TripsModel(this._repo);

  final TripRepository _repo;

  List<Trip> items = const [];
  bool loading = false;
  ApiException? error;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      items = await _repo.getAll();
    } on ApiException catch (e) {
      error = e;
      items = const [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Creates a new trip or updates an existing one; throws [ApiException].
  Future<Trip> save(Trip trip) async {
    final saved = trip.isNew
        ? await _repo.create(trip)
        : await _repo.update(trip);
    await load();
    return saved;
  }

  /// Throws [ApiException]; the list is reloaded only on success.
  Future<void> delete(String id) async {
    await _repo.delete(id);
    await load();
  }
}
