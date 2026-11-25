part of 'api_exception.dart';

/// The answer came but could not be read: broken JSON, a wrong type,
/// an unexpected status. A bug report, not a Retry.
class BadResponseException extends ApiException {
  const BadResponseException(this.detail);

  final String detail;

  @override
  String toString() => 'BadResponseException: $detail';
}
