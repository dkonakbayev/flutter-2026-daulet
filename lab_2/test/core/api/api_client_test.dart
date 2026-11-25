import 'dart:async';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:trip_planner/core/api/api_client.dart';
import 'package:trip_planner/core/api/api_exception.dart';
import 'package:trip_planner/core/storage/secure_store.dart';

ApiClient _client(MockClientHandler handler, {Duration? timeout}) => ApiClient(
  MockClient(handler),
  host: 'example.com',
  timeout: timeout ?? const Duration(seconds: 10),
);

void main() {
  test('404 → NotFoundException', () {
    final api = _client((_) async => http.Response('', 404));
    expect(api.get('/x'), throwsA(isA<NotFoundException>()));
  });

  test('500 → ServerException with the status', () {
    final api = _client((_) async => http.Response('', 500));
    expect(
      api.get('/x'),
      throwsA(isA<ServerException>().having((e) => e.status, 'status', 500)),
    );
  });

  test('401 → UnauthorizedException, other 4xx → RequestException', () {
    expect(
      _client((_) async => http.Response('', 401)).get('/x'),
      throwsA(isA<UnauthorizedException>()),
    );
    expect(
      _client((_) async => http.Response('', 422)).get('/x'),
      throwsA(isA<RequestException>()),
    );
  });

  test('SocketException → NoConnectionException', () {
    final api = _client((_) => throw const SocketException('offline'));
    expect(api.get('/x'), throwsA(isA<NoConnectionException>()));
  });

  test('a server that never answers → NoConnectionException', () {
    final never = Completer<http.Response>();
    final api = _client(
      (_) => never.future,
      timeout: const Duration(milliseconds: 50),
    );
    expect(api.get('/x'), throwsA(isA<NoConnectionException>()));
  });

  test('broken JSON → BadResponseException', () {
    final api = _client((_) async => http.Response('{oops', 200));
    expect(api.get('/x'), throwsA(isA<BadResponseException>()));
  });

  test('an unexpected success status → BadResponseException', () {
    final api = _client((_) async => http.Response('{}', 200));
    expect(api.post('/x', {'a': 1}), throwsA(isA<BadResponseException>()));
  });

  test('builds an https URI and decodes the body', () async {
    late Uri seen;
    final api = _client((r) async {
      seen = r.url;
      return http.Response('[1, 2]', 200);
    });
    expect(await api.get('/v1/items', query: {'q': 'a b'}), [1, 2]);
    expect(seen.scheme, 'https');
    expect(seen.host, 'example.com');
    expect(seen.queryParameters['q'], 'a b');
  });

  test('adds the Bearer token from secure storage', () async {
    FlutterSecureStorage.setMockInitialValues({'auth_token': 'tok_1'});
    late http.BaseRequest seen;
    final api = ApiClient(
      MockClient((r) async {
        seen = r;
        return http.Response('{}', 200);
      }),
      host: 'example.com',
      store: SecureStore(),
    );
    await api.get('/x');
    expect(seen.headers['Authorization'], 'Bearer tok_1');
  });

  test('a public API key is sent when there is no user token', () async {
    late http.BaseRequest seen;
    final api = ApiClient(
      MockClient((r) async {
        seen = r;
        return http.Response('{}', 200);
      }),
      host: 'api.restcountries.com',
      apiKey: 'rc_key',
    );
    await api.get('/countries/v5');
    expect(seen.headers['Authorization'], 'Bearer rc_key');
  });
}
