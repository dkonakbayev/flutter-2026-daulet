part of 'api_exception.dart';

/// 401: the token is missing, wrong or expired.
class UnauthorizedException extends ApiException {
  const UnauthorizedException();

  @override
  String toString() => 'UnauthorizedException';
}
