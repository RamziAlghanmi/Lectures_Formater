import 'package:flutter/material.dart';
import 'package:lecture_formater/core/services/project_storage_service.dart';
import 'package:lecture_formater/engine/pdf/pdf_preview.dart';
import 'package:lecture_formater/presentation/editor/add_block_dialog.dart';
import 'package:lecture_formater/presentation/editor/fontSize_controle.dart';
import 'package:lecture_formater/presentation/editor/font_family.dart';
import 'package:provider/provider.dart';

import '../editor/block_canvas.dart';
import '../editor/toolbar.dart';
import '../inspector/inspector_panel.dart';
import '../providers/document_provider.dart';
import '../providers/editor_provider.dart';

class EditorScreen extends StatelessWidget {
  EditorScreen({super.key});
  static GlobalKey<PdfPreviewsState> PdfPreviewsKey =
      GlobalKey<PdfPreviewsState>();
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final textDirection = TextDirection.rtl;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        endDrawer: isDesktop ? null : _buildMobileDrawer(context),

        body: SafeArea(
          child: isDesktop
              ? Column(
                  children: [
                    const EditorToolbar(),
                    Expanded(child: _buildDesktopSplitLayout(context)),
                  ],
                )
              : _buildMobileLayout(context),
        ),
      ),
    );
  }

  // --- 1. واجهة سطح المكتب ---
  Widget _buildDesktopSplitLayout(BuildContext context) {
    final isInspectorOpen = context.select(
      (EditorProvider editorProvider) => editorProvider.isInspectorOpen,
    );

    return Row(
      children: [
        const Expanded(flex: 5, child: BlockCanvas()),
        const VerticalDivider(width: 1.0),
        Expanded(flex: 4, child: PdfPreviews(key: PdfPreviewsKey)),
        if (isInspectorOpen) ...[
          const VerticalDivider(width: 1.0),
          const SizedBox(width: 320, child: InspectorPanel()),
        ],
      ],
    );
  }

  // --- 2. واجهة الهاتف مع التبويبات ودعم فتح إعدادات الترويسة ---
  Widget _buildMobileLayout(BuildContext context) {
    final editorProvider = context.watch<EditorProvider>();
    final isEditingBlock = editorProvider.selectedBlockId != null;
    bool onEditor = true;
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // شريط علوي تفاعلي (الضغط على العنوان يفتح إعدادات الترويسة فوراً)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 4.0,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        const FontFamilyPopup(),

                        const SizedBox(width: 6),

                        const FontWeightPopup(),
                        const FontSizeButton(),
                      ],
                    ),
                  ),
                ),
                Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(Icons.more_vert, color: Color(0xFF334155)),
                    tooltip: 'خيارات المستند',

                    onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                  ),
                ),
              ],
            ),
          ),
          // تبويبات التنقل
          Container(
            color: Colors.white,
            child: TabBar(
              labelColor: Theme.of(context).primaryColor,
              indicatorColor: Theme.of(context).primaryColor,
              indicatorSize: TabBarIndicatorSize.tab,
              onTap: (value) {
                if (value == 1) {
                  final pdfPreviewState =
                      EditorScreen.PdfPreviewsKey.currentState;
                  if (pdfPreviewState != null) {
                    pdfPreviewState.refreshDoc(
                      ' حفظ التغيرات على معاينة Pdf ...',
                    );
                  }

                  onEditor = false;
                }
              },
              tabs: const [
                Tab(icon: Icon(Icons.edit_note, size: 20), text: 'المحرر'),
                Tab(
                  icon: Icon(Icons.preview_outlined, size: 20),
                  text: 'معاينة A4',
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          const BlockCanvas(),
                          // فتح لوحة الخصائص للكتلة أو لإعدادات الترويسة
                          if (editorProvider.isInspectorOpen)
                            Positioned.fill(
                              child: Container(
                                color: Colors.white,
                                child: Column(
                                  children: [
                                    AppBar(
                                      elevation: 0,
                                      backgroundColor: const Color(0xFFF8FAFC),
                                      title: Text(
                                        isEditingBlock
                                            ? 'خصائص الكتلة'
                                            : 'إعدادات الترويسة والمستند',
                                        style: const TextStyle(
                                          fontSize: 14.0,
                                          color: Color(0xFF0F172A),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      leading: IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.black87,
                                        ),
                                        onPressed: () => editorProvider
                                            .setInspectorOpen(false),
                                      ),
                                    ),
                                    const Expanded(child: InspectorPanel()),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (onEditor) _buildMobileBottomBar(context),
                  ],
                ),
                PdfPreviews(key: PdfPreviewsKey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. الشريط السفلي للهاتف ---
  Widget _buildMobileBottomBar(BuildContext context) {
    final docProvider = context.read<DocumentProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
        border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // زر التراجع
            IconButton.filledTonal(
              onPressed: docProvider.canUndo ? () => docProvider.undo() : null,
              icon: const Icon(Icons.undo, size: 20),
              tooltip: 'تراجع',
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFF1F5F9),
                foregroundColor: const Color(0xFF334155),
              ),
            ),

            // زر إضافة كتلة الأوسط
            AddBlockDialog(),
            // زر التقدم
            IconButton.filledTonal(
              onPressed: docProvider.canRedo ? () => docProvider.redo() : null,
              icon: const Icon(Icons.redo, size: 20),
              tooltip: 'التقدم',
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFF1F5F9),
                foregroundColor: const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 4. القائمة الجانبية للأدوات ---
  Widget _buildMobileDrawer(BuildContext context) {
    final editorProvider = context.read<EditorProvider>();
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: const Text(
                'أدوات وخيارات المستند',
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.tune_outlined,
                      color: Colors.blueAccent,
                    ),
                    title: const Text('إعدادات الترويسة والمستند'),
                    onTap: () {
                      Navigator.pop(context);
                      editorProvider.deselectBlock();
                      editorProvider.setInspectorOpen(true);
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.save_alt, color: Colors.teal),
                    title: const Text('تصدير ملف PDF'),
                    onTap: () {
                      Navigator.pop(context);
                      ProjectStorageService.exportPdf(context);
                    },
                  ),

                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.save_outlined),
                    title: const Text('حفظ المشروع كـ JSON'),

                    onTap: () {
                      Navigator.pop(context);
                      ProjectStorageService.exportJsonProject(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.folder_open_outlined),
                    title: const Text('فتح مشروع JSON'),
                    onTap: () {
                      Navigator.pop(context);
                      ProjectStorageService.importJsonProject(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.folder_open_outlined,
                      color: Colors.redAccent,
                    ),
                    title: const Text('مسح مستند  '),
                    onTap: () {
                      Navigator.pop(context);
                      ProjectStorageService.confirmClearDocument(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} // --- 5. نافذة إضافة الكتل المعيارية ---
