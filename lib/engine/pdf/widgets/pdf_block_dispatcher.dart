import 'dart:convert';

import 'package:lecture_formater/engine/pdf/pdf_text_helper.dart';
import 'package:lecture_formater/engine/pdf/widgets/pdf_function_widget.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/constants/block_types.dart';
import '../../../domain/entities/block_node.dart';
import '../../../domain/entities/document_theme_config.dart';
import '../pdf_font_manager.dart';
import '../widgets/pdf_callout_widget.dart';
import '../widgets/pdf_code_widget.dart';
import '../widgets/pdf_table_widget.dart';

class PdfBlockDispatcher {
  const PdfBlockDispatcher._();

  static pw.TextDirection _getDirection(BlockNode node) {
    return (node.layoutRules.textDirection ?? 'rtl') == 'ltr'
        ? pw.TextDirection.ltr
        : pw.TextDirection.rtl;
  }

  /// توليد قائمة عناصر مفككة ومسطحة لضمان تدفق الصفحات بسلاسة في MultiPage
  static List<pw.Widget> dispatchList({
    required BlockNode node,
    required PdfFontBundle fontBundle,
    required DocumentThemeConfig themeConfig,
    required PdfCodeFontBundle codeFontBundle,
  }) {
    final primaryPdfColor = PdfColor.fromInt(themeConfig.primaryColor);

    switch (node.type) {
      case BlockTypes.heading:
        return _buildHeadingList(
          node,
          fontBundle,
          themeConfig,
          primaryPdfColor,
          codeFontBundle,
        );

      case BlockTypes.paragraph:
        return _buildParagraphList(
          node,
          fontBundle,
          themeConfig,
          codeFontBundle,
        );

      case BlockTypes.bulletList:
      case BlockTypes.numberedList:
        return _buildListItems(
          node,
          fontBundle,
          themeConfig,
          primaryPdfColor,
          codeFontBundle,
        );

      case BlockTypes.note:
      case BlockTypes.information:
      case BlockTypes.tip:
      case BlockTypes.warning:
      case BlockTypes.error:
      case BlockTypes.important:
      case BlockTypes.bestPractice:
        return [
          PdfCalloutWidget(
            codeFontBundle: codeFontBundle,
            node: node,
            theme: themeConfig,
            baseFontSize: themeConfig.baseFontSize,
            fonts: fontBundle,
          ),
        ];

      case BlockTypes.code:
      case BlockTypes.consoleOutput:
        return [
          PdfCodeWidget(
            node: node,
            fontBundle: fontBundle,
            baseFontSize: themeConfig.baseFontSize,
            codeFontBundle: codeFontBundle,
          ),
        ];

      case BlockTypes.table:
        return [
          PdfTableWidget(
            codeFontBundle: codeFontBundle,
            node: node,
            fontBundle: fontBundle,
            primaryColor: primaryPdfColor,
            baseFontSize: themeConfig.baseFontSize,
            theme: themeConfig,
          ),
        ];

      case BlockTypes.image:
        return _buildImageList(node, fontBundle, themeConfig, codeFontBundle);

      case BlockTypes.commonMistake:
        return [
          _buildCommonMistake(node, fontBundle, themeConfig, codeFontBundle),
        ];

      case BlockTypes.comparison:
        return [
          _buildComparison(
            node,
            fontBundle,
            themeConfig,
            primaryPdfColor,
            codeFontBundle,
          ),
        ];
      case BlockTypes.functionDoc:
        return [
          PdfFunctionWidget(
            node: node,
            theme: themeConfig,
            fonts: fontBundle,
            primaryColor: primaryPdfColor,
            baseFontSize: themeConfig.baseFontSize,
            codeFontBundle: codeFontBundle,
          ),
        ];
      default:
        return [_buildGenericFallback(node, fontBundle, themeConfig)];
    }
  }

  static pw.Widget dispatch({
    required BlockNode node,
    required PdfFontBundle fontBundle,
    required DocumentThemeConfig themeConfig,
    required PdfCodeFontBundle codeFontBundle,
  }) {
    final items = dispatchList(
      node: node,
      fontBundle: fontBundle,
      themeConfig: themeConfig,
      codeFontBundle: codeFontBundle,
    );
    if (items.length == 1) return items.first;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      mainAxisSize: pw.MainAxisSize.min,
      children: items,
    );
  }

  static List<pw.Widget> _buildHeadingList(
    BlockNode node,
    PdfFontBundle fonts,
    DocumentThemeConfig theme,
    PdfColor primaryColor,
    PdfCodeFontBundle codeFontBundle,
  ) {
    final direction = _getDirection(node);
    final bool isRtl = direction == pw.TextDirection.rtl;
    final text = (node.fields['text'] as String?)?.trim() ?? '';
    final level = node.fields['level'] as String? ?? 'h1';
    final fontSize = switch (level) {
      'h1' => theme.baseFontSize * 1.6,
      'h2' => theme.baseFontSize * 1.35,
      _ => theme.baseFontSize * 1.15,
    };

    return [
      pw.Directionality(
        textDirection: _getDirection(node),

        child: pw.Container(
          margin: pw.EdgeInsets.only(
            top: node.layoutRules.spaceBefore,
            bottom: node.layoutRules.spaceAfter,
          ),
          child: PdfTextHelper.buildText(
            fallbackFont: codeFontBundle.bold,
            text,
            style: pw.TextStyle(
              font: fonts.bold,
              fontSize: fontSize,
              //     fontFallback: fonts.fontFallback,
              color: const PdfColor.fromInt(0xFF0F172A),
            ),
            isRtl: isRtl,
          ),
        ),
      ),
    ];
  }

  static List<pw.Widget> _buildParagraphList(
    BlockNode node,
    PdfFontBundle fonts,
    DocumentThemeConfig theme,
    PdfCodeFontBundle codeFontBundle,
  ) {
    final title = (node.fields['title'] as String?)?.trim() ?? '';
    final content = (node.fields['content'] as String?)?.trim() ?? '';
    final fontSize =
        theme.baseFontSize * (node.style.fontSizeMultiplier ?? 1.0);
    final direction = _getDirection(node);
    final bool isRtl = direction == pw.TextDirection.rtl;
    final widgets = <pw.Widget>[];

    if (title.isNotEmpty) {
      widgets.add(
        pw.Directionality(
          textDirection: direction,
          child: pw.Padding(
            padding: pw.EdgeInsets.only(
              top: node.layoutRules.spaceBefore,
              bottom: 4.0,
              left: 8.0,
              right: 8.0,
            ),
            child: PdfTextHelper.buildText(
              fallbackFont: codeFontBundle.bold,
              title,
              style: pw.TextStyle(
                font: fonts.bold,
                fontSize: fontSize,
                //  fontFallback: fonts.fontFallback,
                color: const PdfColor.fromInt(0xFF0F172A),
              ),
              isRtl: isRtl,
            ),
          ),
        ),
      );
    }

    if (content.isNotEmpty) {
      widgets.add(
        pw.Directionality(
          textDirection: direction,
          child: pw.Padding(
            padding: pw.EdgeInsets.only(
              top: title.isEmpty ? node.layoutRules.spaceBefore : 0.0,
              bottom: node.layoutRules.spaceAfter,
              left: isRtl ? 0.0 : 24.0,
              right: isRtl ? 24.0 : 0.0,
            ),
            child: PdfTextHelper.buildText(
              fallbackFont: codeFontBundle.regular,
              content,
              style: pw.TextStyle(
                font: fonts.fontForWeight(theme.fontWeight),
                fontSize: fontSize,
                color: const PdfColor.fromInt(0xFF334155),
                lineSpacing: 2.0,
              ),
              isRtl: isRtl,
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  static List<pw.Widget> _buildListItems(
    BlockNode node,
    PdfFontBundle fonts,
    DocumentThemeConfig theme,
    PdfColor primaryColor,
    PdfCodeFontBundle codeFontBundle,
  ) {
    final title = (node.fields['title'] as String?)?.trim() ?? '';
    final itemsRaw = node.fields['items'];
    final items = itemsRaw is List ? itemsRaw : <dynamic>[];
    final isNumbered = node.type == BlockTypes.numberedList;
    final startingIndex = node.fields['startingIndex'] as int? ?? 1;
    final direction = _getDirection(node);
    final bool isRtl = direction == pw.TextDirection.rtl;

    final widgets = <pw.Widget>[];

    // عنوان القائمة
    if (title.isNotEmpty) {
      widgets.add(
        pw.Padding(
          padding: pw.EdgeInsets.only(
            top: node.layoutRules.spaceBefore,
            bottom: 6.0,
          ),
          child: PdfTextHelper.buildText(
            fallbackFont: codeFontBundle.bold,
            title,
            style: pw.TextStyle(
              font: fonts.bold,
              fontSize: theme.baseFontSize,
              color: primaryColor,
            ),
            isRtl: isRtl,
          ),
        ),
      );
    }

    // عناصر القائمة
    for (var idx = 0; idx < items.length; idx++) {
      final rawItem = items[idx];
      final itemText = rawItem is Map
          ? (rawItem['item_text'] ?? '').toString()
          : rawItem.toString();
      final number = startingIndex + idx;
      final isLast = idx == items.length - 1;

      widgets.add(
        pw.Directionality(
          textDirection: direction,
          child: pw.Padding(
            padding: pw.EdgeInsets.only(
              top: 2.0,
              bottom: isLast ? node.layoutRules.spaceAfter : 2.0,
              left: isRtl ? 0.0 : 16.0,
              right: isRtl ? 16.0 : 0.0,
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(
                  width: isNumbered ? 24.0 : 10.0,
                  child: pw.Text(
                    isNumbered ? (isRtl ? ' -$number' : '$number- ') : '•',
                    textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
                    textDirection: direction,
                    style: pw.TextStyle(
                      font: fonts.fontForWeight(theme.fontWeight),
                      fontSize: isNumbered
                          ? theme.baseFontSize
                          : theme.baseFontSize * 0.9,
                      color: primaryColor,
                    ),
                  ),
                ),
                pw.Expanded(
                  child: PdfTextHelper.buildText(
                    fallbackFont: codeFontBundle.regular,
                    itemText,
                    style: pw.TextStyle(
                      font: fonts.fontForWeight(theme.fontWeight),
                      fontSize: theme.baseFontSize,
                      color: const PdfColor.fromInt(0xFF334155),
                      lineSpacing: 1.6,
                    ),
                    isRtl: isRtl,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  static List<pw.Widget> _buildImageList(
    BlockNode node,
    PdfFontBundle fonts,
    DocumentThemeConfig theme,
    PdfCodeFontBundle codeFontBundle,
  ) {
    final base64Str = node.fields['bytesBase64'] as String? ?? '';
    final caption = (node.fields['caption'] as String?)?.trim() ?? '';
    final direction = _getDirection(node);

    pw.Widget imageWidget;
    try {
      if (base64Str.isNotEmpty) {
        final cleanBase64 = base64Str.contains(',')
            ? base64Str.split(',').last
            : base64Str;
        final imageBytes = base64Decode(cleanBase64.trim());
        final pdfImage = pw.MemoryImage(imageBytes);
        imageWidget = pw.Image(pdfImage, fit: pw.BoxFit.contain);
      } else {
        imageWidget = pw.Container(
          height: 100,
          color: const PdfColor.fromInt(0xFFE2E8F0),
          child: pw.Center(
            child: pw.Text(
              'صورة مفقودة',
              style: pw.TextStyle(
                font: fonts.fontForWeight(theme.fontWeight),
                fontSize: 10.0,
              ),
            ),
          ),
        );
      }
    } catch (_) {
      imageWidget = pw.Container(
        height: 100,
        color: const PdfColor.fromInt(0xFFFEE2E2),
        child: pw.Center(
          child: pw.Text(
            'تعذر تحميل بيانات الصورة',
            style: pw.TextStyle(
              font: fonts.fontForWeight(theme.fontWeight),
              fontSize: 9.0,
            ),
          ),
        ),
      );
    }

    return [
      pw.Directionality(
        textDirection: direction,
        child: pw.Container(
          margin: pw.EdgeInsets.only(
            top: node.layoutRules.spaceBefore,
            bottom: node.layoutRules.spaceAfter,
          ),
          alignment: pw.Alignment.center,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              imageWidget,
              if (caption.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 4.0),
                  child: pw.Text(
                    caption,
                    style: pw.TextStyle(
                      font: fonts.fontForWeight(theme.fontWeight),
                      fontSize: theme.baseFontSize * 0.85,
                      color: const PdfColor.fromInt(0xFF64748B),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ];
  }

  static pw.Widget _buildCommonMistake(
    BlockNode node,
    PdfFontBundle fonts,
    DocumentThemeConfig theme,
    PdfCodeFontBundle codeFontBundle,
  ) {
    final mistake = (node.fields['mistake'] as String?)?.trim() ?? '';
    final correction = (node.fields['correction'] as String?)?.trim() ?? '';
    final direction = _getDirection(node);

    return pw.Directionality(
      textDirection: direction,
      child: pw.Container(
        margin: pw.EdgeInsets.only(
          top: node.layoutRules.spaceBefore,
          bottom: node.layoutRules.spaceAfter,
        ),
        padding: const pw.EdgeInsets.all(10.0),
        decoration: pw.BoxDecoration(
          color: const PdfColor.fromInt(0xFFF8FAFC),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4.0)),
          border: pw.Border.all(
            color: const PdfColor.fromInt(0xFFCBD5E1),
            width: 0.6,
          ),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'الخطأ: ',
                  style: pw.TextStyle(
                    font: fonts.bold,
                    fontSize: theme.baseFontSize,
                    color: const PdfColor.fromInt(0xFFDC2626),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    mistake,
                    style: pw.TextStyle(
                      font: fonts.fontForWeight(theme.fontWeight),
                      fontSize: theme.baseFontSize,
                      color: const PdfColor.fromInt(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 6.0),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'الصواب: ',
                  style: pw.TextStyle(
                    font: fonts.bold,
                    fontSize: theme.baseFontSize,
                    color: const PdfColor.fromInt(0xFF16A34A),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    correction,
                    style: pw.TextStyle(
                      font: fonts.fontForWeight(theme.fontWeight),
                      fontSize: theme.baseFontSize,
                      color: const PdfColor.fromInt(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildComparison(
    BlockNode node,
    PdfFontBundle fonts,
    DocumentThemeConfig theme,
    PdfColor primaryColor,
    PdfCodeFontBundle codeFontBundle,
  ) {
    final aTitle = (node.fields['itemATitle'] as String?)?.trim() ?? 'A';
    final aContent = (node.fields['itemAContent'] as String?)?.trim() ?? '';
    final bTitle = (node.fields['itemBTitle'] as String?)?.trim() ?? 'B';
    final bContent = (node.fields['itemBContent'] as String?)?.trim() ?? '';
    final direction = _getDirection(node);
    final bool isRtl = direction == pw.TextDirection.rtl;

    return pw.Directionality(
      textDirection: direction,
      child: pw.Container(
        margin: pw.EdgeInsets.only(
          top: node.layoutRules.spaceBefore,
          bottom: node.layoutRules.spaceAfter,
          left: 16.0,
          right: 16.0,
        ),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: _buildComparisonBox(
                title: aTitle,
                content: aContent,
                fonts: fonts,
                theme: theme,
                primaryColor: primaryColor,
                isRtl: isRtl,
                codeFontBundle: codeFontBundle,
              ),
            ),
            pw.SizedBox(width: 10.0),
            pw.Expanded(
              child: _buildComparisonBox(
                title: bTitle,
                content: bContent,
                fonts: fonts,
                theme: theme,
                primaryColor: primaryColor,
                isRtl: isRtl,
                codeFontBundle: codeFontBundle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildComparisonBox({
    required String title,
    required String content,
    required PdfFontBundle fonts,
    required DocumentThemeConfig theme,
    required PdfColor primaryColor,
    required bool isRtl,
    required PdfCodeFontBundle codeFontBundle,
  }) {
    final lines = content
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final isMultiLine = lines.length > 1;

    return pw.Container(
      padding: const pw.EdgeInsets.all(8.0),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFF8FAFC),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4.0)),
        border: pw.Border.all(
          color: const PdfColor.fromInt(0xFFCBD5E1),
          width: 0.6,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          if (title.isNotEmpty) ...[
            PdfTextHelper.buildText(
              fallbackFont: codeFontBundle.bold,
              title,
              style: pw.TextStyle(
                font: fonts.bold,
                fontSize: theme.baseFontSize,
                color: primaryColor,
              ),
              isRtl: isRtl,
            ),
            pw.SizedBox(height: 5.0),
          ],
          if (lines.isEmpty)
            pw.SizedBox()
          else if (!isMultiLine)
            PdfTextHelper.buildText(
              lines.first,
              fallbackFont: codeFontBundle.regular,
              style: pw.TextStyle(
                font: fonts.fontForWeight(theme.fontWeight),
                fontSize: theme.baseFontSize,
                color: const PdfColor.fromInt(0xFF334155),
                lineSpacing: 1.4,
              ),
              isRtl: isRtl,
            )
          else
            ...lines.map((line) {
              final cleanLine = line.replaceFirst(RegExp(r'^[•\-\*]\s*'), '');
              return pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Padding(
                      padding: pw.EdgeInsets.only(
                        left: isRtl ? 4.0 : 0.0,
                        right: isRtl ? 0.0 : 4.0,
                        top: 1.0,
                      ),
                      child: pw.Text(
                        '•',
                        style: pw.TextStyle(
                          font: fonts.fontForWeight(theme.fontWeight),
                          fontSize: theme.baseFontSize * 0.9,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      child: PdfTextHelper.buildText(
                        fallbackFont: codeFontBundle.regular,
                        cleanLine,
                        style: pw.TextStyle(
                          font: fonts.fontForWeight(theme.fontWeight),
                          fontSize: theme.baseFontSize * 0.9,
                          color: const PdfColor.fromInt(0xFF334155),
                          lineSpacing: 1.3,
                        ),
                        isRtl: isRtl,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  static pw.Widget _buildGenericFallback(
    BlockNode node,
    PdfFontBundle fonts,
    DocumentThemeConfig theme,
  ) {
    return pw.Directionality(
      textDirection: _getDirection(node),
      child: pw.Container(
        margin: const pw.EdgeInsets.symmetric(vertical: 4.0),
        child: pw.Text(
          node.title ?? node.type,
          style: pw.TextStyle(
            font: fonts.fontForWeight(theme.fontWeight),
            fontSize: theme.baseFontSize,
          ),
        ),
      ),
    );
  }
}
