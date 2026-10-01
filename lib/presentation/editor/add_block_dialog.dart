import 'package:flutter/material.dart';
import 'package:lecture_formater/core/constants/default_schemas.dart';
import 'package:lecture_formater/domain/entities/block_node.dart';
import 'package:lecture_formater/domain/schemas/block_schema.dart';
import 'package:lecture_formater/presentation/providers/document_provider.dart';
import 'package:lecture_formater/presentation/providers/editor_provider.dart';
import 'package:provider/provider.dart';

class AddBlockDialog extends StatelessWidget {
  const new({super.key});
  void _showAddBlockDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (ctx) {
        final categories = <String, List<BlockSchema>>{};
        for (final schema in DefaultSchemas.allSchemas) {
          categories.putIfAbsent(schema.category, () => []).add(schema);
        }

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            height: MediaQuery.of(ctx).size.height * 0.75,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'إضافة كتلة جديدة إلى المحاضرة',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    children: categories.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 13.0,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(ctx).colorScheme.primary,
                              ),
                            ),
                          ),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: entry.value.map((schema) {
                              return ActionChip(
                                avatar: const Icon(
                                  Icons.add_circle_outline,
                                  size: 16.0,
                                ),
                                label: Text(schema.displayName),
                                onPressed: () {
                                  final newId =
                                      'block_${DateTime.now().millisecondsSinceEpoch}';
                                  final initialFields = <String, dynamic>{};
                                  for (final f in schema.fields) {
                                    if (f.defaultValue != null) {
                                      initialFields[f.key] = f.defaultValue;
                                    }
                                  }

                                  final newBlock = BlockNode(
                                    id: newId,
                                    type: schema.type,
                                    title: schema.displayName,
                                    fields: initialFields,
                                    layoutRules: schema.defaultLayoutRules,
                                  );

                                  context.read<DocumentProvider>().addBlock(
                                    newBlock,
                                  );
                                  context.read<EditorProvider>().selectBlock(
                                    newId,
                                  );
                                  Navigator.pop(ctx);
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12.0),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return InkWell(
      onTap: () => _showAddBlockDialog(context),
      borderRadius: BorderRadius.circular(24.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, primaryColor.withOpacity(0.85)],
          ),
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Colors.white, size: 20),
            SizedBox(width: 8.0),
            Text(
              'إضافة كتلة',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
