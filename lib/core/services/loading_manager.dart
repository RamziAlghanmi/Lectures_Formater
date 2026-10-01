import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LoadingStep {
  final String message;
  final Future<void> Function() operation;
  final Color? color;

  const LoadingStep({
    required this.message,
    required this.operation,
    this.color,
  });
}

// ============================================================
// حالة التحميل
// ============================================================

class LoadingState {
  final int count;
  final String? message;
  final Color color;

  const LoadingState({this.count = 0, this.message, this.color = Colors.blue});

  bool get isLoading => count > 0;
}

// ============================================================
// Loading Manager
// ============================================================

class LoadingManager {
  LoadingManager._();

  static final ValueNotifier<LoadingState> _state = ValueNotifier<LoadingState>(
    const LoadingState(),
  );

  // ============================================================
  // Getters
  // ============================================================

  static bool get isLoading => _state.value.isLoading;

  static int get loadingCount => _state.value.count;

  static String? get message => _state.value.message;

  static Color get color => _state.value.color;

  // الـListenable الوحيد الذي نحتاجه
  static ValueListenable<LoadingState> get listenable => _state;

  // ============================================================
  // تشغيل عملية واحدة
  // ============================================================

  static Future<T> run<T>(
    Future<T> Function() operation, {
    String? message,
    Color? color,
  }) async {
    show(message: message, color: color);

    try {
      return await operation();
    } finally {
      hide();
    }
  }

  // ============================================================
  // تشغيل عدة عمليات بالتتابع
  // ============================================================

  static Future<void> runSteps(List<LoadingStep> steps) async {
    if (steps.isEmpty) return;

    show(message: steps.first.message, color: steps.first.color);

    try {
      for (final step in steps) {
        setMessage(step.message, color: step.color);

        await step.operation();
      }
    } finally {
      hide();
    }
  }

  // ============================================================
  // إظهار Loading
  // ============================================================

  static void show({String? message, Color? color}) {
    final current = _state.value;

    _state.value = LoadingState(
      count: current.count + 1,
      message: message ?? current.message,
      color: color ?? current.color,
    );
  }

  // ============================================================
  // تغيير الرسالة
  // ============================================================

  static void setMessage(String message, {Color? color}) {
    final current = _state.value;

    _state.value = LoadingState(
      count: current.count,
      message: message,
      color: color ?? current.color,
    );
  }

  // ============================================================
  // تغيير اللون
  // ============================================================

  static void setColor(Color color) {
    final current = _state.value;

    _state.value = LoadingState(
      count: current.count,
      message: current.message,
      color: color,
    );
  }

  // ============================================================
  // إخفاء Loading
  // ============================================================

  static void hide() {
    final current = _state.value;

    if (current.count <= 0) return;

    final newCount = current.count - 1;

    if (newCount == 0) {
      // عند انتهاء جميع العمليات
      _state.value = const LoadingState();
    } else {
      _state.value = LoadingState(
        count: newCount,
        message: current.message,
        color: current.color,
      );
    }
  }

  // ============================================================
  // Reset
  // ============================================================

  static void reset() {
    _state.value = const LoadingState();
  }
}
