part of 'api_exception.dart';

/// 5xx: their server failed; Retry may help.
class ServerException extends ApiException {
  const ServerException(this.status);

  final int status;

  @override
  String toString() => 'ServerException($status)';
}
