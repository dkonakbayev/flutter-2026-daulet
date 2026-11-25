import '../../core/api/api_exception.dart';
import 'trip.dart';
import 'trip_repository.dart';

/// In-memory trips for tests and `USE_FAKES=true`. Deterministic ids;
/// set [failWith] to make every call fail.
class FakeTripRepository implements TripRepository {
  FakeTripRepository({this.delay = Duration.zero, List<Trip>? seed})
    : _items = [...(seed ?? _seed)];

  final Duration delay;
  final List<Trip> _items;
  ApiException? failWith;
  int calls = 0;
  int _nextId = 100;

  static final _seed = [
    Trip(
      id: '1',
      countryCode: 'JPN',
      countryName: 'Japan',
      startDate: DateTime(2027, 4, 1),
      endDate: DateTime(2027, 4, 14),
      budget: 3000,
      rating: 5,
      notes: 'Cherry blossoms',
    ),
    Trip(
      id: '2',
      countryCode: 'FRA',
      countryName: 'France',
      startDate: DateTime(2027, 7, 10),
      endDate: DateTime(2027, 7, 20),
      budget: 2000,
      rating: 4,
    ),
  ];

  Future<void> _call() async {
    calls++;
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    final e = failWith;
    if (e != null) throw e;
  }

  int _indexOf(String id) {
    final i = _items.indexWhere((t) => t.id == id);
    if (i < 0) throw const NotFoundException();
    return i;
  }

  @override
  Future<List<Trip>> getAll() async {
    await _call();
    return List.unmodifiable(_items);
  }

  @override
  Future<Trip> getById(String id) async {
    await _call();
    return _items[_indexOf(id)];
  }

  @override
  Future<Trip> create(Trip draft) async {
    await _call();
    final created = draft.copyWith(id: '${_nextId++}');
    _items.add(created);
    return created;
  }

  @override
  Future<Trip> update(Trip trip) async {
    await _call();
    _items[_indexOf(trip.id)] = trip;
    return trip;
  }

  @override
  Future<void> delete(String id) async {
    await _call();
    _items.removeAt(_indexOf(id));
  }
}
