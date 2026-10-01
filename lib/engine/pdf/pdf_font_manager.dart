import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:lecture_formater/core/config/app_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// ============================================================================
// PdfFontBundle
//
// خاص بخط المستند العادي:
// Cairo / Tajawal
// ============================================================================

class PdfFontBundle {
  /// جميع أوزان عائلة الخط التي تم تحميلها.
  final Map<int, pw.Font> fonts;

  /// خط احتياطي للرموز والحروف غير الموجودة في الخط الأساسي.

  const PdfFontBundle({required this.fonts});

  // ============================================================
  // الحصول على خط بوزن معين
  // ============================================================

  pw.Font fontForWeight(int weight) {
    final exact = fonts[weight];

    if (exact != null) {
      return exact;
    }

    if (fonts.isEmpty) {
      return pw.Font.helvetica();
    }

    int closestWeight = fonts.keys.first;

    int smallestDifference = (closestWeight - weight).abs();

    for (final availableWeight in fonts.keys) {
      final difference = (availableWeight - weight).abs();

      if (difference < smallestDifference) {
        smallestDifference = difference;
        closestWeight = availableWeight;
      }
    }

    return fonts[closestWeight]!;
  }

  // ============================================================
  // الأوزان الشائعة
  // ============================================================

  pw.Font get regular {
    return fontForWeight(400);
  }

  pw.Font get medium {
    return fontForWeight(500);
  }

  pw.Font get semiBold {
    return fontForWeight(600);
  }

  pw.Font get bold {
    return fontForWeight(700);
  }

  pw.Font get extraBold {
    return fontForWeight(800);
  }

  pw.Font get black {
    return fontForWeight(900);
  }

  // ============================================================
  // إنشاء Theme للـ PDF
  // ============================================================

  pw.ThemeData toPdfTheme({
    required int fontWeight,
    required PdfColor textColor,
    required double baseFontSize,
  }) {
    final baseFont = fontForWeight(fontWeight);

    final boldFont = fontForWeight(700);

    return pw.ThemeData.withFont(
      base: baseFont,
      bold: boldFont,
      fontFallback: [regular],
    ).copyWith(
      defaultTextStyle: pw.TextStyle(
        font: baseFont,
        fontSize: baseFontSize,
        color: textColor,
        // fontFallback: fontFallback,
      ),

      paragraphStyle: pw.TextStyle(
        font: baseFont,
        fontSize: baseFontSize,
        color: textColor,
        lineSpacing: 5,
        // fontFallback: fontFallback,
      ),

      tableCell: pw.TextStyle(
        font: baseFont,
        fontSize: baseFontSize,
        color: textColor,
        //    fontFallback: fontFallback,
      ),

      tableHeader: pw.TextStyle(
        font: boldFont,
        fontSize: baseFontSize,
        color: textColor,
        // fontFallback: fontFallback,
      ),
    );
  }
}

// ============================================================================
// PdfCodeFontBundle
//
// خاص بالكود فقط.
// FiraCode ثابت ولا علاقة له بخط المستند أو وزنه.
// ============================================================================

class PdfCodeFontBundle {
  final pw.Font regular;
  final pw.Font bold;

  const PdfCodeFontBundle({required this.regular, required this.bold});
}

// ============================================================================
// PdfFontManager
// ============================================================================

class PdfFontManager {
  PdfFontManager._();

  // ============================================================
  // Cache للخطوط العادية
  // ============================================================

  static final Map<String, PdfFontBundle> _cache = {};

  // ============================================================
  // Cache لـ FiraCode
  // ============================================================

  static PdfCodeFontBundle? _codeFontCache;

  // ============================================================
  // تحميل الخط الاحتياطي
  // ============================================================

  // static Future<pw.Font> _loadFallbackFont() async {
  //   try {
  //     final data = await rootBundle.load(
  //       'assets/fonts/Fallback/DejaVuSans.ttf',
  //     );

  //     return pw.Font.ttf(data);
  //   } catch (_) {
  //     return pw.Font.helvetica();
  //   }
  // }

  // ============================================================
  // تحميل عائلة الخط العادي
  // ============================================================

  static Future<PdfFontBundle> loadFonts(String fontFamily) async {
    final cached = _cache[fontFamily];

    if (cached != null) {
      return cached;
    }

    final family = AppFonts.getByName(fontFamily);
    final loadedFonts = <int, pw.Font>{};
    for (final entry in family.weights.entries) {
      final weight = entry.key;
      final assetPath = entry.value;

      try {
        final data = await rootBundle.load(assetPath);

        final font = pw.Font.ttf(data);

        loadedFonts[weight] = font;
      } catch (e, stack) {
        debugPrint('$stack');
      }
    }

    if (loadedFonts.isEmpty) {
      final fallback = PdfFontBundle(
        fonts: {400: pw.Font.helvetica(), 700: pw.Font.helveticaBold()},
      );

      _cache[fontFamily] = fallback;

      return fallback;
    }

    final bundle = PdfFontBundle(fonts: loadedFonts);

    _cache[fontFamily] = bundle;

    return bundle;
  }
  // ============================================================
  // تحميل FiraCode
  // ============================================================

  static Future<PdfCodeFontBundle> loadCodeFonts() async {
    final cached = _codeFontCache;

    if (cached != null) {
      return cached;
    }

    try {
      final regularData = await rootBundle.load(
        'assets/fonts/FiraCode/FiraCode-Regular.ttf',
      );

      final boldData = await rootBundle.load(
        'assets/fonts/FiraCode/FiraCode-Bold.ttf',
      );

      final regularFont = pw.Font.ttf(regularData);
      final boldFont = pw.Font.ttf(boldData);

      final bundle = PdfCodeFontBundle(regular: regularFont, bold: boldFont);

      _codeFontCache = bundle;

      return bundle;
    } catch (e) {
      final fallback = PdfCodeFontBundle(
        regular: pw.Font.helvetica(),
        bold: pw.Font.helveticaBold(),
      );

      _codeFontCache = fallback;

      return fallback;
    }
  }

  // ============================================================
  // حذف Cache الخطوط العادية
  // ============================================================

  static void clearCache() {
    _cache.clear();
  }

  // ============================================================
  // حذف Cache عائلة محددة
  // ============================================================

  static void removeFromCache(String fontFamily) {
    _cache.remove(fontFamily);
  }

  // ============================================================
  // حذف Cache الخاص بـ FiraCode
  // ============================================================

  static void clearCodeFontCache() {
    _codeFontCache = null;
  }

  // ============================================================
  // حذف جميع الخطوط
  // ============================================================

  static void clearAllCache() {
    _cache.clear();
    _codeFontCache = null;
  }
}
