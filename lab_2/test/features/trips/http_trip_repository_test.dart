import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:trip_planner/core/api/api_client.dart';
import 'package:trip_planner/core/api/api_exception.dart';
import 'package:trip_planner/features/trips/http_trip_repository.dart';
import 'package:trip_planner/features/trips/trip.dart';

import 'trip_test.dart';

void main() {
  HttpTripRepository repo(MockClientHandler handler) =>
      HttpTripRepository(ApiClient(MockClient(handler), host: 'x.mockapi.io'));

  test('create POSTs JSON without an id and expects 201', () async {
    late http.Request seen;
    final draft = Trip.fromJson(tripJson()).copyWith(id: '');
    final created = await repo((r) async {
      seen = r;
      return http.Response(jsonEncode(tripJson()), 201);
    }).create(draft);

    expect(seen.method, 'POST');
    expect(seen.url.path, '/api/v1/trips');
    expect(seen.headers['Content-Type'], startsWith('application/json'));
    expect(jsonDecode(seen.body), isNot(contains('id')));
    expect(created.id, '7');
  });

  test('update PUTs to the item path', () async {
    late http.Request seen;
    await repo((r) async {
      seen = r;
      return http.Response(jsonEncode(tripJson()), 200);
    }).update(Trip.fromJson(tripJson()));
    expect(seen.method, 'PUT');
    expect(seen.url.path, '/api/v1/trips/7');
  });

  test('delete accepts 200 and 204', () async {
    await repo((_) async => http.Response('{}', 200)).delete('7');
    await repo((_) async => http.Response('', 204)).delete('7');
  });

  test('a wrong type → BadResponseException naming resource and field', () {
    final bad = tripJson()..['rating'] = 'five';
    expect(
      repo((_) async => http.Response(jsonEncode([bad]), 200)).getAll(),
      throwsA(
        isA<BadResponseException>().having(
          (e) => e.detail,
          'detail',
          allOf(contains('trips'), contains('rating')),
        ),
      ),
    );
  });

  test('getById of a deleted trip → NotFoundException', () {
    expect(
      repo((_) async => http.Response('"Not found"', 404)).getById('9'),
      throwsA(isA<NotFoundException>()),
    );
  });
}
