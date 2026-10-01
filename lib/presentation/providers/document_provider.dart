import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/config/pagination_config.dart';
import '../../domain/entities/block_node.dart';
import '../../domain/entities/document_metadata.dart';
import '../../domain/entities/document_model.dart';
import '../../domain/entities/document_settings.dart';
import '../../domain/entities/document_theme_config.dart';
import '../../domain/repositories/document_repository.dart';
import '../../domain/schemas/block_schema.dart';
import 'history_manager.dart';

class DocumentProvider extends ChangeNotifier {
  final DocumentRepository _repository;
  final HistoryManager<DocumentModel> _historyManager;

  DocumentModel _document;
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _debounceTimer;

  DocumentProvider({
    required DocumentRepository repository,
    HistoryManager<DocumentModel>? historyManager,
  }) : _repository = repository,
       _historyManager = historyManager ?? HistoryManager<DocumentModel>(),
       _document = DocumentModel(
         id: 'temp_init_id',
         metadata: DocumentMetadata(
           title: 'محاضرة جديدة',
           createdAt: DateTime.now(),
           updatedAt: DateTime.now(),
         ),
       );

  DocumentModel get document => _document;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get canUndo => _historyManager.canUndo;
  bool get canRedo => _historyManager.canRedo;

  Future<void> initializeDefaultOrCached() async {
    _setLoading(true);
    try {
      final cachedDoc = await _repository.getCachedDocument();
      if (cachedDoc != null) {
        _document = cachedDoc;
      } else {
        _document = await _repository.createNewDocument(
          title: 'محاضرة برمجية جديدة',
        );
      }
      _historyManager.clear();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'تعذر استعادة المستند المحفوظ: $e';
      _document = await _repository.createNewDocument(
        title: 'محاضرة برمجية جديدة',
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createNewDocument({
    required String title,
    String? courseName,
    String? unit,
    String? author,
  }) async {
    _setLoading(true);
    try {
      _document = await _repository.createNewDocument(
        title: title,
        courseName: courseName,
        unit: unit,
        author: author,
      );
      _historyManager.clear();
      await _repository.cacheCurrentDocument(_document);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'تعذر إنشاء مستند جديد: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadFromJson(String jsonContent) async {
    // _setLoading(true);
    try {
      final loadedDoc = await _repository.loadDocumentFromJson(jsonContent);
      _document = loadedDoc;
      _historyManager.clear();
      await _repository.cacheCurrentDocument(_document);
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'تعذر تحميل المستند من JSON: $e';
    } finally {
      // _setLoading(false);
    }
  }

  Future<String> exportJson() async {
    return _repository.serializeDocumentToJson(_document);
  }

  void addBlock(BlockNode block, {int? atIndex}) {
    _recordHistorySnapshot();
    if (atIndex != null) {
      _document = _document.insertBlock(atIndex, block);
    } else {
      final currentList = List<BlockNode>.from(_document.blocks)..add(block);
      _document = _document.copyWith(
        blocks: currentList,
        metadata: _document.metadata.copyWith(updatedAt: DateTime.now()),
      );
    }
    _notifyAndPersist();
  }

  void updateBlock(BlockNode updatedNode) {
    _recordHistorySnapshot();
    _document = _document.updateBlock(updatedNode);
    _notifyAndPersist();
  }

  void updateBlockField(String blockId, String fieldKey, dynamic value) {
    final existingBlock = _document.findBlockById(blockId);
    if (existingBlock == null) return;

    _scheduleDebouncedSnapshot();

    final updatedFields = Map<String, dynamic>.from(existingBlock.fields);
    updatedFields[fieldKey] = value;

    final updatedBlock = existingBlock.copyWith(fields: updatedFields);
    _document = _document.updateBlock(updatedBlock);
    _notifyAndPersist();
  }

  void updateBlockStyle(String blockId, BlockStyleOverride style) {
    final existingBlock = _document.findBlockById(blockId);
    if (existingBlock == null) return;

    _recordHistorySnapshot();
    final updatedBlock = existingBlock.copyWith(style: style);
    _document = _document.updateBlock(updatedBlock);
    _notifyAndPersist();
  }

  void updateBlockLayoutRules(String blockId, BlockLayoutRules layoutRules) {
    final existingBlock = _document.findBlockById(blockId);
    if (existingBlock == null) return;

    _recordHistorySnapshot();
    final updatedBlock = existingBlock.copyWith(layoutRules: layoutRules);
    _document = _document.updateBlock(updatedBlock);
    _notifyAndPersist();
  }

  void removeBlock(String blockId) {
    _recordHistorySnapshot();
    _document = _document.removeBlock(blockId);
    _notifyAndPersist();
  }

  void moveBlock(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    _recordHistorySnapshot();
    _document = _document.moveBlock(oldIndex, newIndex);
    _notifyAndPersist();
  }

  void moveBlockByDelta(String blockId, int delta) {
    final currentIndex = _document.blocks.indexWhere((b) => b.id == blockId);
    if (currentIndex == -1) return;

    final newIndex = currentIndex + delta;
    if (newIndex >= 0 && newIndex < _document.blocks.length) {
      moveBlock(currentIndex, newIndex);
    }
  }

  void updateSettings(DocumentSettings settings) {
    _recordHistorySnapshot();
    _document = _document.copyWith(settings: settings);
    _notifyAndPersist();
  }

  void updateTheme(DocumentThemeConfig theme) {
    _recordHistorySnapshot();
    _document = _document.copyWith(theme: theme);
    _notifyAndPersist();
  }

  void updateMetadata(DocumentMetadata metadata) {
    _recordHistorySnapshot();
    _document = _document.copyWith(metadata: metadata);
    _notifyAndPersist();
  }

  void undo() {
    if (!_historyManager.canUndo) return;
    final previousDoc = _historyManager.undo(_document);
    if (previousDoc != null) {
      _document = previousDoc;
      _notifyAndPersist(recordHistory: false);
    }
  }

  void redo() {
    if (!_historyManager.canRedo) return;
    final nextDoc = _historyManager.redo(_document);
    if (nextDoc != null) {
      _document = nextDoc;
      _notifyAndPersist(recordHistory: false);
    }
  }

  Future<void> clearDocument() async {
    _recordHistorySnapshot();
    _document = _document.copyWith(
      blocks: const [],
      metadata: _document.metadata.copyWith(updatedAt: DateTime.now()),
    );
    _notifyAndPersist();
  }

  void _recordHistorySnapshot() {
    _debounceTimer?.cancel();
    _historyManager.pushSnapshot(_document);
  }

  void _scheduleDebouncedSnapshot() {
    if (_debounceTimer?.isActive ?? false) return;
    _historyManager.pushSnapshot(_document);
    _debounceTimer = Timer(
      const Duration(milliseconds: PaginationConfig.debounceDurationMs),
      () {},
    );
  }

  Timer? _autoSaveTimer;

  void _notifyAndPersist({bool recordHistory = true}) {
    notifyListeners();
    // تأخير كتابة الـ JSON والتخزين المحلي حتى يتوقف المستخدم عن الكتابة لمدة ثانية كاملة
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(milliseconds: 1000), () {
      _repository.cacheCurrentDocument(_document);
    });
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _autoSaveTimer?.cancel();
    super.dispose();
  }
}
