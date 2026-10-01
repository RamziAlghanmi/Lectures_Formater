

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/errors/exceptions.dart';

abstract class DocumentLocalDataSource {
  Future<void> cacheDocumentJson(String jsonString);
  Future<String?> getCachedDocumentJson();
  Future<void> clearCachedDocument();
}

class DocumentLocalDataSourceImpl implements DocumentLocalDataSource {
  static const String _cachedDocKey = 'cached_active_lecture_document_v1';
  final SharedPreferences _prefs;

  DocumentLocalDataSourceImpl({required SharedPreferences prefs})
    : _prefs = prefs;

  @override
  Future<void> cacheDocumentJson(String jsonString) async {
    try {
      final success = await _prefs.setString(_cachedDocKey, jsonString);
      if (!success) {
        throw const DocumentException(
          'فشل في كتابة بيانات المستند في الذاكرة المحلية',
        );
      }
    } catch (e) {
      throw DocumentException('خطأ غير متوقع أثناء تخزين المستند محلياً', e);
    }
  }

  @override
  Future<String?> getCachedDocumentJson() async {
    try {
      return _prefs.getString(_cachedDocKey);
    } catch (e) {
      throw DocumentException('خطأ أثناء قراءة المستند المخزن محلياً', e);
    }
  }

  @override
  Future<void> clearCachedDocument() async {
    try {
      await _prefs.remove(_cachedDocKey);
    } catch (e) {
      throw DocumentException('خطأ أثناء مسح بيانات المستند المخزن', e);
    }
  }
}
