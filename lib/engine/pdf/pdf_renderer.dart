import 'dart:typed_data';

import 'package:printing/printing.dart';

import '../../core/errors/exceptions.dart';
import '../../domain/entities/document_model.dart';

import 'pdf_builder.dart';

class PdfRenderer {
  const PdfRenderer._();

  /// توليد مصفوفة بايتات ملف الـ PDF بشكل غير متزامن ومستقل
  static Future<Uint8List> generatePdfBytes({
    required DocumentModel document,
  }) async {
    try {
      final builder = PdfBuilder(document: document);

      final pdfDoc = await builder.buildDocument();
      return await pdfDoc.save();
    } catch (e, st) {
      throw DocumentException('فشل في تصيير ملف الـ PDF: $e\n$st');
    }
  }

  /// فتح نافذة المعاينة والطباعة المباشرة للنظام (Print Preview & Layout)
  static Future<void> layoutPrint({required DocumentModel document}) async {
    try {
      final bytes = await generatePdfBytes(document: document);
      final cleanTitle = document.metadata.title
          .replaceAll(RegExp(r'[^\w\s\u0600-\u06FF]+'), '_')
          .trim();
      final lessonNumber = document.metadata.lessonNumber;
      final fileName = cleanTitle.isEmpty
          ? 'document.pdf'
          : '$lessonNumber-$cleanTitle.pdf';

      await Printing.layoutPdf(onLayout: (_) async => bytes, name: fileName);
    } catch (e, st) {
      throw DocumentException('فشل أثناء محاولة طباعة المستند: $e\n$st');
    }
  }
}
