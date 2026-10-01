import '../../core/constants/dimensions.dart';

enum PageSizePreset {
  a4,
  letter;

  double get width => switch (this) {
    PageSizePreset.a4 => Dimensions.a4Width,
    PageSizePreset.letter => 612.0,
  };

  double get height => switch (this) {
    PageSizePreset.a4 => Dimensions.a4Height,
    PageSizePreset.letter => 792.0,
  };
}

enum PageOrientation { portrait, landscape }

class DocumentMargins {
  final double top;
  final double bottom;
  final double left;
  final double right;

  const DocumentMargins({
    this.top = Dimensions.defaultMarginTop,
    this.bottom = Dimensions.defaultMarginBottom,
    this.left = Dimensions.defaultMarginLeft,
    this.right = Dimensions.defaultMarginRight,
  });

  DocumentMargins copyWith({
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    return DocumentMargins(
      top: top ?? this.top,
      bottom: bottom ?? this.bottom,
      left: left ?? this.left,
      right: right ?? this.right,
    );
  }

  Map<String, dynamic> toJson() => {
    'top': top,
    'bottom': bottom,
    'left': left,
    'right': right,
  };

  factory DocumentMargins.fromJson(
    Map<String, dynamic> json,
  ) => DocumentMargins(
    top: (json['top'] as num?)?.toDouble() ?? Dimensions.defaultMarginTop,
    bottom:
        (json['bottom'] as num?)?.toDouble() ?? Dimensions.defaultMarginBottom,
    left: (json['left'] as num?)?.toDouble() ?? Dimensions.defaultMarginLeft,
    right: (json['right'] as num?)?.toDouble() ?? Dimensions.defaultMarginRight,
  );
}

class DocumentSettings {
  final PageSizePreset pageSizePreset;
  final PageOrientation orientation;
  final DocumentMargins margins;
  final bool isRtl;
  final bool showHeader;
  final bool showFooter;
  final String pageNumberFormat;
  final String customHeaderText;
  final String customFooterText;

  const DocumentSettings({
    this.pageSizePreset = PageSizePreset.a4,
    this.orientation = PageOrientation.portrait,
    this.margins = const DocumentMargins(),
    this.isRtl = true,
    this.showHeader = true,
    this.showFooter = true,
    this.pageNumberFormat = 'صفحة {current} من {total}',
    this.customHeaderText = '',
    this.customFooterText = '',
  });

  double get pageWidth => orientation == PageOrientation.portrait
      ? pageSizePreset.width
      : pageSizePreset.height;

  double get pageHeight => orientation == PageOrientation.portrait
      ? pageSizePreset.height
      : pageSizePreset.width;

  double get contentWidth => pageWidth - (margins.left + margins.right);

  double get contentHeight =>
      pageHeight -
      (margins.top +
          margins.bottom +
          (showHeader
              ? Dimensions.headerHeight + Dimensions.headerContentSpacing
              : 0) +
          (showFooter
              ? Dimensions.footerHeight + Dimensions.footerContentSpacing
              : 0));

  DocumentSettings copyWith({
    PageSizePreset? pageSizePreset,
    PageOrientation? orientation,
    DocumentMargins? margins,
    bool? isRtl,
    bool? showHeader,
    bool? showFooter,
    String? pageNumberFormat,
    String? customHeaderText,
    String? customFooterText,
  }) {
    return DocumentSettings(
      pageSizePreset: pageSizePreset ?? this.pageSizePreset,
      orientation: orientation ?? this.orientation,
      margins: margins ?? this.margins,
      isRtl: isRtl ?? this.isRtl,
      showHeader: showHeader ?? this.showHeader,
      showFooter: showFooter ?? this.showFooter,
      pageNumberFormat: pageNumberFormat ?? this.pageNumberFormat,
      customHeaderText: customHeaderText ?? this.customHeaderText,
      customFooterText: customFooterText ?? this.customFooterText,
    );
  }

  Map<String, dynamic> toJson() => {
    'pageSizePreset': pageSizePreset.name,
    'orientation': orientation.name,
    'margins': margins.toJson(),
    'isRtl': isRtl,
    'showHeader': showHeader,
    'showFooter': showFooter,
    'pageNumberFormat': pageNumberFormat,
    'customHeaderText': customHeaderText,
    'customFooterText': customFooterText,
  };

  factory DocumentSettings.fromJson(Map<String, dynamic> json) =>
      DocumentSettings(
        pageSizePreset: PageSizePreset.values.firstWhere(
          (e) => e.name == json['pageSizePreset'],
          orElse: () => PageSizePreset.a4,
        ),
        orientation: PageOrientation.values.firstWhere(
          (e) => e.name == json['orientation'],
          orElse: () => PageOrientation.portrait,
        ),
        margins: json['margins'] != null
            ? DocumentMargins.fromJson(json['margins'] as Map<String, dynamic>)
            : const DocumentMargins(),
        isRtl: json['isRtl'] as bool? ?? true,
        showHeader: json['showHeader'] as bool? ?? true,
        showFooter: json['showFooter'] as bool? ?? true,
        pageNumberFormat:
            json['pageNumberFormat'] as String? ?? 'صفحة {current} من {total}',
        customHeaderText: json['customHeaderText'] as String? ?? '',
        customFooterText: json['customFooterText'] as String? ?? '',
      );
}
