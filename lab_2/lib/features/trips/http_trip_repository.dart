import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'trip.dart';
import 'trip_repository.dart';

/// The `trips` resource on MockAPI.io: `https://{HOST}/api/v1/trips`.
class HttpTripRepository implements TripRepository {
  HttpTripRepository(this._api);

  final ApiClient _api;

  static const _path = '/api/v1/trips';

  @override
  Future<List<Trip>> getAll() async {
    final body = await _api.get(_path);
    return _parse('trips', () {
      final list = body as List<dynamic>;
      return [for (final j in list) Trip.fromJson(j as Map<String, dynamic>)];
    });
  }

  @override
  Future<Trip> getById(String id) async {
    final body = await _api.get('$_path/$id');
    return _parse(
      'trips/$id',
      () => Trip.fromJson(body as Map<String, dynamic>),
    );
  }

  @override
  Future<Trip> create(Trip draft) async {
    // POST → 201 Created with the new id
    final body = await _api.post(_path, draft.toJson()..remove('id'));
    return _parse('trips', () => Trip.fromJson(body as Map<String, dynamic>));
  }

  @override
  Future<Trip> update(Trip trip) async {
    // PUT → 200 with the stored object
    final body = await _api.put('$_path/${trip.id}', trip.toJson());
    return _parse(
      'trips/${trip.id}',
      () => Trip.fromJson(body as Map<String, dynamic>),
    );
  }

  @override
  Future<void> delete(String id) async {
    // DELETE → 200 (MockAPI) or 204
    await _api.delete('$_path/$id');
  }

  T _parse<T>(String resource, T Function() parse) {
    try {
      return parse();
    } on FormatException catch (e) {
      throw BadResponseException('$resource: ${e.message}');
    } on TypeError catch (e) {
      throw BadResponseException('$resource: $e');
    }
  }
}
