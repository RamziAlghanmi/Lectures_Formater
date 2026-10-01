class DocumentException implements Exception {
  final String message;
  final dynamic cause;

  const DocumentException(this.message, [this.cause]);

  @override
  String toString() => 'DocumentException: $message ${cause != null ? "($cause)" : ""}';
}

class SchemaException implements Exception {
  final String message;

  const SchemaException(this.message);

  @override
  String toString() => 'SchemaException: $message';
}

class MigrationException implements Exception {
  final String message;
  final int fromVersion;
  final int toVersion;

  const MigrationException(this.message, {required this.fromVersion, required this.toVersion});

  @override
  String toString() => 'MigrationException ($fromVersion -> $toVersion): $message';
}

class LayoutCalculationException implements Exception {
  final String message;

  const LayoutCalculationException(this.message);

  @override
  String toString() => 'LayoutCalculationException: $message';
}
