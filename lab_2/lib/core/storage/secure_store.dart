import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The only place the token is kept. Only [ApiClient] and the auth
/// notifier talk to it; no repository and no screen reads the token.
class SecureStore {
  SecureStore([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;
  static const _key = 'auth_token';

  Future<void> saveToken(String token) =>
      _storage.write(key: _key, value: token);

  Future<String?> readToken() => _storage.read(key: _key);

  Future<void> clear() => _storage.delete(key: _key);
}
