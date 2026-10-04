import 'package:lecture_formater/domain/entities/block_node.dart';
import 'package:lecture_formater/engine/pdf/pdf_font_manager.dart';
import 'package:lecture_formater/engine/pdf/pdf_text_helper.dart';
import 'package:lecture_formater/engine/pdf/widgets/pdf_code_syntax.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfCodeWidget extends pw.StatelessWidget {
  final BlockNode node;
  final PdfFontBundle fontBundle;

  final PdfCodeFontBundle codeFontBundle;

  PdfCodeWidget({
    required this.node,
    required this.fontBundle,

    required this.codeFontBundle,
  });

  @override
  pw.Widget build(pw.Context context) {
    final rawCode = (node.fields['code'] as String?) ?? '';
    final normalized = rawCode.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

    final allLines = normalized.split('\n');
    while (allLines.isNotEmpty && allLines.first.trim().isEmpty) {
      allLines.removeAt(0);
    }
    while (allLines.isNotEmpty && allLines.last.trim().isEmpty) {
      allLines.removeLast();
    }

    final lines = allLines.isNotEmpty ? allLines : ['// لا يوجد كود برمجي'];
    final language =
        (node.fields['language'] as String?)?.toLowerCase() ?? 'dart';
    final caption = (node.fields['caption'] as String?)?.trim() ?? '';
    final fileName = node.fields['fileName'] as String? ?? '';
    String title = fileName.isNotEmpty ? ' # $fileName' : 'مثال برمجي #';

    final showLineNumbers = (node.fields['showLineNumbers'] as bool?) ?? true;

    final codeFontSize = 12.0;

    const darkBackground = PdfColor.fromInt(0xFF1E1E1E);
    const headerBackground = PdfColor.fromInt(0xFF252526);
    final direction = _getDirection(node);
    final bool isRtl = direction == pw.TextDirection.rtl;

    final rows = <pw.TableRow>[];

    rows.add(
      pw.TableRow(
        decoration: pw.BoxDecoration(
          color: PdfColor.fromInt(0xFFFFFFFF),
          borderRadius: pw.BorderRadius.only(
            topLeft: pw.Radius.circular(6.0),
            topRight: pw.Radius.circular(6.0),
          ),
        ),
        children: [
          pw.Container(),
          pw.Directionality(
            textDirection: direction,
            child: pw.Padding(
              padding: pw.EdgeInsets.only(
                top: node.layoutRules.spaceBefore,
                bottom: 4.0,

                left: 2.0,
                right: 2.0,
              ),
              child: PdfTextHelper.buildText(
                fallbackFont: codeFontBundle.regular,
                title,
                style: pw.TextStyle(
                  font: fontBundle.bold,
                  fontSize: codeFontSize * 1.25,
                  color: headerBackground,
                ),
                isRtl: isRtl,
              ),
            ),
          ),
        ],
      ),
    );

    // 1. شريط نافذة المحرر العلوي
    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(
          color: headerBackground,
          borderRadius: pw.BorderRadius.only(
            topLeft: pw.Radius.circular(6.0),
            topRight: pw.Radius.circular(6.0),
          ),
        ),
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.only(left: 8.0, top: 5.0, bottom: 5.0),
            child: pw.Row(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Container(
                  width: 6.0,
                  height: 6.0,
                  decoration: const pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFFEF4444),
                    shape: pw.BoxShape.circle,
                  ),
                ),
                pw.SizedBox(width: 3.0),
                pw.Container(
                  width: 6.0,
                  height: 6.0,
                  decoration: const pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFFF59E0B),
                    shape: pw.BoxShape.circle,
                  ),
                ),
                pw.SizedBox(width: 3.0),
                pw.Container(
                  width: 6.0,
                  height: 6.0,
                  decoration: const pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFF10B981),
                    shape: pw.BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.only(
              right: 8.0,
              top: 4.0,
              bottom: 4.0,
            ),
            alignment: pw.Alignment.centerRight,
            child: pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 5.0,
                vertical: 1.0,
              ),
              decoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFF333333),
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(3.0)),
              ),
              child: pw.Text(
                language.toUpperCase(),
                style: pw.TextStyle(
                  font: codeFontBundle.bold,
                  fontSize: 7.0,
                  color: const PdfColor.fromInt(0xFFCCCCCC),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    // 2. أسطر الكود البرمجي
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final isLastRow = (i == lines.length - 1) && caption.isEmpty;

      rows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: darkBackground,
            borderRadius: isLastRow
                ? const pw.BorderRadius.only(
                    bottomLeft: pw.Radius.circular(6.0),
                    bottomRight: pw.Radius.circular(6.0),
                  )
                : pw.BorderRadius.zero,
          ),
          children: [
            // عمود رقم السطر
            pw.Container(
              padding: const pw.EdgeInsets.only(
                left: 6.0,
                right: 8.0,
                top: 1.5,
                bottom: 1.5,
              ),
              alignment: pw.Alignment.topRight,
              child: showLineNumbers
                  ? pw.Text(
                      '${i + 1}',
                      style: pw.TextStyle(
                        font: fontBundle.regular,
                        fontSize: codeFontSize,
                        color: const PdfColor.fromInt(0xFF6E7681),
                      ),
                    )
                  : pw.SizedBox(),
            ),
            // عمود الكود البرمجي مع كامل الإزاحة الهندسية
            pw.Directionality(
              textDirection: pw.TextDirection.ltr,
              child: pw.Container(
                padding: const pw.EdgeInsets.only(
                  left: 2.0,
                  right: 8.0,
                  top: 1.5,
                  bottom: 1.5,
                ),
                alignment: pw.Alignment.topLeft,
                child: PdfSyntaxHighlighter.buildLineWidget(
                  line,
                  language,
                  codeFont: codeFontBundle.regular,
                  arabicFont: fontBundle.regular,

                  fontSize: codeFontSize * 1.1,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // // 3. الشرح التوضيحي السفلي
    // if (caption.isNotEmpty) {
    //   rows.add(
    //     pw.TableRow(
    //       decoration: const pw.BoxDecoration(
    //         color: headerBackground,
    //         borderRadius: pw.BorderRadius.only(
    //           bottomLeft: pw.Radius.circular(6.0),
    //           bottomRight: pw.Radius.circular(6.0),
    //         ),
    //       ),
    //       children: [
    //         pw.SizedBox(),
    //         pw.Directionality(
    //           textDirection: pw.TextDirection.rtl,
    //           child: pw.Container(
    //             padding: const pw.EdgeInsets.symmetric(
    //               horizontal: 8.0,
    //               vertical: 4.0,
    //             ),
    //             alignment: pw.Alignment.centerRight,
    //             child: pw.Text(
    //               caption,
    //               style: pw.TextStyle(
    //                 font: fontBundle.regular,
    //                 fontSize: baseFontSize * 0.8,
    //                 color: const PdfColor.fromInt(0xFF94A3B8),
    //               ),
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //   );
    // }

    return pw.Table(
      border: null,
      columnWidths: {
        0: pw.FixedColumnWidth(showLineNumbers ? 28.0 : 0.0),
        1: const pw.FlexColumnWidth(),
      },
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.top,
      children: rows,
    );
  }

  static pw.TextDirection _getDirection(BlockNode node) {
    return (node.layoutRules.textDirection ?? 'rtl') == 'ltr'
        ? pw.TextDirection.ltr
        : pw.TextDirection.rtl;
  }
}
