import 'package:lecture_formater/domain/entities/block_node.dart';
import 'package:lecture_formater/domain/entities/document_theme_config.dart';
import 'package:lecture_formater/engine/pdf/pdf_font_manager.dart';
import 'package:lecture_formater/engine/pdf/pdf_text_helper.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// 2. الكلاس الأساسي للمقارنة القابل للتجزئة والتدفق عبر الصفحات
class PdfComparisonWidget extends pw.StatelessWidget {
  final BlockNode node;
  final PdfFontBundle fonts;
  final DocumentThemeConfig theme;
  final PdfColor primaryColor;
  final PdfCodeFontBundle codeFontBundle;

  PdfComparisonWidget({
    required this.node,
    required this.fonts,
    required this.theme,
    required this.primaryColor,
    required this.codeFontBundle,
  });

  @override
  bool get canSpan => true;

  static pw.TextDirection _getDirection(BlockNode node) {
    return (node.layoutRules.textDirection ?? 'rtl') == 'ltr'
        ? pw.TextDirection.ltr
        : pw.TextDirection.rtl;
  }

  @override
  pw.Widget build(pw.Context context) {
    final aTitle = (node.fields['itemATitle'] as String?)?.trim() ?? 'A';
    final aContent = (node.fields['itemAContent'] as String?)?.trim() ?? '';
    final bTitle = (node.fields['itemBTitle'] as String?)?.trim() ?? 'B';
    final bContent = (node.fields['itemBContent'] as String?)?.trim() ?? '';

    final direction = _getDirection(node);
    final bool isRtl = direction == pw.TextDirection.rtl;

    final aLines = _extractLines(aContent);
    final bLines = _extractLines(bContent);

    final rowCount = aLines.length > bLines.length
        ? aLines.length
        : bLines.length;
    final totalRows = rowCount > 0 ? rowCount : 1;

    const borderColor = PdfColor.fromInt(0xFFCBD5E1);
    const alternateRowColor = PdfColor.fromInt(0xFFF8FAFC);
    const headerBgColor = PdfColor.fromInt(0xFFF1F5F9);

    final tableRows = <pw.TableRow>[];

    // ============================================================
    // 1. ترويسة المقارنة (تتكرر تلقائياً في رأس كل صفحة جديدة)
    // ============================================================
    final headerCellA = pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
      alignment: isRtl ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
      child: PdfTextHelper.buildText(
        fallbackFont: codeFontBundle.bold,
        aTitle,
        style: pw.TextStyle(
          font: fonts.bold,
          fontSize: theme.baseFontSize,
          color: primaryColor,
        ),
        isRtl: isRtl,
      ),
    );

    final headerCellB = pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
      alignment: isRtl ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
      child: PdfTextHelper.buildText(
        fallbackFont: codeFontBundle.bold,
        bTitle,
        style: pw.TextStyle(
          font: fonts.bold,
          fontSize: theme.baseFontSize,
          color: primaryColor,
        ),
        isRtl: isRtl,
      ),
    );

    tableRows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: headerBgColor),
        repeat: true, // يضمن عدم انفصال العناوين نهائياً عند بدء صفحة جديدة
        children: isRtl
            ? [headerCellB, headerCellA]
            : [headerCellA, headerCellB],
      ),
    );

    // ============================================================
    // 2. صفوف النقاط المتقابلة (تتدفق بحرية نقطة تلو الأخرى)
    // ============================================================
    for (int i = 0; i < totalRows; i++) {
      final textA = i < aLines.length ? aLines[i] : '';
      final textB = i < bLines.length ? bLines[i] : '';
      final isEven = i % 2 == 0;

      final cellA = _buildPointCell(text: textA, isRtl: isRtl);

      final cellB = _buildPointCell(text: textB, isRtl: isRtl);

      tableRows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: isEven ? PdfColors.white : alternateRowColor,
          ),
          children: isRtl ? [cellB, cellA] : [cellA, cellB],
        ),
      );
    }

    // ============================================================
    // 3. جدول المقارنة بدون أي حاويات خارجية مقيدة
    // ============================================================
    return pw.Directionality(
      textDirection: direction,
      child: pw.Table(
        border: const pw.TableBorder(
          top: pw.BorderSide(color: borderColor, width: 0.8),
          bottom: pw.BorderSide(color: borderColor, width: 0.8),
          left: pw.BorderSide(color: borderColor, width: 0.8),
          right: pw.BorderSide(color: borderColor, width: 0.8),
          verticalInside: pw.BorderSide(
            color: borderColor,
            width: 0.8,
          ), // فاصل وسطي بين الطرفين
          horizontalInside: pw.BorderSide(
            color: PdfColor.fromInt(0xFFE2E8F0),
            width: 0.4,
          ),
        ),
        columnWidths: const {
          0: pw.FlexColumnWidth(1.0),
          1: pw.FlexColumnWidth(1.0),
        },
        defaultVerticalAlignment: pw.TableCellVerticalAlignment.top,
        children: tableRows,
      ),
    );
  }

  pw.Widget _buildPointCell({required String text, required bool isRtl}) {
    if (text.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: pw.SizedBox(),
      );
    }

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Padding(
            padding: pw.EdgeInsets.only(
              left: isRtl ? 5.0 : 0.0,
              right: isRtl ? 0.0 : 5.0,
              top: 1.0,
            ),
            child: pw.Text(
              '•',
              style: pw.TextStyle(
                font: fonts.fontForWeight(theme.fontWeight),
                fontSize: theme.baseFontSize * 0.95,
                color: primaryColor,
              ),
            ),
          ),
          pw.Expanded(
            child: PdfTextHelper.buildText(
              fallbackFont: codeFontBundle.regular,
              text,
              style: pw.TextStyle(
                font: fonts.fontForWeight(theme.fontWeight),
                fontSize: theme.baseFontSize * 0.9,
                color: const PdfColor.fromInt(0xFF334155),
                lineSpacing: 1.35,
              ),
              isRtl: isRtl,
            ),
          ),
        ],
      ),
    );
  }

  List<String> _extractLines(String content) {
    if (content.trim().isEmpty) return [];

    final rawLines = content
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final List<String> result = [];
    for (final line in rawLines) {
      final clean = line.replaceFirst(RegExp(r'^[•\-\*]\s*'), '').trim();
      if (clean.isEmpty) continue;

      // تجزئة النقاط التفسيرية فائقة الطول لمنع تجاوز الصفحة الواحدة
      if (clean.length <= 350) {
        result.add(clean);
      } else {
        final words = clean.split(' ');
        final buffer = StringBuffer();
        for (final word in words) {
          if (buffer.length + word.length > 300) {
            if (buffer.isNotEmpty) {
              result.add(buffer.toString().trim());
              buffer.clear();
            }
          }
          buffer.write('$word ');
        }
        if (buffer.isNotEmpty) {
          result.add(buffer.toString().trim());
        }
      }
    }

    return result;
  }
}
