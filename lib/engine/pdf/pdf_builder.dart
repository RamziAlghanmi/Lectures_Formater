import 'package:lecture_formater/engine/pdf/widgets/pdf_block_dispatcher.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/entities/document_model.dart';
import '../../domain/entities/page_model.dart';
import 'pdf_font_manager.dart';
import 'widgets/pdf_header_footer.dart';

class PdfBuilder {
  final DocumentModel document;

  const PdfBuilder({required this.document});

  Future<pw.Document> buildDocument() async {
    // ============================================================
    // إعدادات المستند
    // ============================================================

    final theme = document.theme;

    // ============================================================
    // تحميل عائلة الخط المختارة
    // ============================================================

    final fontBundle = await PdfFontManager.loadFonts(theme.fontFamily);
    final codeFontBundle = await PdfFontManager.loadCodeFonts();

    // ============================================================
    // الألوان
    // ============================================================

    final primaryColor = PdfColor.fromInt(theme.primaryColor);

    final textColor = PdfColor.fromInt(theme.textColor);

    // ============================================================
    // PDF Theme
    // ============================================================

    final pdfTheme = fontBundle.toPdfTheme(
      fontWeight: theme.fontWeight,
      textColor: textColor,
      baseFontSize: theme.baseFontSize,
    );
    // ============================================================
    // إنشاء مستند PDF
    // ============================================================

    final pdf = pw.Document(theme: pdfTheme);

    // ============================================================
    // إعدادات الصفحة
    // ============================================================

    final settings = document.settings;

    // أبعاد الصفحة بدون الهوامش
    // لأن MultiPage هو الذي يطبق الهوامش.
    final pageFormat = PdfPageFormat(settings.pageWidth, settings.pageHeight);

    // ============================================================
    // إضافة الصفحة
    // ============================================================

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,

        // الاتجاه الافتراضي للمستند
        textDirection: pw.TextDirection.rtl,

        maxPages: 100,

        // ==========================================================
        // الهوامش
        // ==========================================================
        margin: pw.EdgeInsets.only(
          top: settings.margins.top,
          bottom: settings.margins.bottom,
          left: settings.margins.left,
          right: settings.margins.right,
        ),

        // ==========================================================
        // Footer
        // ==========================================================
        footer: settings.showFooter
            ? (pw.Context context) {
                return PdfFooterWidget(
                  currentPage: context.pageNumber,
                  totalPages: context.pagesCount,
                  customNote: settings.customFooterText,
                  fontBundle: fontBundle,
                  theme: theme,
                );
              }
            : null,

        // ==========================================================
        // محتوى المستند
        // ==========================================================
        build: (pw.Context context) {
          final contentList = <pw.Widget>[];

          // ========================================================
          // 1. ترويسة الدرس
          // ========================================================

          contentList.add(
            PdfHeaderWidget(
              data: PageHeaderData(
                title: document.metadata.title,
                subtitle: document.metadata.subtitle,
                lessonNumber: document.metadata.lessonNumber,
                courseName: document.metadata.courseName,
                unit: document.metadata.unit,
                isVisible: true,
              ),
              primaryColor: primaryColor,
              fontBundle: fontBundle,
              theme: theme,
            ),
          );

          // ========================================================
          // 2. محتوى الكتل
          // ========================================================

          for (final block in document.blocks) {
            // ------------------------------------------------------
            // كسر الصفحة قبل الكتلة
            // ------------------------------------------------------

            if (block.layoutRules.forcePageBreakBefore &&
                contentList.isNotEmpty) {
              contentList.add(pw.NewPage());
            }

            // ------------------------------------------------------
            // إنشاء Widget للكتلة
            // ------------------------------------------------------

            final blockWidget = PdfBlockDispatcher.dispatch(
              node: block,
              fontBundle: fontBundle,
              themeConfig: theme,
              codeFontBundle: codeFontBundle,
            );

            // ------------------------------------------------------
            // اتجاه النص الخاص بالكتلة
            // ------------------------------------------------------

            final isRtl = block.layoutRules.textDirection != 'ltr';

            final directionalBlockWidget = pw.Directionality(
              textDirection: isRtl
                  ? pw.TextDirection.rtl
                  : pw.TextDirection.ltr,
              child: blockWidget,
            );

            // ------------------------------------------------------
            // المسافة قبل الكتلة
            // ------------------------------------------------------

            if (block.layoutRules.spaceBefore > 0) {
              contentList.add(
                pw.SizedBox(height: block.layoutRules.spaceBefore),
              );
            }

            // ------------------------------------------------------
            // Keep Together
            // ------------------------------------------------------

            if (block.layoutRules.keepTogether) {
              contentList.add(
                pw.Container(
                  width: double.infinity,
                  child: directionalBlockWidget,
                ),
              );
            } else {
              contentList.add(directionalBlockWidget);
            }

            // ------------------------------------------------------
            // المسافة بعد الكتلة
            // ------------------------------------------------------

            if (block.layoutRules.spaceAfter > 0) {
              contentList.add(
                pw.SizedBox(height: block.layoutRules.spaceAfter),
              );
            }
          }

          return contentList;
        },
      ),
    );

    return pdf;
  }
}
