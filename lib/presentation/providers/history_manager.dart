import '../../core/config/pagination_config.dart';

class HistoryManager<T> {
  final int maxHistory;
  final List<T> _undoStack = [];
  final List<T> _redoStack = [];

  HistoryManager({int? maxHistoryLimit})
      : maxHistory = maxHistoryLimit ?? PaginationConfig.maxHistoryLimit;

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  int get undoCount => _undoStack.length;
  int get redoCount => _redoStack.length;

  /// Registers a snapshot state before mutation.
  void pushSnapshot(T currentState) {
    _undoStack.add(currentState);
    if (_undoStack.length > maxHistory) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
  }

  /// Restores the immediate prior state and records [currentState] to redo stack.
  T? undo(T currentState) {
    if (!canUndo) return null;
    final previousState = _undoStack.removeLast();
    _redoStack.add(currentState);
    return previousState;
  }

  /// Restores the forward state and records [currentState] to undo stack.
  T? redo(T currentState) {
    if (!canRedo) return null;
    final nextState = _redoStack.removeLast();
    _undoStack.add(currentState);
    return nextState;
  }

  /// Clears all stored history stacks.
  void clear() {
    _undoStack.clear();
    _redoStack.clear();
  }
}