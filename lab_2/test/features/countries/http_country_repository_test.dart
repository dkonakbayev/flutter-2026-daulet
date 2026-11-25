import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:trip_planner/core/api/api_client.dart';
import 'package:trip_planner/core/api/api_exception.dart';
import 'package:trip_planner/features/countries/countries_cache.dart';
import 'package:trip_planner/features/countries/http_country_repository.dart';

import 'country_test.dart';

void main() {
  late Directory dir;
  late CountriesCache cache;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('countries');
    cache = CountriesCache(directory: () async => dir);
  });

  tearDown(() => dir.delete(recursive: true));

  HttpCountryRepository repo(MockClientHandler handler) =>
      HttpCountryRepository(
        ApiClient(MockClient(handler), host: 'restcountries.com'),
        cache,
      );

  test('searches through the API name endpoint', () async {
    late Uri seen;
    final r = await repo((req) async {
      seen = req.url;
      return _json(v5([franceJson()]));
    }).search(query: 'fra');
    expect(seen.path, '/countries/v5/name');
    expect(seen.queryParameters['q'], 'fra');
    expect(seen.queryParameters['response_fields'], contains('alpha_3'));
    expect(r.items.single.name.common, 'France');
    expect(r.fromCache, isFalse);
  });

  test('filters through the region endpoint', () async {
    late Uri seen;
    await repo((req) async {
      seen = req.url;
      return _json(v5([]));
    }).search(region: 'Asia');
    expect(seen.path, '/countries/v5/region/Asia');
  });

  test('a 404 on a name search is an empty list', () async {
    final r = await repo((_) async => http.Response('{"status":404}', 404))
        .search(query: 'zzz');
    expect(r.items, isEmpty);
  });

  test('a wrong type → BadResponseException naming resource and field', () {
    final bad = franceJson()..['population'] = 'big';
    expect(
      repo((_) async => _json(v5([bad]))).search(),
      throwsA(
        isA<BadResponseException>().having(
          (e) => e.detail,
          'detail',
          allOf(contains('countries'), contains('population')),
        ),
      ),
    );
  });

  test('offline with a cache → the saved list, flagged', () async {
    await repo((_) async => _json(v5([franceJson()]))).search();
    final r = await repo((_) => throw const SocketException('offline'))
        .search();
    expect(r.fromCache, isTrue);
    expect(r.items.single.code, 'FRA');
  });

  test('offline with no cache → NoConnectionException', () {
    expect(
      repo((_) => throw const SocketException('offline')).search(),
      throwsA(isA<NoConnectionException>()),
    );
  });
}

http.Response _json(Object body) => http.Response.bytes(
  utf8.encode(jsonEncode(body)),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);
