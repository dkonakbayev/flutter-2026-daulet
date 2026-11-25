part of 'api_exception.dart';

/// No answer at all: SocketException, a timeout, a dropped connection.
class NoConnectionException extends ApiException {
  const NoConnectionException();

  @override
  String toString() => 'NoConnectionException';
}
