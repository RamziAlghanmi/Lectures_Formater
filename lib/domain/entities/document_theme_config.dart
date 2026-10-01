enum TemplateType {
  modern,
  classic,
  university,
  minimal;

  static TemplateType fromString(String value) {
    return TemplateType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => TemplateType.modern,
    );
  }
}

/// أوزان الخط المتاحة.
/// القيم متوافقة مع نظام FontWeight القياسي:
///
/// 100 = Thin
/// 200 = ExtraLight
/// 300 = Light
/// 400 = Regular
/// 500 = Medium
/// 600 = SemiBold
/// 700 = Bold
/// 800 = ExtraBold
/// 900 = Black
enum DocumentFontWeight {
  thin(100),
  extraLight(200),
  light(300),
  regular(400),
  medium(500),
  semiBold(600),
  bold(700),
  extraBold(800),
  black(900);

  final int value;

  const DocumentFontWeight(this.value);

  // ============================================================
  // التحويل من int
  // ============================================================

  static DocumentFontWeight fromInt(int value) {
    return DocumentFontWeight.values.firstWhere(
      (weight) => weight.value == value,
      orElse: () => DocumentFontWeight.regular,
    );
  }

  // ============================================================
  // الاسم للعرض
  // ============================================================

  String get displayName {
    switch (this) {
      case DocumentFontWeight.thin:
        return 'Thin';

      case DocumentFontWeight.extraLight:
        return 'Extra Light';

      case DocumentFontWeight.light:
        return 'Light';

      case DocumentFontWeight.regular:
        return 'Regular';

      case DocumentFontWeight.medium:
        return 'Medium';

      case DocumentFontWeight.semiBold:
        return 'Semi Bold';

      case DocumentFontWeight.bold:
        return 'Bold';

      case DocumentFontWeight.extraBold:
        return 'Extra Bold';

      case DocumentFontWeight.black:
        return 'Black';
    }
  }
}

class DocumentThemeConfig {
  final int primaryColor;
  final int secondaryColor;
  final int surfaceColor;
  final int textColor;

  // ============================================================
  // الخط الأساسي للمستند
  // ============================================================

  final String fontFamily;

  /// وزن الخط الأساسي.
  ///
  /// مثال:
  /// 400 = Regular
  /// 500 = Medium
  /// 600 = SemiBold
  /// 700 = Bold
  /// 800 = ExtraBold
  /// 900 = Black
  final int fontWeight;

  // ============================================================
  // خط الأكواد
  // ============================================================

  final String codeFontFamily;

  /// وزن خط الأكواد.
  final int codeFontWeight;

  // ============================================================
  // حجم الخط
  // ============================================================

  final double baseFontSize;

  // ============================================================
  // نوع القالب
  // ============================================================

  final TemplateType templateType;

  const DocumentThemeConfig({
    this.primaryColor = 0xFF1E3A8A,
    this.secondaryColor = 0xFF0D9488,
    this.surfaceColor = 0xFFF8FAFC,
    this.textColor = 0xFF0F172A,

    // الخط الافتراضي
    this.fontFamily = 'Cairo',

    // Regular
    this.fontWeight = 400,

    // خط الأكواد
    this.codeFontFamily = 'FiraCode',

    // Regular
    this.codeFontWeight = 400,

    this.baseFontSize = 14,

    this.templateType = TemplateType.modern,
  });

  // ============================================================
  // الحصول على وزن الخط الأساسي كـ Enum
  // ============================================================

  DocumentFontWeight get fontWeightType {
    return DocumentFontWeight.fromInt(fontWeight);
  }

  // ============================================================
  // الحصول على وزن خط الأكواد كـ Enum
  // ============================================================

  DocumentFontWeight get codeFontWeightType {
    return DocumentFontWeight.fromInt(codeFontWeight);
  }

  // ============================================================
  // Copy With
  // ============================================================

  DocumentThemeConfig copyWith({
    int? primaryColor,
    int? secondaryColor,
    int? surfaceColor,
    int? textColor,

    String? fontFamily,
    int? fontWeight,

    String? codeFontFamily,
    int? codeFontWeight,

    double? baseFontSize,

    TemplateType? templateType,
  }) {
    return DocumentThemeConfig(
      primaryColor: primaryColor ?? this.primaryColor,

      secondaryColor: secondaryColor ?? this.secondaryColor,

      surfaceColor: surfaceColor ?? this.surfaceColor,

      textColor: textColor ?? this.textColor,

      fontFamily: fontFamily ?? this.fontFamily,

      fontWeight: fontWeight ?? this.fontWeight,

      codeFontFamily: codeFontFamily ?? this.codeFontFamily,

      codeFontWeight: codeFontWeight ?? this.codeFontWeight,

      baseFontSize: baseFontSize ?? this.baseFontSize,

      templateType: templateType ?? this.templateType,
    );
  }

  // ============================================================
  // JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'surfaceColor': surfaceColor,
      'textColor': textColor,

      'fontFamily': fontFamily,
      'fontWeight': fontWeight,

      'codeFontFamily': codeFontFamily,
      'codeFontWeight': codeFontWeight,

      'baseFontSize': baseFontSize,

      'templateType': templateType.name,
    };
  }

  // ============================================================
  // From JSON
  // ============================================================

  factory DocumentThemeConfig.fromJson(Map<String, dynamic> json) {
    return DocumentThemeConfig(
      primaryColor: json['primaryColor'] as int? ?? 0xFF1E3A8A,

      secondaryColor: json['secondaryColor'] as int? ?? 0xFF0D9488,

      surfaceColor: json['surfaceColor'] as int? ?? 0xFFF8FAFC,

      textColor: json['textColor'] as int? ?? 0xFF0F172A,

      // --------------------------------------------------------
      // الخط الأساسي
      // --------------------------------------------------------
      fontFamily: json['fontFamily'] as String? ?? 'Cairo',

      fontWeight: (json['fontWeight'] as num?)?.toInt() ?? 400,

      // --------------------------------------------------------
      // خط الأكواد
      // --------------------------------------------------------
      codeFontFamily: json['codeFontFamily'] as String? ?? 'FiraCode',

      codeFontWeight: (json['codeFontWeight'] as num?)?.toInt() ?? 400,

      // --------------------------------------------------------
      // حجم الخط
      // --------------------------------------------------------
      baseFontSize: (json['baseFontSize'] as num?)?.toDouble() ?? 14,

      // --------------------------------------------------------
      // القالب
      // --------------------------------------------------------
      templateType: json['templateType'] != null
          ? TemplateType.fromString(json['templateType'] as String)
          : TemplateType.modern,
    );
  }
}
