import 'package:flutter/material.dart';
import 'package:lecture_formater/presentation/providers/document_provider.dart';
import 'package:lecture_formater/presentation/screens/editor_screen.dart';
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
        final pdfPreviewState = EditorScreen.PdfPreviewsKey.currentState;
        if (pdfPreviewState != null) {
          pdfPreviewState.refreshDoc(' حفظ تغيرات حجم الخط على معاينة Pdf ...');
        }
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
        width: 35,
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
