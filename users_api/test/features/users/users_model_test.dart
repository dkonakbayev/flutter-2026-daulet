import 'package:flutter_test/flutter_test.dart';
import 'package:users_api/core/api/api_exception.dart';
import 'package:users_api/features/users/users_model.dart';

import '../../fakes/fake_user_repository.dart';

void main() {
  group('UsersModel', () {
    test('loads users successfully', () async {
      final model = UsersModel(FakeUserRepository());

      await model.load();

      expect(model.items.length, 2);
      expect(model.loading, false);
      expect(model.error, isNull);
      expect(model.fromCache, false);

      model.dispose();
    });

    test('handles network error', () async {
      final model = UsersModel(FakeUserRepository(fail: true));

      await model.load();

      expect(model.items, isEmpty);
      expect(model.loading, false);
      expect(model.error, isA<NoConnectionException>());

      model.dispose();
    });
  });
}
