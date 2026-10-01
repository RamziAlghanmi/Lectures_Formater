import 'package:lecture_formater/domain/entities/document_theme_config.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../domain/entities/page_model.dart';
import '../pdf_font_manager.dart';

class PdfHeaderWidget extends pw.StatelessWidget {
  final PageHeaderData data;
  final PdfColor primaryColor;
  final PdfFontBundle fontBundle;
  final DocumentThemeConfig theme;

  PdfHeaderWidget({
    required this.data,
    required this.primaryColor,
    required this.fontBundle,
    required this.theme,
  });

  @override
  pw.Widget build(pw.Context context) {
    if (!data.isVisible) return pw.SizedBox.shrink();

    final accentBlue = const PdfColor.fromInt(0xFF3B82F6);

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12.0),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          // Top Row: Course Name & Unit Badge
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                data.courseName.isNotEmpty ? data.courseName : 'اسم الدورة',
                style: pw.TextStyle(
                  font: fontBundle.bold,
                  fontSize: 10.5,
                  color: accentBlue,
                ),
              ),
              if (data.unit.isNotEmpty)
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 7.0,
                    vertical: 2.0,
                  ),
                  decoration: pw.BoxDecoration(
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(4.0),
                    ),
                    border: pw.Border.all(
                      color: const PdfColor.fromInt(0xFFCBD5E1),
                      width: 0.6,
                    ),
                  ),
                  child: pw.Text(
                    data.unit,
                    style: pw.TextStyle(
                      font: fontBundle.fontForWeight(theme.fontWeight),
                      fontSize: 8.5,
                      color: const PdfColor.fromInt(0xFF334155),
                    ),
                  ),
                ),
            ],
          ),
          pw.SizedBox(height: 6.0),

          // Circle Number + Title & Subtitle
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Container(
                width: 26.0,
                height: 26.0,
                decoration: pw.BoxDecoration(
                  color: accentBlue,
                  shape: pw.BoxShape.circle,
                ),
                alignment: pw.Alignment.center,
                child: pw.Text(
                  data.lessonNumber.isNotEmpty ? data.lessonNumber : '01',
                  style: pw.TextStyle(
                    font: fontBundle.bold,
                    fontSize: 11.0,
                    color: PdfColors.white,
                  ),
                ),
              ),
              pw.SizedBox(width: 8.0),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Text(
                      data.title.isNotEmpty ? data.title : 'عنوان الدرس',
                      style: pw.TextStyle(
                        font: fontBundle.bold,
                        fontSize: 15.0,
                        color: const PdfColor.fromInt(0xFF0F172A),
                      ),
                    ),
                    if (data.subtitle.isNotEmpty)
                      pw.Text(
                        data.subtitle,
                        style: pw.TextStyle(
                          font: fontBundle.fontForWeight(theme.fontWeight),
                          fontSize: 9.5,
                          color: const PdfColor.fromInt(0xFF64748B),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8.0),
          pw.Container(height: 0.8, color: const PdfColor.fromInt(0xFFE2E8F0)),
        ],
      ),
    );
  }
}

class PdfFooterWidget extends pw.StatelessWidget {
  final int currentPage;
  final int totalPages;
  final String customNote;
  final PdfFontBundle fontBundle;
  final DocumentThemeConfig theme;

  PdfFooterWidget({
    required this.currentPage,
    required this.totalPages,
    this.customNote = '',
    required this.fontBundle,
    required this.theme,
  });

  @override
  pw.Widget build(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 8.0),
      child: pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Container(height: 0.6, color: const PdfColor.fromInt(0xFFE2E8F0)),
          pw.SizedBox(height: 4.0),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                customNote,
                style: pw.TextStyle(
                  font: fontBundle.fontForWeight(theme.fontWeight),
                  fontSize: 8.0,
                  color: const PdfColor.fromInt(0xFF94A3B8),
                ),
              ),
              pw.Text(
                '$currentPage / $totalPages',
                style: pw.TextStyle(
                  font: fontBundle.fontForWeight(theme.fontWeight),
                  fontSize: 8.5,
                  color: const PdfColor.fromInt(0xFF334155),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
