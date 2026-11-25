part of 'api_exception.dart';

/// 404: the resource does not exist (or was deleted).
class NotFoundException extends ApiException {
  const NotFoundException();

  @override
  String toString() => 'NotFoundException';
}
