abstract class Failure {
  final String message;
  final String? details;

  const Failure(this.message, [this.details]);

  @override
  String toString() => details == null ? message : '$message: $details';
}

class DocumentLoadFailure extends Failure {
  const DocumentLoadFailure(super.message, [super.details]);
}

class DocumentSaveFailure extends Failure {
  const DocumentSaveFailure(super.message, [super.details]);
}

class SchemaValidationFailure extends Failure {
  const SchemaValidationFailure(super.message, [super.details]);
}

class MigrationFailure extends Failure {
  const MigrationFailure(super.message, [super.details]);
}

class PdfGenerationFailure extends Failure {
  const PdfGenerationFailure(super.message, [super.details]);
}

class PreflightCheckFailure extends Failure {
  const PreflightCheckFailure(super.message, [super.details]);
}
