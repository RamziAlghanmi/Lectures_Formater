import 'package:flutter/material.dart';

class SyntaxHighlighter {
  static const Map<String, List<String>> _keywords = {
    'dart': [
      'if', 'else', 'for', 'while', 'return', 'class', 'void', 'int',
      'double', 'String', 'bool', 'true', 'false', 'null', 'this', 'super',
      'extends', 'implements', 'import', 'export', 'library', 'part', 'var',
      'final', 'const', 'new', 'switch', 'case', 'break', 'continue', 'try',
      'catch', 'finally', 'throw', 'async', 'await'
    ],
    'python': [
      'if', 'elif', 'else', 'for', 'while', 'return', 'def', 'class',
      'import', 'from', 'as', 'print', 'True', 'False', 'None', 'lambda',
      'try', 'except', 'finally', 'raise', 'with', 'yield', 'and', 'or', 'not'
    ],
    'javascript': [
      'if', 'else', 'for', 'while', 'return', 'function', 'class', 'var',
      'let', 'const', 'true', 'false', 'null', 'undefined', 'this', 'super',
      'extends', 'import', 'export', 'new', 'switch', 'case', 'break',
      'continue', 'try', 'catch', 'finally', 'throw', 'async', 'await'
    ],
  };

  static const Color commentColor = Color(0xFF6A9955);
  static const Color stringColor = Color(0xFFCE9178);
  static const Color keywordColor = Color(0xFF569CD6);
  static const Color functionColor = Color(0xFFDCDCAA);
  static const Color numberColor = Color(0xFFB5CEA8);
  static const Color defaultColor = Color(0xFFD4D4D4);

  /// تظليل الكود البرمجي باستخدام تحليل بسيط بدون RegExp معقد.
  static TextSpan highlight(String code, String language) {
    final lang = language.toLowerCase();
    final keywordList = _keywords[lang] ?? _keywords['dart']!;

    final spans = <TextSpan>[];
    final lines = code.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      spans.addAll(_highlightLine(line, keywordList));

      // إضافة سطر جديد بين الأسطر
      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n', style: TextStyle(color: defaultColor)));
      }
    }

    return TextSpan(children: spans);
  }

  /// تظليل سطر واحد من الكود.
  static List<TextSpan> _highlightLine(String line, List<String> keywords) {
    final spans = <TextSpan>[];
    final tokens = _tokenize(line);

    for (final token in tokens) {
      if (token.isEmpty) continue;

      // تعليقات
      if (token.startsWith('//') || token.startsWith('#') || token.startsWith('/*')) {
        spans.add(TextSpan(
          text: token,
          style: const TextStyle(color: commentColor),
        ));
      }
      // نصوص (Strings)
      else if (token.startsWith('"') || token.startsWith("'")) {
        spans.add(TextSpan(
          text: token,
          style: const TextStyle(color: stringColor),
        ));
      }
      // أرقام
      else if (_isNumber(token)) {
        spans.add(TextSpan(
          text: token,
          style: const TextStyle(color: numberColor),
        ));
      }
      // كلمات مفتاحية ومعرفات
      else if (_isIdentifier(token)) {
        if (keywords.contains(token)) {
          spans.add(TextSpan(
            text: token,
            style: const TextStyle(color: keywordColor),
          ));
        } else if (token.isNotEmpty && _isCapitalized(token)) {
          spans.add(TextSpan(
            text: token,
            style: const TextStyle(color: functionColor),
          ));
        } else {
          spans.add(TextSpan(
            text: token,
            style: const TextStyle(color: defaultColor),
          ));
        }
      }
      // مسافات وأحرف أخرى
      else {
        spans.add(TextSpan(
          text: token,
          style: const TextStyle(color: defaultColor),
        ));
      }
    }

    return spans;
  }

  /// تحويل السطر إلى رموز (tokens) بسيطة.
  static List<String> _tokenize(String line) {
    final tokens = <String>[];
    final buffer = StringBuffer();
    bool inString = false;
    String stringChar = '';

    for (int i = 0; i < line.length; i++) {
      final char = line[i];

      // بداية أو نهاية سلسلة نصية
      if ((char == '"' || char == "'") && (i == 0 || line[i - 1] != '\\')) {
        if (inString && char == stringChar) {
          buffer.write(char);
          tokens.add(buffer.toString());
          buffer.clear();
          inString = false;
        } else if (!inString) {
          if (buffer.isNotEmpty) {
            tokens.add(buffer.toString());
            buffer.clear();
          }
          buffer.write(char);
          inString = true;
          stringChar = char;
        } else {
          buffer.write(char);
        }
      }
      // بداية تعليق
      else if (!inString && i + 1 < line.length && char == '/' && line[i + 1] == '/') {
        if (buffer.isNotEmpty) {
          tokens.add(buffer.toString());
          buffer.clear();
        }
        buffer.write(line.substring(i));
        break;
      }
      // مسافات
      else if (!inString && char == ' ') {
        if (buffer.isNotEmpty) {
          tokens.add(buffer.toString());
          buffer.clear();
        }
        tokens.add(' ');
      }
      // فواصل وأقواس
      else if (!inString && _isPunctuation(char)) {
        if (buffer.isNotEmpty) {
          tokens.add(buffer.toString());
          buffer.clear();
        }
        tokens.add(char);
      }
      // أحرف عادية
      else {
        buffer.write(char);
      }
    }

    if (buffer.isNotEmpty) {
      tokens.add(buffer.toString());
    }

    return tokens;
  }

  /// التحقق من أن النص رقم.
  static bool _isNumber(String text) {
    if (text.isEmpty) return false;
    return double.tryParse(text) != null || int.tryParse(text) != null;
  }

  /// التحقق من أن النص معرف (يبدأ بحرف أو شرطة سفلية).
  static bool _isIdentifier(String text) {
    if (text.isEmpty) return false;
    final first = text.codeUnitAt(0);
    return (first >= 65 && first <= 90) || // A-Z
        (first >= 97 && first <= 122) || // a-z
        first == 95; // _
  }

  /// التحقق من أن النص يبدأ بحرف كبير.
  static bool _isCapitalized(String text) {
    if (text.isEmpty) return false;
    final first = text.codeUnitAt(0);
    return first >= 65 && first <= 90; // A-Z
  }

  /// التحقق من أن الحرف علامة ترقيم.
  static bool _isPunctuation(String char) {
    const punctuation = '(){}[];,.<>=+-*/%&|!?:';
    return punctuation.contains(char);
  }
}