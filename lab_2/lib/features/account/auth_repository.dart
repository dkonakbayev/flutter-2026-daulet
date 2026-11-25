/// Exchanges credentials for a token; throws UnauthorizedException.
abstract interface class AuthRepository {
  Future<String> login(String email, String password);
}
