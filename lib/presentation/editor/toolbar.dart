import 'package:flutter/material.dart';
import 'package:lecture_formater/core/services/project_storage_service.dart';
import 'package:lecture_formater/presentation/editor/add_block_dialog.dart';
import 'package:lecture_formater/presentation/editor/fontSize_controle.dart';
import 'package:lecture_formater/presentation/editor/font_family.dart';
import 'package:lecture_formater/presentation/providers/document_provider.dart';
import 'package:provider/provider.dart';

import '../providers/editor_provider.dart';

class EditorToolbar extends StatelessWidget {
  const EditorToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    final docProvider = context.watch<DocumentProvider>();
    final editorProvider = context.watch<EditorProvider>();

    final screenContext =
        context; // Store the context for later use in other methods

    return Container(
      height: 52.0,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
        ),
      ),
      child: Row(
        children: [
          // التراجع (Undo)
          IconButton(
            icon: const Icon(Icons.undo, size: 20.0),
            tooltip: 'تراجع (Undo)',
            onPressed: docProvider.canUndo ? () => docProvider.undo() : null,
          ),
          // الإعادة (Redo)
          IconButton(
            icon: const Icon(Icons.redo, size: 20.0),
            tooltip: 'إعادة (Redo)',
            onPressed: docProvider.canRedo ? () => docProvider.redo() : null,
          ),
          const VerticalDivider(width: 16.0, indent: 10.0, endIndent: 10.0),

          // زر إضافة كتلة جديدة
          AddBlockDialog(),
          const SizedBox(width: 8.0),

          // فحص المستند الذكي (Preflight)
          const Spacer(),

          // عنوان المستند الحالي
          Expanded(
            flex: 2,
            child: Text(
              docProvider.document.metadata.title,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
              ),
            ),
          ),

          const Spacer(),

          const FontFamilyPopup(),

          const SizedBox(width: 6),

          const FontWeightPopup(),
          FontSizeButton(),
          // استيراد مشروع JSON
          IconButton(
            icon: const Icon(Icons.folder_open_outlined, size: 20.0),
            tooltip: 'فتح مشروع JSON',
            onPressed: () {
              ProjectStorageService.importJsonProject(context);
            },
          ),

          // حفظ المشروع كـ JSON
          IconButton(
            icon: const Icon(Icons.save_outlined, size: 20.0),
            tooltip: 'حفظ المشروع كـ JSON',
            onPressed: () {
              ProjectStorageService.exportJsonProject(screenContext);
            },
          ),

          // مسح المستند
          IconButton(
            icon: const Icon(
              Icons.delete_sweep_outlined,
              size: 20.0,
              color: Colors.redAccent,
            ),
            tooltip: 'مسح المستند',
            onPressed: () {
              ProjectStorageService.confirmClearDocument(context);
            },
          ),

          const VerticalDivider(width: 16.0, indent: 10.0, endIndent: 10.0),

          // لوحة الخصائص (Inspector)
          IconButton(
            icon: Icon(
              editorProvider.isInspectorOpen
                  ? Icons.vertical_split
                  : Icons.vertical_split_outlined,
              size: 20.0,
              color: editorProvider.isInspectorOpen
                  ? const Color(0xFF1E3A8A)
                  : null,
            ),
            tooltip: 'لوحة الخصائص (Inspector)',
            onPressed: () => editorProvider.toggleInspector(),
          ),

          // تصدير PDF
          FilledButton.tonalIcon(
            icon: const Icon(Icons.picture_as_pdf, size: 18.0),
            label: const Text('تصدير PDF'),
            onPressed: () {
              ProjectStorageService.exportPdf(context);
            },
          ),
        ],
      ),
    );
  }
}
