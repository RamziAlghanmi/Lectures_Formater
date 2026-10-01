import 'dart:convert';

import 'package:lecture_formater/domain/entities/document_theme_config.dart';
import 'package:lecture_formater/engine/pdf/widgets/pdf_code_syntax.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../domain/entities/block_node.dart';
import '../pdf_font_manager.dart';
import '../pdf_text_helper.dart';

class PdfFunctionWidget extends pw.StatelessWidget {
  final BlockNode node;
  final DocumentThemeConfig theme;
  final PdfFontBundle fonts;
  final PdfColor primaryColor;
  final double baseFontSize;
  final PdfCodeFontBundle codeFontBundle;

  PdfFunctionWidget({
    required this.node,
    required this.theme,
    required this.fonts,
    required this.primaryColor,
    required this.baseFontSize,
    required this.codeFontBundle,
  });

  @override
  pw.Widget build(pw.Context context) {
    final isRtl = (node.layoutRules.textDirection ?? 'rtl') != 'ltr';
    final textDirection = isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr;
    final alignment = isRtl
        ? pw.Alignment.centerRight
        : pw.Alignment.centerLeft;

    final name = (node.fields['name'] as String?)?.trim() ?? 'functionName';
    final returnType = (node.fields['returnType'] as String?)?.trim() ?? 'void';
    final signature =
        (node.fields['signature'] as String?)?.trim() ?? '$returnType $name()';
    final description = (node.fields['description'] as String?)?.trim() ?? '';
    final returnsDesc = (node.fields['returns'] as String?)?.trim() ?? '';
    final language = (node.fields['language'] as String?)?.trim() ?? 'dart';
    final parameters = _parseParameters(node.fields['parameters']);

    final example =
        (node.fields['example'] as String?)?.trim() ??
        (node.fields['exampleCode'] as String?)?.trim() ??
        (node.fields['code'] as String?)?.trim() ??
        '';

    const borderColor = PdfColor.fromInt(0xFFCBD5E1);
    const codeBgColor = PdfColor.fromInt(0xFF1E1E2E);
    const surfaceColor = PdfColor.fromInt(0xFFF8FAFC);
    final labelColor = primaryColor;

    final formattedSignature = signature.startsWith(returnType)
        ? signature.substring(returnType.length).trim()
        : signature;

    final exampleLines = example.isNotEmpty
        ? example.replaceAll('\r\n', '\n').replaceAll('\r', '\n').split('\n')
        : <String>[];

    return pw.Directionality(
      textDirection: textDirection,
      child: pw.Container(
        margin: pw.EdgeInsets.only(
          top: node.layoutRules.spaceBefore,
          bottom: node.layoutRules.spaceAfter,
          left: 16.0,
          right: 16.0,
        ),
        decoration: pw.BoxDecoration(
          color: surfaceColor,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6.0)),
          border: pw.Border.all(color: borderColor, width: 0.8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            // 1. شريط توقيع الدالة البرمجية
            pw.Directionality(
              textDirection: pw.TextDirection.ltr,
              child: pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                decoration: const pw.BoxDecoration(
                  color: codeBgColor,
                  borderRadius: pw.BorderRadius.only(
                    topLeft: pw.Radius.circular(5.2),
                    topRight: pw.Radius.circular(5.2),
                  ),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      returnType,
                      textDirection: pw.TextDirection.ltr,
                      style: pw.TextStyle(
                        font: codeFontBundle.regular,
                        fontSize: baseFontSize * 0.88,
                        color: const PdfColor.fromInt(0xFF89B4FA),
                      ),
                    ),
                    pw.SizedBox(width: 6.0),
                    pw.Expanded(
                      child: pw.Text(
                        formattedSignature,
                        textDirection: pw.TextDirection.ltr,
                        style: pw.TextStyle(
                          font: codeFontBundle.bold,
                          fontSize: baseFontSize * 0.88,
                          color: const PdfColor.fromInt(0xFFF9E2AF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. تفاصيل الدالة
            pw.Padding(
              padding: const pw.EdgeInsets.all(12.0),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  if (description.isNotEmpty) ...[
                    PdfTextHelper.buildText(
                      fallbackFont: codeFontBundle.regular,
                      description,
                      style: pw.TextStyle(
                        font: codeFontBundle.regular,
                        fontSize: baseFontSize * 0.92,
                        color: const PdfColor.fromInt(0xFF334155),
                        lineSpacing: 1.6,
                      ),
                      isRtl: isRtl,
                    ),
                    pw.SizedBox(height: 10.0),
                  ],

                  if (parameters.isNotEmpty) ...[
                    PdfTextHelper.buildText(
                      fallbackFont: codeFontBundle.regular,
                      isRtl ? 'المعاملات (Parameters):' : 'Parameters:',
                      style: pw.TextStyle(
                        font: fonts.bold,
                        fontSize: baseFontSize * 0.9,
                        color: labelColor,
                      ),
                      isRtl: isRtl,
                    ),
                    pw.SizedBox(height: 6.0),
                    _buildParametersTable(
                      parameters: parameters,
                      isRtl: isRtl,
                      alignment: alignment,
                    ),
                    pw.SizedBox(height: 10.0),
                  ],

                  if (returnsDesc.isNotEmpty) ...[
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        PdfTextHelper.buildText(
                          fallbackFont: codeFontBundle.regular,
                          isRtl ? 'القيمة المعادة: ' : 'Returns: ',
                          style: pw.TextStyle(
                            font: fonts.bold,
                            fontSize: baseFontSize * 0.9,
                            color: labelColor,
                          ),
                          isRtl: isRtl,
                        ),
                        pw.SizedBox(width: 4.0),
                        pw.Expanded(
                          child: PdfTextHelper.buildText(
                            fallbackFont: codeFontBundle.regular,
                            returnsDesc,
                            style: pw.TextStyle(
                              font: fonts.fontForWeight(theme.fontWeight),
                              fontSize: baseFontSize * 0.9,
                              color: const PdfColor.fromInt(0xFF1E293B),
                              lineSpacing: 1.4,
                            ),
                            isRtl: isRtl,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // 3. صندوق الكود الملون عبر PdfSyntaxHighlighter
                  if (exampleLines.isNotEmpty) ...[
                    pw.SizedBox(height: 10.0),
                    PdfTextHelper.buildText(
                      fallbackFont: codeFontBundle.regular,
                      isRtl ? 'مثال الاستخدام (Example):' : 'Example:',
                      style: pw.TextStyle(
                        font: fonts.bold,
                        fontSize: baseFontSize * 0.9,
                        color: labelColor,
                      ),
                      isRtl: isRtl,
                    ),
                    pw.SizedBox(height: 6.0),
                    pw.Directionality(
                      textDirection: pw.TextDirection.ltr,
                      child: pw.Container(
                        width: double.infinity,
                        padding: const pw.EdgeInsets.all(10.0),
                        decoration: const pw.BoxDecoration(
                          color: codeBgColor,
                          borderRadius: pw.BorderRadius.all(
                            pw.Radius.circular(4.0),
                          ),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: exampleLines.map((line) {
                            return PdfSyntaxHighlighter.buildLineWidget(
                              line,
                              language,
                              codeFont: codeFontBundle.regular,
                              arabicFont: fonts.fontForWeight(theme.fontWeight),
                              fontSize: baseFontSize * 0.80,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildParametersTable({
    required List<_ParameterInfo> parameters,
    required bool isRtl,
    required pw.Alignment alignment,
  }) {
    final headerTitles = isRtl
        ? ['المعامل', 'النوع', 'الوصف']
        : ['Parameter', 'Type', 'Description'];

    final headerCells = headerTitles.map((title) {
      return pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
        alignment: alignment,
        child: PdfTextHelper.buildText(
          fallbackFont: codeFontBundle.regular,
          title,
          style: pw.TextStyle(
            font: fonts.bold,
            fontSize: baseFontSize * 0.82,
            color: const PdfColor.fromInt(0xFF1E293B),
          ),
          isRtl: isRtl,
        ),
      );
    }).toList();

    final rows = <pw.TableRow>[
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFE2E8F0)),
        children: isRtl ? headerCells.reversed.toList() : headerCells,
      ),
    ];

    for (int i = 0; i < parameters.length; i++) {
      final p = parameters[i];
      final isEven = i % 2 == 0;

      final cells = [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 4.5,
          ),
          alignment: alignment,
          child: PdfTextHelper.buildText(
            fallbackFont: codeFontBundle.regular,
            p.name,
            style: pw.TextStyle(
              font: fonts.bold,
              fontSize: baseFontSize * 0.8,
              color: const PdfColor.fromInt(0xFF0F172A),
            ),
            latinStyle: pw.TextStyle(
              font: codeFontBundle.bold,
              fontSize: baseFontSize * 0.78,
              color: const PdfColor.fromInt(0xFF0F172A),
            ),
            isRtl: isRtl,
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 4.5,
          ),
          alignment: alignment,
          child: PdfTextHelper.buildText(
            fallbackFont: codeFontBundle.regular,
            p.type,
            style: pw.TextStyle(
              font: fonts.bold,
              fontSize: baseFontSize * 0.8,
              color: const PdfColor.fromInt(0xFF0284C7),
            ),
            latinStyle: pw.TextStyle(
              font: codeFontBundle.bold,
              fontSize: baseFontSize * 0.78,
              color: const PdfColor.fromInt(0xFF0284C7),
            ),
            isRtl: isRtl,
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 4.5,
          ),
          alignment: alignment,
          child: PdfTextHelper.buildText(
            fallbackFont: codeFontBundle.regular,
            p.description,
            style: pw.TextStyle(
              font: fonts.fontForWeight(theme.fontWeight),
              fontSize: baseFontSize * 0.8,
              color: const PdfColor.fromInt(0xFF334155),
              lineSpacing: 1.3,
            ),
            latinStyle: pw.TextStyle(
              font: codeFontBundle.regular,
              fontSize: baseFontSize * 0.78,
              color: const PdfColor.fromInt(0xFF334155),
            ),
            isRtl: isRtl,
          ),
        ),
      ];

      rows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: isEven
                ? PdfColors.white
                : const PdfColor.fromInt(0xFFF1F5F9),
          ),
          children: isRtl ? cells.reversed.toList() : cells,
        ),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(
        color: const PdfColor.fromInt(0xFFCBD5E1),
        width: 0.5,
      ),
      columnWidths: isRtl
          ? const {
              0: pw.FlexColumnWidth(2.5),
              1: pw.FlexColumnWidth(1.2),
              2: pw.FlexColumnWidth(1.2),
            }
          : const {
              0: pw.FlexColumnWidth(1.2),
              1: pw.FlexColumnWidth(1.2),
              2: pw.FlexColumnWidth(2.5),
            },
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      children: rows,
    );
  }

  List<_ParameterInfo> _parseParameters(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data
          .map((item) {
            if (item is Map) {
              return _ParameterInfo(
                name: (item['name'] ?? '').toString().trim(),
                type: (item['type'] ?? '').toString().trim(),
                description: (item['description'] ?? '').toString().trim(),
              );
            }
            final str = item.toString().trim();
            final parts = str
                .split(RegExp(r'[|,،]'))
                .map((e) => e.trim())
                .toList();
            return _ParameterInfo(
              name: parts.isNotEmpty ? parts[0] : '',
              type: parts.length > 1 ? parts[1] : '',
              description: parts.length > 2 ? parts.sublist(2).join(' ') : '',
            );
          })
          .where((p) => p.name.isNotEmpty)
          .toList();
    }
    if (data is String && data.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is List) return _parseParameters(decoded);
      } catch (_) {}
      return data
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .map((line) {
            final delimiter = line.contains('|')
                ? '|'
                : (line.contains('،') ? '،' : ',');
            final parts = line.split(delimiter).map((c) => c.trim()).toList();
            return _ParameterInfo(
              name: parts.isNotEmpty ? parts[0] : '',
              type: parts.length > 1 ? parts[1] : '',
              description: parts.length > 2 ? parts.sublist(2).join(' ') : '',
            );
          })
          .where((p) => p.name.isNotEmpty)
          .toList();
    }
    return [];
  }
}

class _ParameterInfo {
  final String name;
  final String type;
  final String description;

  const _ParameterInfo({
    required this.name,
    required this.type,
    required this.description,
  });
}
