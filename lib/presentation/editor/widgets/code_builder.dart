import 'package:flutter/material.dart';
import 'package:lecture_formater/core/utils/syntax_highlighter.dart';

class CodeBuilder extends StatelessWidget {
  final String title;
  final String lang;
  final String code;
  const CodeBuilder({
    super.key,
    required this.title,
    required this.lang,
    required this.code,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _MacDot(color: Colors.redAccent),
                  _MacDot(color: Colors.amber),
                  _MacDot(color: Colors.green),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      lang.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SelectableText.rich(
                SyntaxHighlighter.highlight(
                  code.isEmpty ? '// اكتب الشفرة البرمجية هنا...' : code,
                  lang,
                ),
                style: const TextStyle(
                  fontFamily: 'FiraCode',
                  fontSize: 13,
                  height: 1.5,
                ),
                textDirection: TextDirection.ltr,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _MacDot({required Color color}) {
    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
