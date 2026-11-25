import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../storage/secure_store.dart';
import 'api_exception.dart';

/// Owns the wire: every request goes through [_send], every status through
/// [_check], every body through [_decode]. Repositories get decoded JSON.
class ApiClient {
  ApiClient(
    this._client, {
    required this.host,
    this._store,
    this._apiKey,
    this.timeout = const Duration(seconds: 10),
  });

  /// The real network client; keeps `package:http` out of `main.dart`.
  ApiClient.live({required String host, SecureStore? store, String? apiKey})
    : this(http.Client(), host: host, store: store, apiKey: apiKey);

  final http.Client _client;
  final SecureStore? _store;

  /// A fixed key of a public API (REST Countries v5) for a client
  /// without a [SecureStore]; the user's token always wins.
  final String? _apiKey;
  final String host;
  final Duration timeout;

  Future<Object?> get(String path, {Map<String, String>? query}) =>
      _send('GET', path, query: query);

  Future<Object?> post(
    String path,
    Object body, {
    Set<int> expect = const {201},
  }) => _send('POST', path, body: body, expect: expect);

  Future<Object?> put(String path, Object body) =>
      _send('PUT', path, body: body);

  Future<Object?> delete(String path) =>
      _send('DELETE', path, expect: const {200, 204});

  Future<Map<String, String>> _headers({required bool json}) async {
    final token = await _store?.readToken() ?? _apiKey;
    return {
      'Accept': 'application/json',
      if (json) 'Content-Type': 'application/json; charset=utf-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Object?> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
    Set<int> expect = const {200},
  }) async {
    final uri = Uri.https(host, path, query);
    final request = http.Request(method, uri)
      ..headers.addAll(await _headers(json: body != null));
    if (body != null) request.body = jsonEncode(body);

    final watch = Stopwatch()..start();
    final http.Response r;
    try {
      final streamed = await _client.send(request).timeout(timeout);
      r = await http.Response.fromStream(streamed).timeout(timeout);
    } on SocketException {
      throw const NoConnectionException();
    } on TimeoutException {
      throw const NoConnectionException();
    } on http.ClientException {
      throw const NoConnectionException();
    }
    if (kDebugMode) {
      // method, path, status, time — never the headers, so never the token
      log(
        '$method ${uri.path} → ${r.statusCode} (${watch.elapsedMilliseconds} ms)',
        name: 'api',
      );
    }
    _check(r, expect, '$method ${uri.path}');
    return _decode(r);
  }

  void _check(http.Response r, Set<int> expect, String where) {
    final s = r.statusCode;
    if (s == 401) throw const UnauthorizedException();
    if (s == 404) throw const NotFoundException();
    if (s >= 400 && s < 500) throw RequestException(s);
    if (s >= 500) throw ServerException(s);
    if (!expect.contains(s)) {
      throw BadResponseException('$where: expected $expect, got $s');
    }
  }

  Object? _decode(http.Response r) {
    if (r.body.isEmpty) return null;
    try {
      return jsonDecode(utf8.decode(r.bodyBytes));
    } on FormatException catch (e) {
      throw BadResponseException('invalid JSON: ${e.message}');
    }
  }
}
