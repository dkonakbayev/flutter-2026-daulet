import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:users_api/core/api/api_client.dart';
import 'package:users_api/core/api/api_exception.dart';
import 'package:users_api/core/storage/secure_store.dart';

class TestSecureStore implements SecureStore {
  @override
  Future<String?> readToken() async => null;

  @override
  Future<void> saveToken(String token) async {}

  @override
  Future<void> clear() async {}
}

void main() {
  group('ApiClient', () {
    test('throws NotFoundException on 404', () async {
      final client = ApiClient(
        MockClient((request) async => http.Response('', 404)),
        TestSecureStore(),
      );

      expect(
        () => client.get(Uri.https('example.com', '/users')),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('throws ServerException on 500', () async {
      final client = ApiClient(
        MockClient((request) async => http.Response('', 500)),
        TestSecureStore(),
      );

      expect(
        () => client.get(Uri.https('example.com', '/users')),
        throwsA(isA<ServerException>()),
      );
    });

    test('throws NoConnectionException on network failure', () async {
      final client = ApiClient(
        MockClient((request) async {
          throw const SocketException('No internet');
        }),
        TestSecureStore(),
      );

      expect(
        () => client.get(Uri.https('example.com', '/users')),
        throwsA(isA<NoConnectionException>()),
      );
    });
  });
}
