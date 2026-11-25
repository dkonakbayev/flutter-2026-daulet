import '../../core/api/api_exception.dart';
import 'auth_repository.dart';

/// Fake sign-in (the course needs no real auth server): the demo password
/// is accepted, anything else answers like a server's 401.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.delay = Duration.zero});

  static const demoPassword = 'travel123';

  final Duration delay;

  @override
  Future<String> login(String email, String password) async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    if (password != demoPassword) throw const UnauthorizedException();
    return 'tok_${email.trim().toLowerCase().hashCode.toRadixString(16)}';
  }
}
