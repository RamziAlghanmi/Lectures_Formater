import 'dart:convert';

import 'package:lecture_formater/domain/entities/document_theme_config.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../domain/entities/block_node.dart';
import '../pdf_font_manager.dart';
import '../pdf_text_helper.dart';

class PdfTableWidget extends pw.StatelessWidget {
  final BlockNode node;
  final PdfFontBundle fontBundle;
  final PdfColor primaryColor;
  final double baseFontSize;
  final DocumentThemeConfig theme;
  final PdfCodeFontBundle codeFontBundle;

  PdfTableWidget({
    required this.node,
    required this.fontBundle,
    required this.primaryColor,
    required this.baseFontSize,
    required this.theme,
    required this.codeFontBundle,
  });

  @override
  bool get canSpan => true;

  @override
  pw.Widget build(pw.Context context) {
    final isRtl = (node.layoutRules.textDirection ?? 'rtl') != 'ltr';
    final alignment = isRtl
        ? pw.Alignment.centerRight
        : pw.Alignment.centerLeft;

    final headers = _parseHeaders(node.fields['headers']);
    final rowsData = _parseRows(node.fields['rows']);
    final tableFontSize = baseFontSize * 0.88;
    const borderColor = PdfColor.fromInt(0xFFCBD5E1);
    const alternateRowColor = PdfColor.fromInt(0xFFF8FAFC);
    const headerTextColor = PdfColors.white;
    // حساب عدد الأعمدة الكلي
    int columnCount = headers.length;
    for (final row in rowsData) {
      if (row.length > columnCount) {
        columnCount = row.length;
      }
    }

    if (columnCount == 0) {
      return pw.SizedBox();
    }

    final tableRows = <pw.TableRow>[];

    // ============================================================
    // 1. ترويسة الجدول (مع تكرارها تلقائياً عند الانتقال لصفحة جديدة)
    // ============================================================
    if (headers.isNotEmpty) {
      final headerCells = List.generate(columnCount, (colIdx) {
        final text = colIdx < headers.length ? headers[colIdx] : '';

        return pw.Container(
          padding: const pw.EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 6.0,
          ),
          alignment: alignment,
          child: PdfTextHelper.buildText(
            fallbackFont: codeFontBundle.bold,
            text,
            style: pw.TextStyle(
              font: fontBundle.semiBold,
              fontSize: tableFontSize,
              color: headerTextColor,
            ),
            isRtl: isRtl,
          ),
        );
      });

      tableRows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(color: primaryColor),
          repeat: true, // يكرر الترويسة في رأس كل صفحة جديدة ينتقل إليها الجدول
          children: isRtl ? headerCells.reversed.toList() : headerCells,
        ),
      );
    }

    // ============================================================
    // 2. صفوف البيانات (تتدفق صفاً تلو الآخر عبر الصفحات دون انهيار)
    // ============================================================
    for (int i = 0; i < rowsData.length; i++) {
      final row = rowsData[i];
      final isEven = i % 2 == 0;

      final rowCells = List.generate(columnCount, (colIdx) {
        final cellText = colIdx < row.length ? row[colIdx] : '';

        return pw.Container(
          padding: const pw.EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 5.5,
          ),
          alignment: alignment,
          child: PdfTextHelper.buildText(
            fallbackFont: codeFontBundle.regular,
            cellText,
            style: pw.TextStyle(
              font: fontBundle.fontForWeight(theme.fontWeight),
              fontSize: tableFontSize * 0.85,
              color: const PdfColor.fromInt(0xFF1E293B),
              lineSpacing: 1.3,
            ),
            isRtl: isRtl,
          ),
        );
      });

      tableRows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: isEven ? PdfColors.white : alternateRowColor,
          ),
          children: isRtl ? rowCells.reversed.toList() : rowCells,
        ),
      );
    }

    // ============================================================
    // 4. توزيع مساحات الأعمدة بنسب مرنة تضمن التفاف النصوص بدقة
    // ============================================================
    final Map<int, pw.TableColumnWidth> columnWidths = {};
    for (int i = 0; i < columnCount; i++) {
      columnWidths[i] = const pw.IntrinsicColumnWidth();
    }

    // ============================================================
    // 5. إرجاع الجدول كعنصر مباشر لتمكين الـ MultiPage من شطره
    // ============================================================
    return pw.Table(
      border: pw.TableBorder.all(color: borderColor, width: 0.6),
      columnWidths: columnWidths,
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      children: tableRows,
    );
  }

  // ==============================================================
  // Parse Headers (تم استبعاد الفاصلة العربية "،" نهائياً)
  // ==============================================================
  List<String> _parseHeaders(dynamic data) {
    if (data == null) return [];

    if (data is List) {
      return data
          .map((e) {
            if (e is Map) {
              return (e['column_name'] ?? '').toString().trim();
            }
            return e.toString().trim();
          })
          .where((e) => e.isNotEmpty)
          .toList();
    }

    if (data is String && data.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is List) {
          return _parseHeaders(decoded);
        }
      } catch (_) {}

      // الاعتماد فقط على خط الأنابيب | أو الفاصلة الإنجليزية , واستبعاد الفاصلة العربية ،
      final delimiter = data.contains('|') ? '|' : ',';

      return data
          .split(delimiter)
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return [];
  }

  // ==============================================================
  // Parse Rows (تم استبعاد الفاصلة العربية "،" نهائياً)
  // ==============================================================
  List<List<String>> _parseRows(dynamic data) {
    if (data == null) return [];

    if (data is List) {
      return data.map((item) {
        if (item is List) {
          return item.map((cell) => cell.toString().trim()).toList();
        }

        if (item is Map) {
          return item.values.map((v) => v.toString().trim()).toList();
        }

        final str = item.toString().trim();
        // الاعتماد فقط على | أو , واستبعاد ،
        final delimiter = str.contains('|') ? '|' : ',';

        return str.split(delimiter).map((c) => c.trim()).toList();
      }).toList();
    }

    if (data is String && data.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is List) {
          return _parseRows(decoded);
        }
      } catch (_) {}

      return data
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .map((line) {
            // الاعتماد فقط على | أو , واستبعاد ،
            final delimiter = line.contains('|') ? '|' : ',';

            return line.split(delimiter).map((cell) => cell.trim()).toList();
          })
          .toList();
    }

    return [];
  }
}
