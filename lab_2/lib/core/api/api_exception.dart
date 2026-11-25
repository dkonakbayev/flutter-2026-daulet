part 'bad_response_exception.dart';
part 'no_connection_exception.dart';
part 'not_found_exception.dart';
part 'request_exception.dart';
part 'server_exception.dart';
part 'unauthorized_exception.dart';

/// Everything that can go wrong with a request. Screens switch on it
/// exhaustively, so a new subclass does not compile until it is handled.
/// Each subclass lives in its own `part` file: a sealed class can only be
/// extended inside its own library.
sealed class ApiException implements Exception {
  const ApiException();
}
