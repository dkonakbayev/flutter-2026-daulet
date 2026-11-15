import 'package:flutter/foundation.dart';

import '../../core/api/api_exception.dart';
import 'user.dart';
import 'user_repository.dart';

class UsersModel extends ChangeNotifier {
  UsersModel(this._repo);

  final UserRepository _repo;

  List<User> items = const [];
  ApiException? error;
  bool loading = false;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      items = await _repo.getAll();
    } on ApiException catch (e) {
      error = e;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Returns null on success, or the exception on failure.
  Future<ApiException?> create({
    required String name,
    required String username,
    required String email,
  }) async {
    const draftAddress = Address(
      street: '',
      suite: '',
      city: '',
      zipcode: '',
      geo: Geo(lat: 0, lng: 0),
    );
    final draft = User(
      id: 0,
      name: name,
      username: username,
      email: email,
      phone: '',
      website: null,
      address: draftAddress,
      company: (name: '', catchPhrase: ''),
    );
    try {
      final created = await _repo.create(draft);
      items = [created, ...items];
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e;
    }
  }
}
