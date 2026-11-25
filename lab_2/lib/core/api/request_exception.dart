part of 'api_exception.dart';

/// Any other 4xx: our request was wrong.
class RequestException extends ApiException {
  const RequestException(this.status);

  final int status;

  @override
  String toString() => 'RequestException($status)';
}
