// import 'dart:convert';

// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;

// import '../../../domain/entities/block_node.dart';
// import '../pdf_font_manager.dart';
// import '../pdf_text_helper.dart';

// class PdfTableWidget extends pw.StatelessWidget {
// final BlockNode node;
// final PdfFontBundle fontBundle;
// final PdfColor primaryColor;
// final double baseFontSize;

// PdfTableWidget({
// required this.node,
// required this.fontBundle,
// required this.primaryColor,
// required this.baseFontSize,
// });

// @override
// pw.Widget build(pw.Context context) {
// final isRtl = (node.layoutRules.textDirection ?? 'rtl') != 'ltr';
// final textDirection = isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr;
// final alignment = isRtl
// ? pw.Alignment.centerRight
// : pw.Alignment.centerLeft;

// final headers = _parseHeaders(node.fields['headers']);
// final rowsData = _parseRows(node.fields['rows']);
// final caption = (node.fields['caption'] as String?)?.trim() ?? '';

// final tableFontSize = baseFontSize * 0.88;
// const borderColor = PdfColor.fromInt(0xFFCBD5E1); // Slate 300
// const alternateRowColor = PdfColor.fromInt(0xFFF8FAFC); // Slate 50
// const headerTextColor = PdfColors.white;

// // حساب أقصى عدد أعمدة
// int columnCount = headers.length;
// for (final row in rowsData) {
//   if (row.length > columnCount) {
//     columnCount = row.length;
//   }
// }

// if (columnCount == 0) {
//   return pw.SizedBox();
// }

// final tableRows = <pw.TableRow>[];

// // 1. ترويسة الجدول (Headers)
// if (headers.isNotEmpty) {
//   final headerCells = List.generate(columnCount, (colIdx) {
//     final text = colIdx < headers.length ? headers[colIdx] : '';
//     return pw.Container(
//       padding: const pw.EdgeInsets.symmetric(
//         horizontal: 2.0,
//         vertical: 6.0,
//       ),
//       alignment: alignment,
//       child: PdfTextHelper.buildText(
//         text,

//         style: pw.TextStyle(
//           font: fontBundle.cairoBold,
//           fontSize: tableFontSize,
//           color: headerTextColor,
//         ),
//         isRtl: isRtl,
//       ),
//     );
//   });

//   tableRows.add(
//     pw.TableRow(
//       decoration: pw.BoxDecoration(color: primaryColor),
//       repeat: true, // تكرار الترويسة آلياً عند تقسيم الجدول بين الصفحات
//       // عكس ترتيب الأعمدة في وضع RTL لتبدأ من أقصى اليمين
//       children: isRtl ? headerCells.reversed.toList() : headerCells,
//     ),
//   );
// }

// // 2. صفوف بيانات الجدول (Data Rows)
// for (int i = 0; i < rowsData.length; i++) {
//   final row = rowsData[i];
//   final isEven = i % 2 == 0;

//   final rowCells = List.generate(columnCount, (colIdx) {
//     final cellText = colIdx < row.length ? row[colIdx] : '';
//     return pw.Container(
//       padding: const pw.EdgeInsets.symmetric(
//         horizontal: 8.0,
//         vertical: 5.5,
//       ),
//       alignment: alignment,
//       child: PdfTextHelper.buildText(
//         cellText,
//         style: pw.TextStyle(
//           font: fontBundle.cairoRegular,
//           fontSize: tableFontSize * 0.8,
//           color: const PdfColor.fromInt(0xFF1E293B),
//           lineSpacing: 1.3,
//         ),
//         isRtl: isRtl,
//       ),
//     );
//   });

//   tableRows.add(
//     pw.TableRow(
//       decoration: pw.BoxDecoration(
//         color: isEven ? PdfColors.white : alternateRowColor,
//       ),
//       // عكس خلايا الصف لتطابق الترويسة
//       children: isRtl ? rowCells.reversed.toList() : rowCells,
//     ),
//   );
// }

// return pw.Directionality(
//   textDirection: textDirection,
//   child: pw.Container(
//     margin: pw.EdgeInsets.only(
//       top: node.layoutRules.spaceBefore,
//       bottom: node.layoutRules.spaceAfter,
//       left: 8.0,
//       right: 8.0,
//     ),
//     child: pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.stretch,
//       children: [
//         // جسم الجدول
//         pw.Table(
//           border: pw.TableBorder.all(color: borderColor, width: 0.6),
//           columnWidths: {0: const pw.IntrinsicColumnWidth()},
//           defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
//           children: tableRows,
//         ),

//         // الوصف التوضيحي للجدول (إن وجد)
//         if (caption.isNotEmpty) ...[
//           pw.SizedBox(height: 5.0),
//           pw.Padding(
//             padding: const pw.EdgeInsets.symmetric(horizontal: 4.0),
//             child: PdfTextHelper.buildText(
//               caption,
//               style: pw.TextStyle(
//                 font: fontBundle.cairoRegular,
//                 fontSize: tableFontSize,
//                 color: const PdfColor.fromInt(0xFF64748B), // Slate 500
//               ),
//               textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
//               isRtl: isRtl,
//             ),
//           ),
//         ],
//       ],
//     ),
//   ),
// );

// }

// List<String> _parseHeaders(dynamic data) {
// if (data == null) return [];
// if (data is List) {
// return data
// .map((e) {
// if (e is Map) return (e['column_name'] ?? '').toString().trim();
// return e.toString().trim();
// })
// .where((e) => e.isNotEmpty)
// .toList();
// }
// if (data is String && data.trim().isNotEmpty) {
// try {
// final decoded = jsonDecode(data);
// if (decoded is List) return parseHeaders(decoded);
// } catch () {}
// final delimiter = data.contains('|')
// ? '|'
// : (data.contains('،') ? '،' : ',');
// return data
// .split(delimiter)
// .map((e) => e.trim())
// .where((e) => e.isNotEmpty)
// .toList();
// }
// return [];
// }

// List<List<String>> _parseRows(dynamic data) {
// if (data == null) return [];
// if (data is List) {
// return data.map((item) {
// if (item is List) {
// return item.map((cell) => cell.toString().trim()).toList();
// }
// if (item is Map) {
// return item.values.map((v) => v.toString().trim()).toList();
// }
// final str = item.toString().trim();
// final delimiter = str.contains('|')
// ? '|'
// : (str.contains('،') ? '،' : ',');
// return str.split(delimiter).map((c) => c.trim()).toList();
// }).toList();
// }
// if (data is String && data.trim().isNotEmpty) {
// try {
// final decoded = jsonDecode(data);
// if (decoded is List) return parseRows(decoded);
// } catch () {}
// return data
// .split('\n')
// .map((line) => line.trim())
// .where((line) => line.isNotEmpty)
// .map((line) {
// final delimiter = line.contains('|')
// ? '|'
// : (line.contains('،') ? '،' : ',');
// return line.split(delimiter).map((cell) => cell.trim()).toList();
// })
// .toList();
// }
// return [];
// }
// }

import 'package:flutter/material.dart';
import 'package:lecture_formater/presentation/providers/document_provider.dart';
import 'package:provider/provider.dart';

class FontSizeButton extends StatelessWidget {
  const FontSizeButton({super.key});

  static const List<double> _fontSizes = [
    8,
    9,
    10,
    11,
    12,
    14,
    16,
    18,
    20,
    22,
    24,
    28,
    32,
    36,
    48,
    72,
  ];

  @override
  Widget build(BuildContext context) {
    final docProvider = context.watch<DocumentProvider>();
    final fontSize = docProvider.document.theme.baseFontSize;
    return PopupMenuButton<double>(
      tooltip: 'حجم الخط',
      padding: EdgeInsets.zero,

      onSelected: (value) {
        docProvider.updateTheme(
          docProvider.document.theme.copyWith(baseFontSize: value),
        );
      },

      itemBuilder: (context) {
        return _fontSizes.map((size) {
          return PopupMenuItem<double>(
            value: size,
            child: SizedBox(
              width: 80,
              child: Row(
                children: [
                  if (size == fontSize) const Icon(Icons.check, size: 18),

                  if (size == fontSize) const SizedBox(width: 8),

                  Text(
                    size.toStringAsFixed(
                      size.truncateToDouble() == size ? 0 : 1,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList();
      },

      child: Container(
        width: 48,
        alignment: Alignment.center,
        child: Text(
          fontSize.toStringAsFixed(
            fontSize.truncateToDouble() == fontSize ? 0 : 1,
          ),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
