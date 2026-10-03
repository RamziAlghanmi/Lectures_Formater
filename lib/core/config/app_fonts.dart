class AppFontFamily {
  final String name;
  final String displayName;

  /// الوزن → مسار ملف الخط
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
  final Map<int, String> weights;

  const AppFontFamily({
    required this.name,
    required this.displayName,
    required this.weights,
  });

  List<int> get availableWeights {
    final result = weights.keys.toList();
    result.sort();
    return result;
  }

  bool hasWeight(int weight) {
    return weights.containsKey(weight);
  }

  String? assetForWeight(int weight) {
    return weights[weight];
  }
}

class AppFonts {
  AppFonts._();

  // ============================================================
  // Cairo
  // ============================================================

  static const cairo = AppFontFamily(
    name: 'Cairo',
    displayName: 'Cairo',

    weights: {
      200: 'assets/fonts/Cairo/Cairo-ExtraLight.ttf',
      300: 'assets/fonts/Cairo/Cairo-Light.ttf',
      400: 'assets/fonts/Cairo/Cairo-Regular.ttf',
      500: 'assets/fonts/Cairo/Cairo-Medium.ttf',
      600: 'assets/fonts/Cairo/Cairo-SemiBold.ttf',
      700: 'assets/fonts/Cairo/Cairo-Bold.ttf',
      800: 'assets/fonts/Cairo/Cairo-ExtraBold.ttf',
      900: 'assets/fonts/Cairo/Cairo-Black.ttf',
    },
  );

  // ============================================================
  // NotoNaskhArabic
  // ============================================================

  static const notoNaskhArabic = AppFontFamily(
    name: 'NotoNaskhArabic',
    displayName: 'Noto',

    weights: {
      400: 'assets/fonts/Noto_Naskh_Arabic/NotoNaskhArabic-Regular.ttf',
      500: 'assets/fonts/Noto_Naskh_Arabic/NotoNaskhArabic-Medium.ttf',
      600: 'assets/fonts/Noto_Naskh_Arabic/NotoNaskhArabic-SemiBold.ttf',
      700: 'assets/fonts/Noto_Naskh_Arabic/NotoNaskhArabic-Bold.ttf',
    },
  );

  // ============================================================
  // Tajawal
  // ============================================================

  static const tajawal = AppFontFamily(
    name: 'Tajawal',
    displayName: 'Tajawal',

    weights: {
      200: 'assets/fonts/Tajawal/Tajawal-ExtraLight.ttf',
      300: 'assets/fonts/Tajawal/Tajawal-Light.ttf',
      400: 'assets/fonts/Tajawal/Tajawal-Regular.ttf',
      500: 'assets/fonts/Tajawal/Tajawal-Medium.ttf',
      700: 'assets/fonts/Tajawal/Tajawal-Bold.ttf',
      800: 'assets/fonts/Tajawal/Tajawal-ExtraBold.ttf',
      900: 'assets/fonts/Tajawal/Tajawal-Black.ttf',
    },
  );

  // ============================================================
  // Amiri
  // ============================================================

  static const amiri = AppFontFamily(
    name: 'Amiri',
    displayName: 'Amiri',

    weights: {
      400: 'assets/fonts/Amiri/Amiri-Regular.ttf',
      700: 'assets/fonts/Amiri/Amiri-Bold.ttf',
    },
  );

  // ============================================================
  // جميع العائلات
  // ============================================================

  static const List<AppFontFamily> all = [
    cairo,
    notoNaskhArabic,
    amiri,
    tajawal,
  ];

  // ============================================================
  // البحث عن عائلة
  // ============================================================

  static AppFontFamily getByName(String name) {
    return all.firstWhere((font) => font.name == name, orElse: () => cairo);
  }
}
