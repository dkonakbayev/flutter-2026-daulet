import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';

class UserRepository {
  UserRepository(this._api);

  final ApiClient _api;

  Future<List<User>> getAll() async {
    final r = await _api.get(Uri.https(_api.host, '/users'));
    return _toUsers(r, 'users');
  }

  Future<User> getById(int id) async {
    final r = await _api.get(Uri.https(_api.host, '/users/$id'));
    return _toUser(r, 'users/$id');
  }

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
