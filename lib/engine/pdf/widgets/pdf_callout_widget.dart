import 'package:lecture_formater/domain/entities/document_theme_config.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/constants/block_types.dart';
import '../../../domain/entities/block_node.dart';
import '../pdf_font_manager.dart';
import '../pdf_text_helper.dart';

class PdfCalloutWidget extends pw.StatelessWidget {
  final BlockNode node;
  final double baseFontSize;
  final DocumentThemeConfig theme;
  final PdfFontBundle fonts;
  final PdfCodeFontBundle codeFontBundle;

  PdfCalloutWidget({
    required this.node,
    required this.theme,
    required this.baseFontSize,
    required this.fonts,
    required this.codeFontBundle,
  });

  @override
  pw.Widget build(pw.Context context) {
    final isRtl = (node.layoutRules.textDirection ?? 'rtl') != 'ltr';
    final textDirection = isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr;

    final rawTitle = (node.fields['title'] as String?)?.trim() ?? '';
    final title = rawTitle.isNotEmpty ? rawTitle : _getDefaultTitle(node.type);

    final rawContent = (node.fields['content'] as String?) ?? '';
    final cleanContent = rawContent
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .trim();

    final colors = _getCalloutColors(node.type);
    final lines = cleanContent
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    final isMultiLine = lines.length > 1;

    final rows = <pw.TableRow>[];

    // 1. عنوان الصندوق
    if (title.isNotEmpty) {
      rows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: colors.backgroundColor,
            border: pw.Border(
              top: pw.BorderSide(color: colors.borderColor, width: 0.6),
              right: isRtl
                  ? pw.BorderSide(color: colors.accentColor, width: 3.5)
                  : pw.BorderSide(color: colors.borderColor, width: 0.6),
              left: isRtl
                  ? pw.BorderSide(color: colors.borderColor, width: 0.6)
                  : pw.BorderSide(color: colors.accentColor, width: 3.5),
            ),
          ),
          children: [
            pw.Directionality(
              textDirection: textDirection,
              child: pw.Padding(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 5.0,
                ),
                child: PdfTextHelper.buildText(
                  fallbackFont: codeFontBundle.bold,
                  title,
                  style: pw.TextStyle(
                    font: fonts.bold,
                    fontSize: baseFontSize,
                    color: colors.accentColor,
                  ),
                  isRtl: isRtl,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 2. محتوى الصندوق (نص فردي أو قائمة أسطر)
    if (!isMultiLine && lines.isNotEmpty) {
      final isFirst = title.isEmpty;
      rows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: colors.backgroundColor,
            border: pw.Border(
              top: isFirst
                  ? pw.BorderSide(color: colors.borderColor, width: 0.6)
                  : pw.BorderSide.none,
              bottom: pw.BorderSide(color: colors.borderColor, width: 0.6),
              right: isRtl
                  ? pw.BorderSide(color: colors.accentColor, width: 3.5)
                  : pw.BorderSide(color: colors.borderColor, width: 0.6),
              left: isRtl
                  ? pw.BorderSide(color: colors.borderColor, width: 0.6)
                  : pw.BorderSide(color: colors.accentColor, width: 3.5),
            ),
          ),
          children: [
            pw.Directionality(
              textDirection: textDirection,
              child: pw.Padding(
                padding: pw.EdgeInsets.only(
                  top: isFirst ? 6.0 : 2.0,
                  bottom: 6.0,
                  left: 16.0,
                  right: 16.0,
                ),
                child: PdfTextHelper.buildText(
                  fallbackFont: codeFontBundle.regular,
                  lines.first,
                  style: pw.TextStyle(
                    font: fonts.fontForWeight(theme.fontWeight),
                    fontSize: baseFontSize * 0.95,
                    color: const PdfColor.fromInt(0xFF1E293B),
                    lineSpacing: 1.5,
                  ),
                  isRtl: isRtl,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      for (int i = 0; i < lines.length; i++) {
        final cleanLine = lines[i].replaceFirst(RegExp(r'^[•\-\*]\s*'), '');
        final isFirst = (i == 0) && title.isEmpty;
        final isLast = i == lines.length - 1;

        rows.add(
          pw.TableRow(
            decoration: pw.BoxDecoration(
              color: colors.backgroundColor,
              border: pw.Border(
                top: isFirst
                    ? pw.BorderSide(color: colors.borderColor, width: 0.6)
                    : pw.BorderSide.none,
                bottom: isLast
                    ? pw.BorderSide(color: colors.borderColor, width: 0.6)
                    : pw.BorderSide.none,
                right: isRtl
                    ? pw.BorderSide(color: colors.accentColor, width: 3.5)
                    : pw.BorderSide(color: colors.borderColor, width: 0.6),
                left: isRtl
                    ? pw.BorderSide(color: colors.borderColor, width: 0.6)
                    : pw.BorderSide(color: colors.accentColor, width: 3.5),
              ),
            ),
            children: [
              pw.Directionality(
                textDirection: textDirection,
                child: pw.Padding(
                  padding: pw.EdgeInsets.only(
                    top: isFirst ? 6.0 : 1.5,
                    bottom: isLast ? 6.0 : 1.5,
                    left: 12.0,
                    right: 12.0,
                  ),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(
                          top: 1.5,
                          left: 6.0,
                          right: 6.0,
                        ),
                        child: pw.Text(
                          '•',
                          style: pw.TextStyle(
                            font: fonts.fontForWeight(theme.fontWeight),
                            fontSize: baseFontSize * 0.9,
                            color: colors.accentColor,
                          ),
                        ),
                      ),
                      pw.Expanded(
                        child: PdfTextHelper.buildText(
                          fallbackFont: codeFontBundle.regular,
                          cleanLine,
                          style: pw.TextStyle(
                            font: fonts.fontForWeight(theme.fontWeight),
                            fontSize: baseFontSize,
                            color: const PdfColor.fromInt(0xFF1E293B),
                            lineSpacing: 1.4,
                          ),
                          isRtl: isRtl,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }

    return pw.Table(
      border: pw.TableBorder.symmetric(
        inside: pw.BorderSide.none,
        outside: pw.BorderSide.none,
      ),
      columnWidths: const {0: pw.FlexColumnWidth()},
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.top,
      children: rows,
    );
  }

  String _getDefaultTitle(String type) => switch (type) {
    BlockTypes.note => 'ملاحظة',
    BlockTypes.information => 'معلومة',
    BlockTypes.tip => 'نصيحة',
    BlockTypes.warning => 'تحذير',
    BlockTypes.error => 'خطأ برمجي',
    BlockTypes.important => 'هام جداً',
    BlockTypes.bestPractice => 'أفضل ممارسة',
    _ => 'تنبيه',
  };

  _CalloutColors _getCalloutColors(String type) => switch (type) {
    BlockTypes.tip || BlockTypes.bestPractice => const _CalloutColors(
      accentColor: PdfColor.fromInt(0xFF0D9488),
      backgroundColor: PdfColor.fromInt(0xFFF0FDFA),
      borderColor: PdfColor.fromInt(0xFFCCFBF1),
    ),
    BlockTypes.warning => const _CalloutColors(
      accentColor: PdfColor.fromInt(0xFFD97706),
      backgroundColor: PdfColor.fromInt(0xFFFFFBEB),
      borderColor: PdfColor.fromInt(0xFFFEF3C7),
    ),
    BlockTypes.error => const _CalloutColors(
      accentColor: PdfColor.fromInt(0xFFDC2626),
      backgroundColor: PdfColor.fromInt(0xFFFEF2F2),
      borderColor: PdfColor.fromInt(0xFFFEE2E2),
    ),
    BlockTypes.important => const _CalloutColors(
      accentColor: PdfColor.fromInt(0xFF7C3AED),
      backgroundColor: PdfColor.fromInt(0xFFF5F3FF),
      borderColor: PdfColor.fromInt(0xFFEDE9FE),
    ),
    _ => const _CalloutColors(
      accentColor: PdfColor.fromInt(0xFF2563EB),
      backgroundColor: PdfColor.fromInt(0xFFEFF6FF),
      borderColor: PdfColor.fromInt(0xFFDBEAFE),
    ),
  };
}

class _CalloutColors {
  final PdfColor accentColor;
  final PdfColor backgroundColor;
  final PdfColor borderColor;

  const _CalloutColors({
    required this.accentColor,
    required this.backgroundColor,
    required this.borderColor,
  });
}
