import 'api_exception.dart';

/// One sentence for every failure. The switch has no `default`: a new
/// ApiException subclass will not compile until it gets its own text.
abstract final class ApiErrorMessage {
  static String of(ApiException e) => switch (e) {
    NoConnectionException() => 'No connection. Check the internet.',
    UnauthorizedException() => 'Wrong email or password, or the session ended.',
    NotFoundException() => 'Not found. It may have been deleted.',
    RequestException(:final status) => 'The server refused it ($status).',
    ServerException(:final status) => 'Server error ($status). Try again.',
    BadResponseException() => 'Could not read the server answer.',
  };
}
