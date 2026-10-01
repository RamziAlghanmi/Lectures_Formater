class Dimensions {
  const Dimensions._();

  /// Standard A4 Dimensions in PDF Points (1 pt = 1/72 inch).
  /// 210mm x 297mm converts to 595.28 x 841.89 points.
  static const double a4Width = 595.28;
  static const double a4Height = 841.89;

  /// Default Page Margins (in points).
  static const double defaultMarginTop = 40.0;
  static const double defaultMarginBottom = 40.0;
  static const double defaultMarginLeft = 36.0;
  static const double defaultMarginRight = 36.0;

  /// Header & Footer bounds.
  static const double headerHeight = 32.0;
  static const double footerHeight = 28.0;
  static const double headerContentSpacing = 16.0;
  static const double footerContentSpacing = 12.0;

  /// Usable content width for default A4 with default margins.
  static double get defaultContentWidth =>
      a4Width - (defaultMarginLeft + defaultMarginRight);

  /// Usable content height for default A4 with margins, headers, and footers.
  static double get defaultContentHeight =>
      a4Height -
      (defaultMarginTop +
          defaultMarginBottom +
          headerHeight +
          headerContentSpacing +
          footerHeight +
          footerContentSpacing);
}
