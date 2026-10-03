import 'package:flutter/material.dart';
import 'package:lecture_formater/core/config/app_fonts.dart';
import 'package:lecture_formater/domain/entities/document_theme_config.dart';
import 'package:lecture_formater/presentation/screens/editor_screen.dart';
import 'package:provider/provider.dart';

import '../providers/document_provider.dart';

class FontFamilyPopup extends StatelessWidget {
  const FontFamilyPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final docProvider = context.watch<DocumentProvider>();
    final selectedFamily = context.select<DocumentProvider, String>(
      (provider) => provider.document?.theme.fontFamily ?? 'NotoNaskhArabic',
    );

    final current = AppFonts.getByName(selectedFamily);

    return PopupMenuButton<String>(
      tooltip: 'عائلة الخط',

      onSelected: (value) {
        docProvider.updateTheme(
          docProvider.document.theme.copyWith(fontFamily: value),
        );
        final pdfPreviewState = EditorScreen.PdfPreviewsKey.currentState;
        if (pdfPreviewState != null) {
          pdfPreviewState.refreshDoc(
            ' حفظ تغيرات عاىلة الخط على معاينة Pdf ...',
          );
        }
      },

      itemBuilder: (context) {
        return AppFonts.all.map((font) {
          final selected = font.name == selectedFamily;

          return PopupMenuItem<String>(
            value: font.name,

            child: Row(
              children: [
                SizedBox(
                  width: 10,
                  child: selected ? const Icon(Icons.check, size: 18) : null,
                ),

                Text(font.displayName, style: const TextStyle(fontSize: 15)),
              ],
            ),
          );
        }).toList();
      },

      child: Container(
        height: 36,
        constraints: const BoxConstraints(minWidth: 50),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
          color: Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(current.displayName, style: const TextStyle(fontSize: 14)),

            const SizedBox(width: 5),

            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }
}

class FontWeightPopup extends StatelessWidget {
  const FontWeightPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final docProvider = context.watch<DocumentProvider>();

    final family = AppFonts.getByName(docProvider.document.theme.fontFamily);

    final currentWeight = DocumentFontWeight.fromInt(
      docProvider.document.theme.fontWeight,
    );

    return PopupMenuButton<int>(
      tooltip: 'وزن الخط',

      onSelected: (weight) {
        docProvider.updateTheme(
          docProvider.document.theme.copyWith(fontWeight: weight),
        );
        final pdfPreviewState = EditorScreen.PdfPreviewsKey.currentState;
        if (pdfPreviewState != null) {
          pdfPreviewState.refreshDoc(' حفظ تغيرات وزن الخط على معاينة Pdf ...');
        }
      },

      itemBuilder: (context) {
        return family.availableWeights.map((weight) {
          final selected = weight == docProvider.document.theme.fontWeight;

          final weightType = DocumentFontWeight.fromInt(weight);

          return PopupMenuItem<int>(
            value: weight,

            child: Row(
              children: [
                SizedBox(
                  width: 10,
                  child: selected ? const Icon(Icons.check, size: 18) : null,
                ),

                Text(
                  weightType.displayName,
                  style: TextStyle(fontWeight: _flutterFontWeight(weight)),
                ),

                const SizedBox(width: 5),

                Text(
                  '$weight',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          );
        }).toList();
      },

      child: Container(
        height: 36,
        constraints: const BoxConstraints(minWidth: 50),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
          color: Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentWeight.displayName,
              style: TextStyle(
                fontWeight: _flutterFontWeight(
                  docProvider.document.theme.fontWeight,
                ),
                fontSize: 14,
              ),
            ),

            const SizedBox(width: 5),

            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }

  FontWeight _flutterFontWeight(int weight) {
    switch (weight) {
      case 100:
        return FontWeight.w100;

      case 200:
        return FontWeight.w200;

      case 300:
        return FontWeight.w300;

      case 400:
        return FontWeight.w400;

      case 500:
        return FontWeight.w500;

      case 600:
        return FontWeight.w600;

      case 700:
        return FontWeight.w700;

      case 800:
        return FontWeight.w800;

      case 900:
        return FontWeight.w900;

      default:
        return FontWeight.w400;
    }
  }
}
