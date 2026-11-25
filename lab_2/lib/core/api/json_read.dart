/// Typed reads from a decoded JSON object. A wrong type becomes a
/// [FormatException] that names the field, so the repository can turn it
/// into a BadResponseException with the resource and the field.
extension JsonRead on Map<String, dynamic> {
  T read<T>(String key) {
    final value = this[key];
    if (value is T) return value;
    throw FormatException(
      'field "$key": expected $T, got ${value.runtimeType}',
    );
  }
}
