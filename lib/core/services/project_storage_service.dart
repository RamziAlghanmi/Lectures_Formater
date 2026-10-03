import 'dart:convert';
import 'dart:typed_data';

import 'package:lecture_formater/core/services/app_message.dart';
import 'package:lecture_formater/core/services/file_service.dart';
import 'package:lecture_formater/core/services/loading_manager.dart';
import 'package:lecture_formater/presentation/providers/document_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lecture_formater/presentation/screens/editor_screen.dart';
import 'package:provider/provider.dart';

import '../../engine/pdf/pdf_renderer.dart';

class ProjectStorageService {
  ProjectStorageService._();

  /// تصدير وحفظ ملف JSON على ذاكرة الجهاز
  static Future<void> exportJsonProject(BuildContext context) async {
    final docProvider = context.read<DocumentProvider>();
    final docTitle = docProvider.document.metadata.title.trim();

    try {
      await LoadingManager.run(
        () async {
          final jsonStr = await docProvider.exportJson();

          final safeFileName = (docTitle.isEmpty ? 'lecture_project' : docTitle)
              .replaceAll(RegExp(r'[^\w\u0600-\u06FF\s]+'), '_');

          final lessonNumber = docProvider.document.metadata.lessonNumber;
          final claenFileName = '$lessonNumber-$safeFileName.json';
          final bytes = Uint8List.fromList(utf8.encode(jsonStr));
          final uri = await FileService().saveFile(
            dialogTitle: 'حفظ مشروع JSON',
            fileName: claenFileName,
            bytes: bytes,
            mimeType: 'application/json',
            type: 'json',
          );

          if (uri == null) {
            return;
          }

          if (!context.mounted) return;

          AppMessage.success(
            context,
            title: 'تم الحفظ',
            message: 'تم حفظ المشروع بنجاح:\n',
          );
        },
        message: 'جاري تصدير المشروع...',
        color: Colors.blue,
      );
    } catch (e) {
      if (!context.mounted) return;

      AppMessage.error(
        context,
        title: 'فشل الحفظ',
        message: 'فشل حفظ المشروع:',
      );
    }
  }

  /// استيراد مشروع JSON من الجهاز
  static Future<void> importJsonProject(BuildContext context) async {
    final docProvider = context.read<DocumentProvider>();
    try {
      await LoadingManager.run(() async {
        LoadingManager.setMessage('جاري فتح ملف Json...', color: Colors.blue);

        final result = await FileService().loadFile();

        if (result != null) {
          LoadingManager.setMessage(
            'جاري استخراج بيانات  Json ...',
            color: Colors.blue,
          );

          final fileBytes = await result.readAsBytes();
          final content = utf8.decode(await fileBytes);
          LoadingManager.setMessage('جاري  تجهيز Json ...', color: Colors.blue);

          await docProvider.loadFromJson(content);

          if (context.mounted) {
            final pdfPreviewState = EditorScreen.PdfPreviewsKey.currentState;
            if (pdfPreviewState != null) {
              await pdfPreviewState.refreshDoc('إعادة بناء معاينة Pdf ...');
            }

            if (context.mounted) {
              AppMessage.success(
                context,
                title: 'تم الفتح',
                message: 'تم استيراد المشروع بنجاح ومواصلة العمل عليه',
              );
            }
          }
        }
      });
    } catch (e) {
      AppMessage.error(
        context,
        title: 'فشل الاستيراد',
        message: 'فشل استيراد المشروع:',
      );
    }
  }

  /// حفظ الـ PDF في مسار يحدده المستخدم
  static Future<void> exportPdf(BuildContext context) async {
    try {
      final document = context.read<DocumentProvider>().document;
      await LoadingManager.run(() async {
        LoadingManager.setMessage(
          'جاري استخراج البيانات...',
          color: Colors.blue,
        );
        final bytes = await PdfRenderer.generatePdfBytes(document: document);
        final lessonNumber = document.metadata.lessonNumber;
        final cleanName = document.metadata.title
            .replaceAll(RegExp(r'[^\w\s\u0600-\u06FF]+'), '_')
            .trim();
        final defaultFileName = cleanName.isEmpty
            ? 'lecture.pdf'
            : '$lessonNumber-$cleanName.pdf';

        final uri = await FileService().saveFile(
          dialogTitle: 'حفظ مشروع PDF',
          fileName: defaultFileName,
          bytes: bytes,
          mimeType: 'application/pdf',
          type: 'pdf',
        );

        if (uri == null) {
          return;
        }

        if (context.mounted) {
          AppMessage.success(
            context,
            title: 'تم الحفظ',
            message: 'تم حفظ ملف Pdf بنجاح',
          );
        }
      });
    } catch (e) {
      if (context.mounted) {
        AppMessage.error(context, title: 'فشل الحفظ', message: 'فشل حفظ الملف');
      }
    }
  }

  static Future<void> confirmClearDocument(BuildContext context) async {
    final screenContext = context;
    final confirm = await showDialog<bool>(
      context: screenContext,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('مسح المستند بالكامل'),
          content: const Text(
            'هل أنت متأكد من مسح جميع الكتل والمحتوى الحالي؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('مسح الآن'),
            ),
          ],
        ),
      ),
    );

    if (confirm == true && context.mounted) {
      await LoadingManager.run(
        () async {
          await context.read<DocumentProvider>().clearDocument();
          if (context.mounted) {
            final pdfPreviewState = EditorScreen.PdfPreviewsKey.currentState;
            if (pdfPreviewState != null) {
              await pdfPreviewState.refreshDoc('تنظيف معاينة Pdf ...');
            }

            if (context.mounted) {
              AppMessage.success(
                context,
                title: 'تم التنظيف',
                message:
                    'تم تنظيف المستند بنجاح يمكنك العمل على إنشاء ملف جديد',
              );
            }
          }
          ;
        },
        message: 'جاري مسح المستند',
        color: Colors.red,
      );
    }
  }
}
