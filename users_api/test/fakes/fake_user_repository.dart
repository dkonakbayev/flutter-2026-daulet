import 'dart:async';

import 'package:users_api/core/api/api_exception.dart';
import 'package:users_api/features/users/user.dart';
import 'package:users_api/features/users/user_repository.dart';

class FakeUserRepository implements UserRepository {
  FakeUserRepository({this.fail = false, this.delay = Duration.zero});

  final bool fail;
  final Duration delay;

  final List<User> _users = [
    User(
      id: 1,
      name: 'Leanne Graham',
      username: 'Bret',
      email: 'leanne@example.com',
      phone: '1-770-736-8031',
      website: 'hildegard.org',
      address: const Address(
        street: 'Kulas Light',
        suite: 'Apt. 556',
        city: 'Gwenborough',
        zipcode: '92998-3874',
        geo: Geo(lat: -37.3159, lng: 81.1496),
      ),
      company: (
        name: 'Romaguera-Crona',
        catchPhrase: 'Multi-layered client-server neural-net',
      ),
    ),
    User(
      id: 2,
      name: 'Ervin Howell',
      username: 'Antonette',
      email: 'ervin@example.com',
      phone: '010-692-6593',
      website: 'anastasia.net',
      address: const Address(
        street: 'Victor Plains',
        suite: 'Suite 879',
        city: 'Wisokyburgh',
        zipcode: '90566-7771',
        geo: Geo(lat: -43.9509, lng: -34.4618),
      ),
      company: (
        name: 'Deckow-Crist',
        catchPhrase: 'Proactive didactic contingency',
      ),
    ),
  ];

  Future<void> _wait() async {
    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }

    if (fail) {
      throw const NoConnectionException();
    }
  }

  @override
  Future<({List<User> items, bool fromCache})> getAll() async {
    await _wait();
    return (items: List<User>.unmodifiable(_users), fromCache: false);
  }

  @override
  Future<User> getById(int id) async {
    await _wait();
    return _users.firstWhere((user) => user.id == id);
  }

  @override
  Future<User> create(User draft) async {
    await _wait();

    final created = User(
      id: _users.length + 1,
      name: draft.name,
      username: draft.username,
      email: draft.email,
      phone: draft.phone,
      website: draft.website,
      address: draft.address,
      company: draft.company,
    );

    _users.insert(0, created);
    return created;
  }
}
