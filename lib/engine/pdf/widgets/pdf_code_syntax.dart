import 'package:lecture_formater/engine/pdf/pdf_text_helper.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfSyntaxHighlighter {
  const PdfSyntaxHighlighter._();

  static const Map<String, List<String>> _keywords = {
    'dart': [
      'if',
      'else',
      'for',
      'while',
      'return',
      'class',
      'void',
      'int',
      'double',
      'String',
      'bool',
      'true',
      'false',
      'null',
      'this',
      'super',
      'extends',
      'implements',
      'import',
      'export',
      'library',
      'part',
      'var',
      'final',
      'const',
      'new',
      'switch',
      'case',
      'break',
      'continue',
      'try',
      'catch',
      'finally',
      'throw',
      'async',
      'await',
      'late',
      'required',
      'enum',
      'typedef',
      'mixin',
      'with',
      'static',
      'override',
      'get',
      'set',
    ],
    'python': [
      'if',
      'elif',
      'else',
      'for',
      'while',
      'return',
      'def',
      'class',
      'import',
      'from',
      'as',
      'print',
      'True',
      'False',
      'None',
      'lambda',
      'try',
      'except',
      'finally',
      'raise',
      'with',
      'yield',
      'and',
      'or',
      'not',
      'self',
      'is',
      'in',
      'pass',
      'global',
      'nonlocal',
      'assert',
    ],
    'javascript': [
      'if',
      'else',
      'for',
      'while',
      'return',
      'function',
      'class',
      'var',
      'let',
      'const',
      'true',
      'false',
      'null',
      'undefined',
      'this',
      'super',
      'extends',
      'import',
      'export',
      'new',
      'switch',
      'case',
      'break',
      'continue',
      'try',
      'catch',
      'finally',
      'throw',
      'async',
      'await',
      'typeof',
      'instanceof',
      'of',
      'in',
      'default',
    ],
    'sql': [
      'SELECT',
      'FROM',
      'WHERE',
      'INSERT',
      'INTO',
      'UPDATE',
      'DELETE',
      'CREATE',
      'TABLE',
      'ALTER',
      'DROP',
      'JOIN',
      'LEFT',
      'RIGHT',
      'INNER',
      'OUTER',
      'GROUP',
      'BY',
      'ORDER',
      'HAVING',
      'LIMIT',
      'UNION',
      'AND',
      'OR',
      'NOT',
      'IS',
      'LIKE',
      'PRIMARY',
      'KEY',
      'FOREIGN',
      'REFERENCES',
      'select',
      'from',
      'where',
      'insert',
      'into',
      'update',
      'delete',
      'create',
      'table',
      'alter',
      'drop',
      'join',
      'left',
      'right',
      'inner',
      'outer',
      'group',
      'by',
      'order',
      'having',
      'limit',
      'union',
      'and',
      'or',
      'not',
      'is',
      'like',
      'primary',
      'key',
      'foreign',
      'references',
    ],
  };

  static const PdfColor commentColor = PdfColor.fromInt(0xFF6A9955);
  static const PdfColor stringColor = PdfColor.fromInt(0xFFCE9178);
  static const PdfColor keywordColor = PdfColor.fromInt(0xFF569CD6);
  static const PdfColor functionColor = PdfColor.fromInt(0xFFDCDCAA);
  static const PdfColor numberColor = PdfColor.fromInt(0xFFB5CEA8);
  static const PdfColor defaultColor = PdfColor.fromInt(0xFFD4D4D4);

  static pw.Widget buildLineWidget(
    String line,
    String language, {
    required pw.Font codeFont,
    required pw.Font arabicFont,
    required double fontSize,
  }) {
    final expandedLine = line.replaceAll('\t', '    ').replaceAll('\r', '');
    final charWidth = fontSize * 0.60;

    if (expandedLine.isEmpty) {
      return pw.SizedBox(height: fontSize * 1.35);
    }

    final defaultCodeStyle = pw.TextStyle(
      font: codeFont,
      fontSize: fontSize,
      color: defaultColor,
    );
    final defaultArabicStyle = pw.TextStyle(
      font: arabicFont,
      fontSize: fontSize * 0.95,
      color: defaultColor,
    );

    final commentCodeStyle = pw.TextStyle(
      font: codeFont,
      fontSize: fontSize,
      color: commentColor,
    );
    final commentArabicStyle = pw.TextStyle(
      font: arabicFont,
      fontSize: fontSize * 0.95,
      color: commentColor,
    );

    final stringCodeStyle = pw.TextStyle(
      font: codeFont,
      fontSize: fontSize,
      color: stringColor,
    );
    final stringArabicStyle = pw.TextStyle(
      font: arabicFont,
      fontSize: fontSize * 1.1,
      color: stringColor,
    );
    // final describeArabicStyle = pw.TextStyle(
    //   font: arabicFont,
    //   fontSize: fontSize * 1.3,
    //   color: const PdfColor.fromInt(0xFFD4D4D4),
    // );

    final keywordStyle = pw.TextStyle(
      font: codeFont,
      fontSize: fontSize,
      color: keywordColor,
    );
    final functionStyle = pw.TextStyle(
      font: codeFont,
      fontSize: fontSize,
      color: functionColor,
    );
    final numberStyle = pw.TextStyle(
      font: codeFont,
      fontSize: fontSize,
      color: numberColor,
    );

    final trimmedLine = expandedLine.trim();

    // 1. معالجة السطور التي تمثل شرحاً أو نصاً عربياً كاملاً كوحدة واحدة
    // هذا يمنع تفكيك السطر إلى كلمات وعكسها بواسطة الـ Row
    if (PdfTextHelper.hasArabic(trimmedLine) &&
        !PdfTextHelper.hasLatin(trimmedLine)) {
      final leadingSpacesCount = expandedLine.indexOf(trimmedLine);
      final isComment =
          trimmedLine.startsWith('//') ||
          trimmedLine.startsWith('#') ||
          trimmedLine.startsWith('/*') ||
          trimmedLine.startsWith('--');

      final selectedStyle = isComment ? commentArabicStyle : defaultArabicStyle;

      return pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          if (leadingSpacesCount > 0)
            pw.SizedBox(width: leadingSpacesCount * charWidth),
          PdfTextHelper.buildText(
            fallbackFont: codeFont,
            trimmedLine,
            style: selectedStyle,
            latinStyle: defaultCodeStyle,
            isRtl: true,
          ),
        ],
      );
    }

    // 2. تحليل الأسطر البرمجية المشتركة
    final lang = language.toLowerCase();
    final keywordList = _keywords[lang] ?? _keywords['dart']!;
    final tokens = _tokenize(expandedLine);
    final widgets = <pw.Widget>[];

    for (final token in tokens) {
      if (token.isEmpty) continue;

      // الإزاحات والمسافات
      if (token.trim().isEmpty) {
        widgets.add(pw.SizedBox(width: token.length * charWidth));
        continue;
      }

      // التعليقات البرمجية
      if (token.startsWith('//') ||
          token.startsWith('#') ||
          token.startsWith('/*') ||
          token.startsWith('--')) {
        if (PdfTextHelper.hasArabic(token)) {
          widgets.add(
            PdfTextHelper.buildText(
              fallbackFont: codeFont,
              token,
              style: commentArabicStyle,
              latinStyle: commentCodeStyle,
              isRtl: true,
            ),
          );
        } else {
          widgets.add(pw.Text(token, style: commentCodeStyle));
        }
      }
      // النصوص الصريحة (Strings)
      else if (token.startsWith('"') ||
          token.startsWith("'") ||
          token.startsWith('`')) {
        if (PdfTextHelper.hasArabic(token)) {
          widgets.add(
            PdfTextHelper.buildText(
              fallbackFont: codeFont,
              token,
              style: stringArabicStyle,
              latinStyle: stringCodeStyle,
              isRtl: true,
            ),
          );
        } else {
          widgets.add(pw.Text(token, style: stringCodeStyle));
        }
      }
      // الأرقام
      else if (_isNumber(token)) {
        widgets.add(pw.Text(token, style: numberStyle));
      }
      // الكلمات المفتاحية
      else if (keywordList.contains(token)) {
        widgets.add(pw.Text(token, style: keywordStyle));
      }
      // أسماء الدوال والكلاسات
      else if (_isCapitalized(token)) {
        widgets.add(pw.Text(token, style: functionStyle));
      }
      // المتغيرات والنصوص العربية
      else if (PdfTextHelper.hasArabic(token)) {
        widgets.add(
          PdfTextHelper.buildText(
            fallbackFont: codeFont,
            token,
            style: defaultArabicStyle,
            latinStyle: defaultCodeStyle,
            isRtl: true,
          ),
        );
      }
      // الرموز والعمليات البرمجية
      else {
        widgets.add(pw.Text(token, style: defaultCodeStyle));
      }
    }

    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: widgets,
    );
  }

  static List<String> _tokenize(String line) {
    final tokens = <String>[];
    final buffer = StringBuffer();
    bool inString = false;
    String stringChar = '';

    for (int i = 0; i < line.length; i++) {
      final char = line[i];

      // سلاسل نصية
      if ((char == '"' || char == "'" || char == '`') &&
          (i == 0 || line[i - 1] != '\\')) {
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
      // تعليقات السطر الواحد
      else if (!inString &&
          ((i + 1 < line.length && char == '/' && line[i + 1] == '/') ||
              (i + 1 < line.length && char == '/' && line[i + 1] == '*') ||
              (i + 1 < line.length && char == '-' && line[i + 1] == '-') ||
              char == '#')) {
        if (buffer.isNotEmpty) {
          tokens.add(buffer.toString());
          buffer.clear();
        }
        tokens.add(line.substring(i));
        break;
      }
      // المسافات: الحفاظ على العبارات والجمل العربية كوحدة واحدة وعدم تفتيتها
      else if (!inString && char == ' ') {
        if (buffer.isNotEmpty && PdfTextHelper.hasArabic(buffer.toString())) {
          int j = i;
          while (j < line.length && line[j] == ' ') {
            j++;
          }
          // إذا كانت الكلمة التالية أيضاً عربية، يتم دمج المسافة والكلمة في نفس الـ Token
          if (j < line.length &&
              (PdfTextHelper.hasArabic(line[j]) ||
                  _isArabicFollower(line, j))) {
            buffer.write(line.substring(i, j));
            i = j - 1;
            continue;
          }
        }

        if (buffer.isNotEmpty) {
          tokens.add(buffer.toString());
          buffer.clear();
        }
        int j = i;
        while (j < line.length && line[j] == ' ') {
          j++;
        }
        tokens.add(line.substring(i, j));
        i = j - 1;
      }
      // الرموز البرمجية
      else if (!inString && _isPunctuation(char)) {
        if (buffer.isNotEmpty) {
          tokens.add(buffer.toString());
          buffer.clear();
        }
        tokens.add(char);
      }
      // الحروف والأرقام
      else {
        buffer.write(char);
      }
    }

    if (buffer.isNotEmpty) {
      tokens.add(buffer.toString());
    }

    return tokens;
  }

  static bool _isArabicFollower(String line, int startIndex) {
    for (int k = startIndex; k < line.length; k++) {
      if (line[k] == ' ') continue;
      if (PdfTextHelper.hasArabic(line[k])) return true;
      if (RegExp(r'[a-zA-Z]').hasMatch(line[k])) return false;
    }
    return false;
  }

  static bool _isNumber(String text) {
    if (text.isEmpty) return false;
    return RegExp(r'^[0-9]+(\.[0-9]+)?$').hasMatch(text);
  }

  static bool _isCapitalized(String text) {
    if (text.isEmpty) return false;
    final first = text.codeUnitAt(0);
    return first >= 65 && first <= 90;
  }

  static bool _isPunctuation(String char) {
    const punctuation = '(){}[];,.<>=+-*/%&|!?:';
    return punctuation.contains(char);
  }
}
