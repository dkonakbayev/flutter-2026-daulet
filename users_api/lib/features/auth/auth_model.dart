import 'package:flutter/foundation.dart';

import '../../core/storage/secure_store.dart';

class AuthModel extends ChangeNotifier {
  AuthModel(this._store, {this._token});

  final SecureStore _store;
  String? _token;

  bool get signedIn => _token != null;
  String? get token => _token; // only for the debug "copy token" button

  /// Fake login: any password of 8+ characters works.
  Future<bool> login(String email, String password) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (password.length < 8) return false;
    final t = 'tok_${email.hashCode}';
    await _store.saveToken(t);
    _token = t;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    await _store.clear();
    _token = null;
    notifyListeners();
  }
}
