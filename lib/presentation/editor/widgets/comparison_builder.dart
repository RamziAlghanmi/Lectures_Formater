import 'package:flutter/material.dart';
import 'package:lecture_formater/domain/entities/block_node.dart';

class ComparisonBuilder extends StatelessWidget {
  final BlockNode node;

  const ComparisonBuilder({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    final isRtl = (node.layoutRules.textDirection ?? 'rtl') != 'ltr';
    final textDirection = isRtl ? TextDirection.rtl : TextDirection.ltr;

    final aTitle = (node.fields['itemATitle'] as String?)?.trim() ?? 'الخيار A';
    final aContent = (node.fields['itemAContent'] as String?)?.trim() ?? '';
    final bTitle = (node.fields['itemBTitle'] as String?)?.trim() ?? 'الخيار B';
    final bContent = (node.fields['itemBContent'] as String?)?.trim() ?? '';
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Directionality(
      textDirection: textDirection,
      child: Container(
        margin: EdgeInsets.only(
          top: node.layoutRules.spaceBefore,
          bottom: node.layoutRules.spaceAfter,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildComparisonItem(
                title: aTitle,
                content: aContent,
                primaryColor: primaryColor,
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: _buildComparisonItem(
                title: bTitle,
                content: bContent,
                primaryColor: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonItem({
    required String title,
    required String content,
    required Color primaryColor,
  }) {
    final lines = content
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final isMultiLine = lines.length > 1;

    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: primaryColor,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6.0),
          if (lines.isEmpty)
            Text(
              'اكتب المحتوى هنا...',
              style: TextStyle(fontSize: 12.0, color: Colors.grey[400]),
            )
          else if (!isMultiLine)
            Text(
              lines.first,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF334155),
                height: 1.4,
              ),
            )
          else
            ...lines.map((line) {
              final cleanLine = line.replaceFirst(RegExp(r'^[•\-\*]\s*'), '');
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 2.0,
                  horizontal: 6.0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(color: primaryColor, fontSize: 13.7),
                    ),
                    Expanded(
                      child: Text(
                        cleanLine,
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: Color(0xFF334155),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
