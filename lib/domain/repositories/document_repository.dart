import '../entities/document_model.dart';

abstract class DocumentRepository {
  Future<DocumentModel> createNewDocument({
    required String title,
    String? courseName,
    String? unit,
    String? author,
  });

  Future<DocumentModel> loadDocumentFromJson(String jsonContent);

  Future<String> serializeDocumentToJson(DocumentModel document);

  Future<void> saveDocumentToFile(DocumentModel document, String filePath);

  Future<DocumentModel> loadDocumentFromFile(String filePath);

  Future<void> cacheCurrentDocument(DocumentModel document);

  Future<DocumentModel?> getCachedDocument();

  Future<void> clearCachedDocument();
}
