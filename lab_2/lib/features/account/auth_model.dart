import 'package:flutter/foundation.dart';

import '../../core/storage/secure_store.dart';
import 'auth_repository.dart';

/// Signed in or not. The token goes straight into [SecureStore]; this
/// class never keeps it in a field.
class AuthModel extends ChangeNotifier {
  AuthModel(this._repo, this._store, {required this.signedIn});

  final AuthRepository _repo;
  final SecureStore _store;
  bool signedIn;

  /// Throws ApiException when the server says no.
  Future<void> login(String email, String password) async {
    await _store.saveToken(await _repo.login(email, password));
    signedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await _store.clear();
    signedIn = false;
    notifyListeners();
  }
}
