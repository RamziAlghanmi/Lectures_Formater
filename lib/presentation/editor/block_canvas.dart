import 'package:flutter/material.dart';
import 'package:lecture_formater/domain/entities/document_metadata.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/block_node.dart';
import '../providers/document_provider.dart';
import '../providers/editor_provider.dart';
import 'block_renderer.dart';

class BlockCanvas extends StatelessWidget {
  const BlockCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    final docProvider = context.watch<DocumentProvider>();
    final editorProvider = context.watch<EditorProvider>();
    final blocks = docProvider.document.blocks;
    final isHeaderSelected =
        editorProvider.selectedBlockId == null &&
        editorProvider.isInspectorOpen;

    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      header: _LessonHeaderCanvasCard(
        metadata: docProvider.document.metadata,
        isSelected: isHeaderSelected,
        onTap: () {
          editorProvider.deselectBlock();
          editorProvider.setInspectorOpen(true);
        },
      ),
      itemCount: blocks.length,
      onReorder: (oldIndex, newIndex) {
        final targetIndex = oldIndex < newIndex ? newIndex - 1 : newIndex;
        docProvider.moveBlock(oldIndex, targetIndex);
      },
      itemBuilder: (context, index) {
        final block = blocks[index];
        final isSelected = editorProvider.selectedBlockId == block.id;

        return _BlockCanvasItem(
          key: ValueKey(block.id),
          block: block,
          index: index,
          totalCount: blocks.length,
          isSelected: isSelected,
          onTap: () => editorProvider.selectBlock(block.id),
          onMoveUp: index > 0
              ? () => docProvider.moveBlockByDelta(block.id, -1)
              : null,
          onMoveDown: index < blocks.length - 1
              ? () => docProvider.moveBlockByDelta(block.id, 1)
              : null,
          onDelete: () => _confirmDeleteBlock(context, docProvider, block.id),
        );
      },
    );
  }

  Future<void> _confirmDeleteBlock(
    BuildContext context,
    DocumentProvider docProvider,
    String blockId,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFDC2626),
                size: 24,
              ),
              SizedBox(width: 8.0),
              Text(
                'تأكيد الحذف',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'هل أنت متأكد من رغبتك في حذف هذه الكتلة؟ لا يمكن التراجع عن هذا الإجراء.',
            style: TextStyle(fontSize: 14.0, color: Color(0xFF334155)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
              ),
              onPressed: () => Navigator.pop(dialogCtx, true),
              child: const Text('حذف الكتلة'),
            ),
          ],
        ),
      ),
    );

    if (shouldDelete == true) {
      docProvider.removeBlock(blockId);
    }
  }
}

class _BlockCanvasItem extends StatelessWidget {
  final BlockNode block;
  final int index;
  final int totalCount;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback onDelete;

  const _BlockCanvasItem({
    super.key,
    required this.block,
    required this.index,
    required this.totalCount,
    required this.isSelected,
    required this.onTap,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currentDirection = block.layoutRules.textDirection ?? 'rtl';
    final isRtl = currentDirection == 'rtl';

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : const Color(0xFFE2E8F0),
          width: isSelected ? 2.0 : 1.0,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary
                      .withOpacity(0.08),
                  blurRadius: 8.0,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Controls Bar
              Row(
                children: [
                  ReorderableDragStartListener(
                    index: index,
                    child: const MouseRegion(
                      cursor: SystemMouseCursors.grab,
                      child: Icon(
                        Icons.drag_indicator,
                        size: 18.0,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6.0),
                  Text(
                    '#${index + 1} ${block.title ?? block.type}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const Spacer(),
                  // زر تبديل اتجاه النص للكتلة (RTL / LTR)
                  IconButton(
                    icon: Icon(
                      isRtl
                          ? Icons.format_textdirection_r_to_l
                          : Icons.format_textdirection_l_to_r,
                      size: 18.0,
                      color: !isRtl
                          ? Theme.of(context).colorScheme.primary
                          : Colors.blueGrey[600],
                    ),
                    tooltip: isRtl
                        ? 'الاتجاه الحالي: من اليمين لليسار (اضغط للتحويل لـ LTR)'
                        : 'الاتجاه الحالي: من اليسار لليمين (اضغط للتحويل لـ RTL)',
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      final newDirection = isRtl ? 'ltr' : 'rtl';
                      context.read<DocumentProvider>().updateBlockLayoutRules(
                        block.id,
                        block.layoutRules.copyWith(textDirection: newDirection),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_up, size: 18.0),
                    visualDensity: VisualDensity.compact,
                    onPressed: onMoveUp,
                  ),
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down, size: 18.0),
                    visualDensity: VisualDensity.compact,
                    onPressed: onMoveDown,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 18.0,
                      color: Colors.redAccent,
                    ),
                    visualDensity: VisualDensity.compact,
                    onPressed: onDelete,
                  ),
                ],
              ),
              const Divider(height: 12.0),
              BlockRenderer(node: block),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonHeaderCanvasCard extends StatelessWidget {
  final DocumentMetadata metadata;
  final bool isSelected;
  final VoidCallback onTap;

  const _LessonHeaderCanvasCard({
    required this.metadata,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : const Color(0xFFE2E8F0),
          width: isSelected ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
                : Colors.black.withOpacity(0.02),
            blurRadius: 6.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Badges Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.school,
                          size: 16.0,
                          color: Color(0xFF3B82F6),
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          metadata.courseName.isNotEmpty
                              ? metadata.courseName
                              : 'اسم الدورة التعليمية',
                          style: const TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                        SizedBox(width: metadata.unit.isNotEmpty ? 12.0 : 0.0),
                      ],
                    ),
                    if (metadata.unit.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 2.0,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(4.0),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          metadata.unit,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8.0),

              // Title Row with Circle Number
              Row(
                children: [
                  Container(
                    width: 34.0,
                    height: 34.0,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3B82F6),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      metadata.lessonNumber.isNotEmpty
                          ? metadata.lessonNumber
                          : '01',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          metadata.title.isNotEmpty
                              ? metadata.title
                              : 'عنوان الدرس التعليمي',
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        if (metadata.subtitle.isNotEmpty)
                          Text(
                            metadata.subtitle,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
