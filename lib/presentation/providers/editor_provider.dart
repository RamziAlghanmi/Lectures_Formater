import 'package:flutter/foundation.dart';

enum EditorViewMode { splitView, editorOnly, previewOnly }

class EditorProvider extends ChangeNotifier {
  String? _selectedBlockId;
  bool _isInspectorOpen = true;
  bool _isDragging = false;
  EditorViewMode _viewMode = EditorViewMode.splitView;

  String? get selectedBlockId => _selectedBlockId;
  bool get isInspectorOpen => _isInspectorOpen;
  bool get isDragging => _isDragging;
  EditorViewMode get viewMode => _viewMode;

  void selectBlock(String? blockId) {
    // if (_selectedBlockId == blockId) return;
    _selectedBlockId = blockId;
    if (blockId != null) {
      _isInspectorOpen = true;
    }
    notifyListeners();
  }

  void deselectBlock() {
    if (_selectedBlockId == null) return;
    _selectedBlockId = null;
    notifyListeners();
  }

  void toggleInspector() {
    _isInspectorOpen = !_isInspectorOpen;
    notifyListeners();
  }

  void setInspectorOpen(bool open) {
    if (_isInspectorOpen == open) return;
    _isInspectorOpen = open;
    notifyListeners();
  }

  void setDragging(bool dragging) {
    if (_isDragging == dragging) return;
    _isDragging = dragging;
    notifyListeners();
  }

  void setViewMode(EditorViewMode mode) {
    if (_viewMode == mode) return;
    _viewMode = mode;
    notifyListeners();
  }
}
