import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trip_planner/core/api/api_exception.dart';
import 'package:trip_planner/core/storage/secure_store.dart';
import 'package:trip_planner/features/account/auth_model.dart';
import 'package:trip_planner/features/account/fake_auth_repository.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('the right password stores a token and signs in', () async {
    final store = SecureStore();
    final m = AuthModel(FakeAuthRepository(), store, signedIn: false);
    await m.login('a@b.kz', FakeAuthRepository.demoPassword);
    expect(m.signedIn, isTrue);
    expect(await store.readToken(), isNotNull);
  });

  test('a wrong password → UnauthorizedException, still signed out', () async {
    final store = SecureStore();
    final m = AuthModel(FakeAuthRepository(), store, signedIn: false);
    await expectLater(
      m.login('a@b.kz', 'wrongpass'),
      throwsA(isA<UnauthorizedException>()),
    );
    expect(m.signedIn, isFalse);
    expect(await store.readToken(), isNull);
  });

  test('sign out deletes the token', () async {
    final store = SecureStore();
    await store.saveToken('tok');
    final m = AuthModel(FakeAuthRepository(), store, signedIn: true);
    await m.logout();
    expect(m.signedIn, isFalse);
    expect(await store.readToken(), isNull);
  });
}
