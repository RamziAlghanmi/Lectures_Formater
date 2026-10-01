import 'package:flutter/material.dart';

import '../../../../../core/constants/block_types.dart';
import '../../../../../domain/entities/block_node.dart';

class CalloutBuilder extends StatelessWidget {
  final BlockNode node;

  const CalloutBuilder({super.key, required this.node});

  String _getDefaultTitle(String type) => switch (type) {
    BlockTypes.note => 'ملاحظة',
    BlockTypes.information => 'معلومة',
    BlockTypes.tip => 'نصيحة',
    BlockTypes.warning => 'تحذير',
    BlockTypes.error => 'خطأ برمجي',
    BlockTypes.important => 'هام جداً',
    BlockTypes.bestPractice => 'أفضل ممارسة',
    _ => 'تنبيه',
  };

  _CalloutColorPalette _getCalloutColors(String type) => switch (type) {
    BlockTypes.tip || BlockTypes.bestPractice => const _CalloutColorPalette(
      accentColor: Color(0xFF0D9488), // Teal
      backgroundColor: Color(0xFFF0FDFA),
      borderColor: Color(0xFFCCFBF1),
    ),
    BlockTypes.warning => const _CalloutColorPalette(
      accentColor: Color(0xFFD97706), // Amber
      backgroundColor: Color(0xFFFFFBEB),
      borderColor: Color(0xFFFEF3C7),
    ),
    BlockTypes.error => const _CalloutColorPalette(
      accentColor: Color(0xFFDC2626), // Red
      backgroundColor: Color(0xFFFEF2F2),
      borderColor: Color(0xFFFEE2E2),
    ),
    BlockTypes.important => const _CalloutColorPalette(
      accentColor: Color(0xFF7C3AED), // Purple
      backgroundColor: Color(0xFFF5F3FF),
      borderColor: Color(0xFFEDE9FE),
    ),
    _ => const _CalloutColorPalette(
      accentColor: Color(0xFF2563EB), // Blue
      backgroundColor: Color(0xFFEFF6FF),
      borderColor: Color(0xFFDBEAFE),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final isRtl = (node.layoutRules.textDirection ?? 'rtl') != 'ltr';
    final textDirection = isRtl ? TextDirection.rtl : TextDirection.ltr;

    // 1. معالجة العنوان
    final rawTitle = (node.fields['title'] as String?)?.trim() ?? '';
    final title = rawTitle.isNotEmpty ? rawTitle : _getDefaultTitle(node.type);

    // 2. معالجة المحتوى
    final rawContent = (node.fields['content'] as String?)?.trim() ?? '';
    final content = rawContent.isNotEmpty
        ? rawContent
        : 'اكتب نص $title هنا من لوحة الخصائص...';

    final colors = _getCalloutColors(node.type);

    return Directionality(
      textDirection: textDirection,
      child: Container(
        margin: EdgeInsets.only(
          top: node.layoutRules.spaceBefore,
          bottom: node.layoutRules.spaceAfter,
        ),
        decoration: BoxDecoration(
          color: colors.backgroundColor,
          borderRadius: BorderRadius.circular(6.0),
          border: Border.all(color: colors.borderColor, width: 1.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // الشريط الجانبي الملون (ينتقل لليمين في RTL ولليسار في LTR تلقائياً)
              Container(width: 4.5, color: colors.accentColor),
              // محتوى التنبيه
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 10.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (title.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                              color: colors.accentColor,
                            ),
                          ),
                        ),
                      Text(
                        content,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: rawContent.isNotEmpty
                              ? const Color(0xFF1E293B)
                              : Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalloutColorPalette {
  final Color accentColor;
  final Color backgroundColor;
  final Color borderColor;

  const _CalloutColorPalette({
    required this.accentColor,
    required this.backgroundColor,
    required this.borderColor,
  });
}
