class AuriError implements Exception {
  final String message;
  AuriError(this.message);

  @override
  String toString() => "AuriError: $message";
}
