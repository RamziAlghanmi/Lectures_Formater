import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../../core/config/app_config.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/document_metadata.dart';
import '../../domain/entities/document_model.dart';
import '../../domain/entities/document_settings.dart';
import '../../domain/entities/document_theme_config.dart';
import '../../domain/repositories/document_repository.dart';
import '../datasources/document_local_datasource.dart';
import '../migrations/migration_runner.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentLocalDataSource _localDataSource;
  final MigrationRunner _migrationRunner;
  final Uuid _uuid;

  DocumentRepositoryImpl({
    required DocumentLocalDataSource localDataSource,
    MigrationRunner? migrationRunner,
    Uuid? uuid,
  }) : _localDataSource = localDataSource,
       _migrationRunner = migrationRunner ?? MigrationRunner(),
       _uuid = uuid ?? const Uuid();

  @override
  Future<DocumentModel> createNewDocument({
    required String title,
    String? courseName,
    String? unit,
    String? author,
  }) async {
    final now = DateTime.now();
    return DocumentModel(
      id: _uuid.v4(),
      schemaVersion: AppConfig.currentSchemaVersion,
      metadata: DocumentMetadata(
        title: title.trim().isEmpty ? 'محاضرة جديدة' : title.trim(),
        courseName: courseName ?? '',
        unit: unit ?? '',
        author: author ?? '',
        createdAt: now,
        updatedAt: now,
      ),
      settings: const DocumentSettings(),
      theme: const DocumentThemeConfig(),
      blocks: const [],
    );
  }

  @override
  Future<DocumentModel> loadDocumentFromJson(String jsonContent) async {
    try {
      final rawMap = jsonDecode(jsonContent) as Map<String, dynamic>;
      final migratedMap = _migrationRunner.runMigrations(rawMap);
      return DocumentModel.fromJson(migratedMap);
    } catch (e) {
      if (e is MigrationException) rethrow;
      throw DocumentException('تعذر تحليل هيكل ملف JSON الخاص بالمستند', e);
    }
  }

  @override
  Future<String> serializeDocumentToJson(DocumentModel document) async {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(document.toJson());
    } catch (e) {
      throw DocumentException('تعذر تحويل كائن المستند إلى JSON', e);
    }
  }

  @override
  Future<void> saveDocumentToFile(
    DocumentModel document,
    String filePath,
  ) async {
    // Handling file system writes happens via native file picker / standard io abstractions
    // Serialized output validation:
    await serializeDocumentToJson(document);
  }

  @override
  Future<DocumentModel> loadDocumentFromFile(String filePath) async {
    throw UnimplementedError('Handled via FilePicker bytes on cross-platform');
  }

  @override
  Future<void> cacheCurrentDocument(DocumentModel document) async {
    final jsonStr = await serializeDocumentToJson(document);
    await _localDataSource.cacheDocumentJson(jsonStr);
  }

  @override
  Future<DocumentModel?> getCachedDocument() async {
    final cachedStr = await _localDataSource.getCachedDocumentJson();
    if (cachedStr == null || cachedStr.trim().isEmpty) return null;
    return loadDocumentFromJson(cachedStr);
  }

  @override
  Future<void> clearCachedDocument() async {
    await _localDataSource.clearCachedDocument();
  }
}
