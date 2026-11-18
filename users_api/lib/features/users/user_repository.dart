import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';
import 'users_cache.dart';

// 1. Contract: what every UserRepository must provide.
abstract interface class UserRepository {
  Future<({List<User> items, bool fromCache})> getAll();

  Future<User> getById(int id);

  Future<User> create(User draft);
}

// 2. Real implementation: works with HTTP API and local cache.
class HttpUserRepository implements UserRepository {
  HttpUserRepository(this._api, this._cache);

  final ApiClient _api;
  final UsersCache _cache;

  @override
  Future<({List<User> items, bool fromCache})> getAll() async {
    try {
      final fresh = await _fetch();

      try {
        await _cache.save(fresh);
      } on FileSystemException catch (e) {
        log('cache save failed: $e', name: 'cache');
      }

      return (items: fresh, fromCache: false);
    } on NoConnectionException {
      final saved = await _cache.load();
      if (saved == null) rethrow;
      return (items: saved, fromCache: true);
    }
  }

  Future<List<User>> _fetch() async {
    final r = await _api.get(Uri.https(_api.host, '/users'));
    return _toUsers(r, 'users');
  }

  @override
  Future<User> getById(int id) async {
    final r = await _api.get(Uri.https(_api.host, '/users/$id'));
    return _toUser(r, 'users/$id');
  }

  @override
  Future<User> create(User draft) async {
    final body = jsonEncode(draft.toJson()..remove('id'));
    final r = await _api.post(Uri.https(_api.host, '/users'), body);

    if (r.statusCode != 201) {
      throw BadResponseException('users: expected 201, got ${r.statusCode}');
    }

    return _toUser(r, 'users');
  }

  User _toUser(http.Response r, String where) => _guard(
    where,
    () => User.fromJson(_api.decode(r) as Map<String, dynamic>),
  );

  List<User> _toUsers(http.Response r, String where) => _guard(
    where,
    () => [
      for (final j in _api.decode(r) as List<dynamic>)
        User.fromJson(j as Map<String, dynamic>),
    ],
  );

  T _guard<T>(String where, T Function() parse) {
    try {
      return parse();
    } on TypeError catch (e) {
      throw BadResponseException('$where: $e');
    } on FormatException catch (e) {
      throw BadResponseException('$where: $e');
    }
  }
}
