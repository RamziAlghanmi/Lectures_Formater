import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lecture_formater/core/services/loading_manager.dart';
import 'package:lecture_formater/engine/pdf/pdf_renderer.dart';
import 'package:lecture_formater/presentation/providers/document_provider.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

class PdfPreviews extends StatefulWidget {
  PdfPreviews({super.key});

  @override
  State<PdfPreviews> createState() => PdfPreviewsState();
}

class PdfPreviewsState extends State<PdfPreviews> {
  Uint8List? pdfBytes;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshDoc('بناء الpdf للمعاينة ...');
    });
    super.initState();
  }

  Future<void> refreshDoc(String message) async {
    final newDoc = context.read<DocumentProvider>().document;
    if (!mounted) return;

    await LoadingManager.run(
      () async {
        final newPdfBytes = await PdfRenderer.generatePdfBytes(
          document: newDoc,
        );
        if (!mounted) return;
        setState(() {
          pdfBytes = newPdfBytes;
        });
        await WidgetsBinding.instance.endOfFrame;
      },
      message: message,
      color: Colors.blue,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    return Column(
      children: [
        if (isDesktop)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(" محاكاة الملف الناتج "),
              IconButton(
                onPressed: () {
                  refreshDoc(' حفظ التغيرات على معاينة Pdf ...');
                },
                icon: Icon(Icons.refresh),
              ),
            ],
          ),
        Expanded(
          child: pdfBytes != null
              ? PdfPreview(
                  build: (format) => pdfBytes!,
                  loadingWidget: Center(
                    child: const CircularProgressIndicator(),
                  ),
                  canChangeOrientation: false,
                  canChangePageFormat: false,
                  scrollViewDecoration: const BoxDecoration(
                    color: Color(0xFF525659),
                  ),
                )
              : Center(
                  child: Container(
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.error,
                            color: Colors.red.shade600,
                            size: 48,
                          ),
                          SizedBox(height: 20),
                          Text(
                            "تعذر إنشاء معاينة PDF",
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
