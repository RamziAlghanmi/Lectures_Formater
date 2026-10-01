import '../../core/config/app_config.dart';
import '../../core/errors/exceptions.dart';
import 'schema_migration.dart';

class MigrationRunner {
  final List<SchemaMigration> _migrations;

  MigrationRunner({List<SchemaMigration>? migrations})
    : _migrations = migrations ?? [SchemaMigrationV1ToV2()];

  Map<String, dynamic> runMigrations(Map<String, dynamic> rawJson) {
    var currentVersion = rawJson['schemaVersion'] as int? ?? 1;
    final targetVersion = AppConfig.currentSchemaVersion;

    if (currentVersion == targetVersion) {
      return rawJson;
    }

    if (currentVersion > targetVersion) {
      throw MigrationException(
        'إصدار المستند ($currentVersion) أحدث من إصدار التطبيق ($targetVersion). يرجى تحديث التطبيق.',
        fromVersion: currentVersion,
        toVersion: targetVersion,
      );
    }

    var migratedJson = Map<String, dynamic>.from(rawJson);

    while (currentVersion < targetVersion) {
      final migration = _migrations.firstWhere(
        (m) => m.fromVersion == currentVersion,
        orElse: () => throw MigrationException(
          'لا يوجد مسار ترقية مباشر للإصدار $currentVersion إلى ${currentVersion + 1}',
          fromVersion: currentVersion,
          toVersion: targetVersion,
        ),
      );

      migratedJson = migration.migrate(migratedJson);
      currentVersion = migration.toVersion;
    }

    return migratedJson;
  }
}
