import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lecture_formater/presentation/editor/widgets/callout_builder.dart';
import 'package:lecture_formater/presentation/editor/widgets/code_builder.dart';
import 'package:lecture_formater/presentation/editor/widgets/comparison_builder.dart';
import 'package:lecture_formater/presentation/editor/widgets/function_builder.dart';
import 'package:lecture_formater/presentation/editor/widgets/table_builder.dart';

import '../../core/constants/block_types.dart';
import '../../domain/entities/block_node.dart';

class BlockRenderer extends StatelessWidget {
  final BlockNode node;

  const BlockRenderer({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    final isRtl = (node.layoutRules.textDirection ?? 'rtl') != 'ltr';
    final textDirection = isRtl ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: _buildContent(context, textDirection),
    );
  }

  Widget _buildContent(BuildContext context, TextDirection textDirection) {
    switch (node.type) {
      case BlockTypes.heading:
        final text = node.fields['text'] as String? ?? '';
        final level = node.fields['level'] as String? ?? 'h1';
        final size = switch (level) {
          'h1' => 20.0,
          'h2' => 17.0,
          _ => 15.0,
        };
        return Text(
          text.isEmpty ? 'عنوان فارغ' : text,
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.bold,
            color: text.isEmpty ? Colors.grey : const Color(0xFF1E3A8A),
          ),
        );

      case BlockTypes.paragraph:
        final title = node.fields['title'] as String? ?? '';
        final text = node.fields['content'] as String? ?? '';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: title.isEmpty
                        ? Colors.grey
                        : const Color(0xFF334155),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                text.isEmpty ? 'انقر لكتابة نص الفقرة والشرح...' : text,
                style: TextStyle(
                  fontSize: 14,
                  color: text.isEmpty ? Colors.grey : const Color(0xFF334155),
                  height: 1.5,
                ),
              ),
            ),
          ],
        );

      case BlockTypes.bulletList:
      case BlockTypes.numberedList:
        final title = node.fields['title'] as String? ?? '';
        final itemsRaw = node.fields['items'];
        final items = itemsRaw is List ? itemsRaw : <dynamic>[];
        final isNumbered = node.type == BlockTypes.numberedList;
        final startingIndex = node.fields['startingIndex'] as int? ?? 1;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ),
            if (items.isEmpty)
              const Text(
                'قائمة فارغة - أضف عناصر من لوحة الخصائص',
                style: TextStyle(color: Colors.grey, fontSize: 12.5),
              )
            else
              ...List.generate(items.length, (idx) {
                final rawItem = items[idx];
                final itemText = rawItem is Map
                    ? (rawItem['item_text'] ?? '').toString()
                    : rawItem.toString();
                final number = startingIndex + idx;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 2.0,
                    horizontal: 8.0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: isNumbered ? 24.0 : 10.0,
                        child: Text(
                          isNumbered ? '$number- ' : '•',
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                      ),

                      Expanded(
                        child: Text(
                          itemText.isEmpty ? 'عنصر فارغ' : itemText,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: itemText.isEmpty
                                ? Colors.grey
                                : const Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        );

      case BlockTypes.table:
        return TableBuilder(node: node);

      case BlockTypes.code:
        final code = node.fields['code'] as String? ?? '';
        final lang = node.fields['language'] as String? ?? 'code';
        final fileName = node.fields['fileName'] as String? ?? '';

        return CodeBuilder(title: fileName, lang: lang, code: code);

      case BlockTypes.note:
      case BlockTypes.information:
      case BlockTypes.tip:
      case BlockTypes.warning:
      case BlockTypes.error:
      case BlockTypes.important:
      case BlockTypes.bestPractice:
        return CalloutBuilder(node: node);

      case BlockTypes.comparison:
        return ComparisonBuilder(node: node);

      case BlockTypes.functionDoc:
        print("functionDoc block detected");
        return FunctionBuilder(node: node);

      case BlockTypes.image:
        final base64Str = node.fields['bytesBase64'] as String? ?? '';
        final caption = node.fields['caption'] as String? ?? '';
        return Column(
          children: [
            if (base64Str.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(6.0),
                child: Image.memory(
                  base64Decode(
                    base64Str.contains(',')
                        ? base64Str.split(',').last
                        : base64Str,
                  ),
                  height: 140,
                  fit: BoxFit.contain,
                ),
              )
            else
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: const Center(
                  child: Icon(Icons.image, color: Colors.grey),
                ),
              ),
            if (caption.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  caption,
                  style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                ),
              ),
          ],
        );

      default:
        return Text(
          node.title ?? node.type,
          style: const TextStyle(fontSize: 13.0),
        );
    }
  }
}
