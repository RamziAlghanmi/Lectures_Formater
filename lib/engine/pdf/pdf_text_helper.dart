import 'package:pdf/widgets.dart' as pw;

class PdfTextHelper {
  const PdfTextHelper._();

  // فحص الحروف وعلامات الترقيم العربية (شاملة التشكيل والأرقام والرموز العربية)
  static final RegExp _arabicLettersRegex = RegExp(
    r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
  );

  // فحص الحروف اللاتينية القوية
  static final RegExp _latinLettersRegex = RegExp(r'[a-zA-Z]');

  static bool hasArabic(String text) => _arabicLettersRegex.hasMatch(text);
  static bool hasLatin(String text) => _latinLettersRegex.hasMatch(text);

  /// معالجة وتجهيز النص للرسم مع الحفاظ على الاتجاه وعلامات الترقيم والمسافات
  static pw.Widget buildText(
    String text, {
    required pw.TextStyle style,
    pw.TextStyle? latinStyle,
    required pw.Font fallbackFont,
    bool isRtl = true,
    pw.TextAlign? textAlign,
  }) {
    if (text.isEmpty) return pw.SizedBox();

    // تطبيع الياء الفارسية (إن كُتبت بالخطأ) إلى ياء عربية قياسية
    final normalized = text.replaceAll('\u06CC', '\u064A');

    // إذا كان النص لا يحتوي على أي حرف عربي (مثل خلايا الجداول البرمجية)
    // يُرسم باتجاه LTR حصراً لحماية الأقواس من الانعكاس

    final textHasArabic = hasArabic(normalized);
    final effectiveDirection = textHasArabic
        ? (isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr)
        : pw.TextDirection.ltr;
    final effectiveAlign =
        textAlign ?? (isRtl ? pw.TextAlign.right : pw.TextAlign.left);

    final spans = _buildSpans(
      normalized,
      baseStyle: style,
      latinStyle: latinStyle,
      fallbackFont: fallbackFont,
      isRtl: isRtl,
    );

    return pw.RichText(
      text: pw.TextSpan(children: spans),
      textAlign: effectiveAlign,
      textDirection: effectiveDirection,
    );
  }

  static List<pw.InlineSpan> _buildSpans(
    String text, {
    required pw.TextStyle baseStyle,
    pw.TextStyle? latinStyle,
    required pw.Font fallbackFont,
    required bool isRtl,
  }) {
    if (text.isEmpty) return [];

    final chunks = _segmentText(text, isRtl);

    return chunks.map((c) {
      String processedText = c.text;

      // في وضع LTR: تشكيل وعكس المقاطع العربية فقط مع عكس الأقواس هندسياً
      if (!isRtl && c.isArabic) {
        processedText = _reshapeArabicForLtr(c.text);
      }

      final selectedStyle = c.isArabic ? baseStyle : (latinStyle ?? baseStyle);

      return pw.TextSpan(
        text: processedText,
        style: selectedStyle.copyWith(fontFallback: [fallbackFont]),
      );
    }).toList();
  }

  /// تقسيم النص وتوزيع الرموز والمسافات بدقة BiDi هندسية
  static List<_TextChunk> _segmentText(String text, bool isRtl) {
    // نصوص إنجليزية أو برمجية خالصة: كتلة واحدة لا تُجزأ
    if (!hasArabic(text)) {
      return [_TextChunk(text: text, isArabic: false)];
    }

    final tokenRegex = RegExp(
      r'([a-zA-Z0-9_]+|[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]+|[^\s\w]+|\s+)',
      unicode: true,
    );
    final tokens = tokenRegex.allMatches(text).map((m) => m.group(0)!).toList();

    if (tokens.isEmpty) return [];

    final List<_IntermediateToken> classified = [];

    for (final t in tokens) {
      if (t.trim().isEmpty) {
        classified.add(_IntermediateToken(t, _TokenType.space));
      } else if (_arabicLettersRegex.hasMatch(t)) {
        classified.add(_IntermediateToken(t, _TokenType.arabic));
      } else if (_latinLettersRegex.hasMatch(t)) {
        classified.add(_IntermediateToken(t, _TokenType.latin));
      } else {
        classified.add(_IntermediateToken(t, _TokenType.neutral));
      }
    }

    // 1. حسم الرموز وعلامات الترقيم المحايدة مع حماية أقواس الإنجليزية
    for (int i = 0; i < classified.length; i++) {
      if (classified[i].type == _TokenType.neutral) {
        final tokenText = classified[i].text.trim();
        final prevLatin = _findPrevNonSpaceIsLatin(classified, i);
        final nextLatin = _findNextNonSpaceIsLatin(classified, i);

        final isClosingBracket =
            tokenText == ')' || tokenText == ']' || tokenText == '}';
        final isOpeningBracket =
            tokenText == '(' || tokenText == '[' || tokenText == '{';

        // إذا كان الرمز محاطاً بكلمتين إنجليزيتين من الطرفين (مثل user.name أو 10.5)
        if (prevLatin && nextLatin) {
          classified[i].type = _TokenType.latin;
        }
        // قوس إغلاق لتعبير إنجليزي مثل UPPER(s) أو (SQL)
        else if (isClosingBracket && prevLatin) {
          classified[i].type = _TokenType.latin;
        }
        // قوس فتح لتعبير إنجليزي مثل (SQL) أو (POSITION)
        else if (isOpeningBracket && nextLatin) {
          classified[i].type = _TokenType.latin;
        }
        // بقية علامات الترقيم (: ، . -) تتبع السياق العربي لمنع انعكاسها
        else if (isRtl) {
          classified[i].type = _TokenType.arabic;
        } else {
          final prevAr = _findPrevNonSpaceIsArabic(classified, i);
          final nextAr = _findNextNonSpaceIsArabic(classified, i);
          classified[i].type = (prevAr && nextAr)
              ? _TokenType.arabic
              : _TokenType.latin;
        }
      }
    }

    // 2. توزيع المسافات البينية لمنع ابتلاع المسافة بين اللغات
    for (int i = 0; i < classified.length; i++) {
      if (classified[i].type == _TokenType.space) {
        final prevType = i > 0 ? classified[i - 1].type : null;
        final nextType = i + 1 < classified.length
            ? classified[i + 1].type
            : null;

        if (isRtl) {
          if (nextType == _TokenType.arabic || prevType == _TokenType.arabic) {
            classified[i].type = _TokenType.arabic;
          } else {
            classified[i].type = _TokenType.latin;
          }
        } else {
          if (prevType == _TokenType.latin || nextType == _TokenType.latin) {
            classified[i].type = _TokenType.latin;
          } else {
            classified[i].type = _TokenType.arabic;
          }
        }
      }
    }

    // 3. دمج المقاطع المتتالية المتجانسة
    final List<_TextChunk> chunks = [];
    for (final item in classified) {
      final isAr = item.type == _TokenType.arabic;
      if (chunks.isNotEmpty && chunks.last.isArabic == isAr) {
        chunks.last.text += item.text;
      } else {
        chunks.add(_TextChunk(text: item.text, isArabic: isAr));
      }
    }

    return chunks;
  }

  static bool _findPrevNonSpaceIsLatin(
    List<_IntermediateToken> tokens,
    int index,
  ) {
    for (int i = index - 1; i >= 0; i--) {
      if (tokens[i].type == _TokenType.latin) return true;
      if (tokens[i].type == _TokenType.arabic) return false;
    }
    return false;
  }

  static bool _findNextNonSpaceIsLatin(
    List<_IntermediateToken> tokens,
    int index,
  ) {
    for (int i = index + 1; i < tokens.length; i++) {
      if (tokens[i].type == _TokenType.latin) return true;
      if (tokens[i].type == _TokenType.arabic) return false;
    }
    return false;
  }

  static bool _findPrevNonSpaceIsArabic(
    List<_IntermediateToken> tokens,
    int index,
  ) {
    for (int i = index - 1; i >= 0; i--) {
      if (tokens[i].type == _TokenType.arabic) return true;
      if (tokens[i].type == _TokenType.latin) return false;
    }
    return false;
  }

  static bool _findNextNonSpaceIsArabic(
    List<_IntermediateToken> tokens,
    int index,
  ) {
    for (int i = index + 1; i < tokens.length; i++) {
      if (tokens[i].type == _TokenType.arabic) return true;
      if (tokens[i].type == _TokenType.latin) return false;
    }
    return false;
  }

  /// تشكيل الحروف وعكس المقاطع العربية في LTR مع الحفاظ على المسافات والأقواس
  static String _reshapeArabicForLtr(String text) {
    if (text.isEmpty) return text;
    final leadingMatch = RegExp(r'^\s+').firstMatch(text);
    final trailingMatch = RegExp(r'\s+$').firstMatch(text);

    final leadingSpaces = leadingMatch?.group(0) ?? '';
    final trailingSpaces = trailingMatch?.group(0) ?? '';

    final trimmed = text.substring(
      leadingSpaces.length,
      text.length - trailingSpaces.length,
    );

    if (trimmed.isEmpty) return text;

    final runes = trimmed.runes.toList();
    final List<int> reshaped = [];

    for (int i = 0; i < runes.length; i++) {
      final cur = runes[i];

      // معالجة اللام ألف
      if (cur == 0x0644 && i + 1 < runes.length) {
        final next = runes[i + 1];
        final lamAlef = _getLamAlef(next, _canConnectBefore(runes, i));
        if (lamAlef != null) {
          reshaped.add(lamAlef);
          i++;
          continue;
        }
      }

      final forms = _arabicForms[cur];
      if (forms == null) {
        reshaped.add(_mirrorChar(cur));
        continue;
      }

      final prevConnects = _canConnectBefore(runes, i);
      final nextConnects = _canConnectAfter(runes, i);

      if (forms.length >= 4) {
        if (prevConnects && nextConnects) {
          reshaped.add(forms[3]); // Medial
        } else if (prevConnects) {
          reshaped.add(forms[1]); // Final
        } else if (nextConnects) {
          reshaped.add(forms[2]); // Initial
        } else {
          reshaped.add(forms[0]); // Isolated
        }
      } else if (forms.length == 2) {
        if (prevConnects) {
          reshaped.add(forms[1]); // Final
        } else {
          reshaped.add(forms[0]); // Isolated
        }
      } else if (forms.length == 1) {
        // حرف له شكل واحد فقط مثل همزة القطع المستقلة "ء"
        reshaped.add(forms[0]);
      }
    }

    return leadingSpaces +
        String.fromCharCodes(reshaped.reversed) +
        trailingSpaces;
  }

  static int _mirrorChar(int charCode) {
    switch (charCode) {
      case 0x0028:
        return 0x0029; // ( -> )
      case 0x0029:
        return 0x0028; // ) -> (
      case 0x005B:
        return 0x005D; // [ -> ]
      case 0x005D:
        return 0x005B; // ] -> [
      case 0x007B:
        return 0x007D; // { -> }
      case 0x007D:
        return 0x007B; // } -> {
      case 0x003C:
        return 0x003E; // < -> >
      case 0x003E:
        return 0x003C; // > -> <
      case 0x00AB:
        return 0x00BB; // « -> »
      case 0x00BB:
        return 0x00AB; // » -> «
      default:
        return charCode;
    }
  }

  static bool _isDiacritic(int rune) =>
      (rune >= 0x064B && rune <= 0x065F) || rune == 0x0670;

  static bool _canConnectBefore(List<int> runes, int index) {
    int prevIndex = index - 1;
    // تخطي الحركات التشكيلية للوصول إلى الحرف الفعلي السابق
    while (prevIndex >= 0 && _isDiacritic(runes[prevIndex])) {
      prevIndex--;
    }
    if (prevIndex < 0) return false;
    final prev = runes[prevIndex];
    if (prev == 0x0640) return true; // كشيدة
    final forms = _arabicForms[prev];
    return forms != null && forms.length == 4;
  }

  // static bool _canConnectAfter(List<int> runes, int index) {
  //   int nextIndex = index + 1;
  //   // تخطي الحركات التشكيلية للوصول إلى الحرف الفعلي التالي
  //   while (nextIndex < runes.length && _isDiacritic(runes[nextIndex])) {
  //     nextIndex++;
  //   }
  //   if (nextIndex >= runes.length) return false;
  //   final next = runes[nextIndex];
  //   if (next == 0x0640) return true;
  //   return _arabicForms.containsKey(next) && next != 0x0621;
  // }
  static bool _canConnectAfter(List<int> runes, int index) {
    int nextIndex = index + 1;

    while (nextIndex < runes.length && _isDiacritic(runes[nextIndex])) {
      nextIndex++;
    }

    if (nextIndex >= runes.length) return false;

    final next = runes[nextIndex];

    if (next == 0x0640) return true;

    final forms = _arabicForms[next];

    return forms != null && forms.length == 4;
  }

  static int? _getLamAlef(int alefCode, bool prevConnects) {
    switch (alefCode) {
      case 0x0622:
        return prevConnects ? 0xFEF6 : 0xFEF5;
      case 0x0623:
        return prevConnects ? 0xFEF8 : 0xFEF7;
      case 0x0625:
        return prevConnects ? 0xFEFA : 0xFEF9;
      case 0x0627:
        return prevConnects ? 0xFEFC : 0xFEFB;
      default:
        return null;
    }
  }

  static const Map<int, List<int>> _arabicForms = {
    0x0621: [0xFE80],
    0x0622: [0xFE81, 0xFE82],
    0x0623: [0xFE83, 0xFE84],
    0x0624: [0xFE85, 0xFE86],
    0x0625: [0xFE87, 0xFE88],
    0x0626: [0xFE89, 0xFE8A, 0xFE8B, 0xFE8C],
    0x0627: [0xFE8D, 0xFE8E],
    0x0628: [0xFE8F, 0xFE90, 0xFE91, 0xFE92],
    0x0629: [0xFE93, 0xFE94],
    0x062A: [0xFE95, 0xFE96, 0xFE97, 0xFE98],
    0x062B: [0xFE99, 0xFE9A, 0xFE9B, 0xFE9C],
    0x062C: [0xFE9D, 0xFE9E, 0xFE9F, 0xFEA0],
    0x062D: [0xFEA1, 0xFEA2, 0xFEA3, 0xFEA4],
    0x062E: [0xFEA5, 0xFEA6, 0xFEA7, 0xFEA8],
    0x062F: [0xFEA9, 0xFEAA],
    0x0630: [0xFEAB, 0xFEAC],
    0x0631: [0xFEAD, 0xFEAE],
    0x0632: [0xFEAF, 0xFEB0],
    0x0633: [0xFEB1, 0xFEB2, 0xFEB3, 0xFEB4],
    0x0634: [0xFEB5, 0xFEB6, 0xFEB7, 0xFEB8],
    0x0635: [0xFEB9, 0xFEBA, 0xFEBB, 0xFEBC],
    0x0636: [0xFEBD, 0xFEBE, 0xFEBF, 0xFEC0],
    0x0637: [0xFEC1, 0xFEC2, 0xFEC3, 0xFEC4],
    0x0638: [0xFEC5, 0xFEC6, 0xFEC7, 0xFEC8],
    0x0639: [0xFEC9, 0xFECA, 0xFECB, 0xFECC],
    0x063A: [0xFECD, 0xFECE, 0xFECF, 0xFED0],
    0x0641: [0xFED1, 0xFED2, 0xFED3, 0xFED4],
    0x0642: [0xFED5, 0xFED6, 0xFED7, 0xFED8],
    0x0643: [0xFED9, 0xFEDA, 0xFEDB, 0xFEDC],
    0x0644: [0xFEDD, 0xFEDE, 0xFEDF, 0xFEE0],
    0x0645: [0xFEE1, 0xFEE2, 0xFEE3, 0xFEE4],
    0x0646: [0xFEE5, 0xFEE6, 0xFEE7, 0xFEE8],
    0x0647: [0xFEE9, 0xFEEA, 0xFEEB, 0xFEEC],
    0x0648: [0xFEED, 0xFEEE],
    0x0649: [
      0x0649,
      0xFEF0,
    ], // الألف المقصورة المنفصلة = 0x0649 لتفادي نقص المحارف
    0x064A: [0x064A, 0xFEF2, 0xFEF3, 0xFEF4],

    //// الياء المنفصلة = 0x064A لتفادي خطأ U+FEF1 في خط Cairo
  };
}

enum _TokenType { arabic, latin, neutral, space }

class _IntermediateToken {
  String text;
  _TokenType type;

  _IntermediateToken(this.text, this.type);
}

class _TextChunk {
  String text;
  final bool isArabic;

  _TextChunk({required this.text, required this.isArabic});
}
