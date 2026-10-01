abstract class SchemaMigration {
  int get fromVersion;
  int get toVersion;

  Map<String, dynamic> migrate(Map<String, dynamic> rawJson);
}

class SchemaMigrationV1ToV2 implements SchemaMigration {
  @override
  int get fromVersion => 1;

  @override
  int get toVersion => 2;

  @override
  Map<String, dynamic> migrate(Map<String, dynamic> rawJson) {
    final updated = Map<String, dynamic>.from(rawJson);
    updated['schemaVersion'] = 2;
    return updated;
  }
}
