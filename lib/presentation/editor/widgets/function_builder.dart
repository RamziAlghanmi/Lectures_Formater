import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../domain/entities/block_node.dart';

class FunctionBuilder extends StatelessWidget {
  final BlockNode node;

  const FunctionBuilder({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    final isRtl = (node.layoutRules.textDirection ?? 'rtl') != 'ltr';
    final textDirection = isRtl ? TextDirection.rtl : TextDirection.ltr;
    final primaryColor = Theme.of(context).colorScheme.primary;
    print("functionDoc block detected");
    final name = (node.fields['name'] as String?)?.trim() ?? 'functionName';
    final returnType = (node.fields['returnType'] as String?)?.trim() ?? 'void';
    final signature =
        (node.fields['signature'] as String?)?.trim() ?? '$returnType $name()';
    final description = (node.fields['description'] as String?)?.trim() ?? '';
    final returnsDesc = (node.fields['returns'] as String?)?.trim() ?? '';
    final parameters = _parseParameters(node.fields['parameters']);
    final example =
        (node.fields['example'] as String?)?.trim() ??
        (node.fields['exampleCode'] as String?)?.trim() ??
        (node.fields['code'] as String?)?.trim() ??
        '';
    return Directionality(
      textDirection: textDirection,
      child: Container(
        margin: EdgeInsets.only(
          top: node.layoutRules.spaceBefore,
          bottom: node.layoutRules.spaceAfter,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(6.0),
          border: Border.all(color: const Color(0xFFCBD5E1), width: 0.8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. شريط توقيع الدالة البرمجية
            Directionality(
              textDirection: TextDirection.ltr,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                color: const Color(0xFF1E1E2E),
                child: Row(
                  children: [
                    Text(
                      returnType,
                      style: const TextStyle(
                        fontFamily: 'FiraCode',
                        fontSize: 13.0,
                        color: Color(0xFF89B4FA),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        signature.startsWith(returnType)
                            ? signature.substring(returnType.length).trim()
                            : signature,
                        style: const TextStyle(
                          fontFamily: 'FiraCode',
                          fontSize: 13.0,
                          color: Color(0xFFF9E2AF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. المحتوى الداخلي
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (description.isNotEmpty) ...[
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Color(0xFF334155),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                  ],

                  if (parameters.isNotEmpty) ...[
                    Text(
                      isRtl ? 'المعاملات (Parameters):' : 'Parameters:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Table(
                      border: TableBorder.all(
                        color: const Color(0xFFCBD5E1),
                        width: 0.6,
                      ),
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: [
                        TableRow(
                          decoration: const BoxDecoration(
                            color: Color(0xFFE2E8F0),
                          ),
                          children: [
                            _buildHeaderCell(isRtl ? 'المعامل' : 'Parameter'),
                            _buildHeaderCell(isRtl ? 'النوع' : 'Type'),
                            _buildHeaderCell(isRtl ? 'الوصف' : 'Description'),
                          ],
                        ),
                        ...parameters.map((p) {
                          return TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Text(
                                  p.name,
                                  style: const TextStyle(
                                    fontFamily: 'FiraCode',
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Text(
                                  p.type,
                                  style: const TextStyle(
                                    fontFamily: 'FiraCode',
                                    fontSize: 13.5,
                                    color: Color(0xFF0284C7),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Text(
                                  p.description,
                                  style: const TextStyle(
                                    fontSize: 13.0,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                  ],

                  if (returnsDesc.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isRtl ? 'القيمة المعادة: ' : 'Returns: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                            color: primaryColor,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            returnsDesc,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // داخل Column الخاص بمعاينة البطاقة:
                  if (example.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      isRtl ? 'مثال الاستخدام (Example):' : 'Example:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E2E),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        example,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
                          fontFamily: 'FiraCode',
                          fontSize: 12.5,
                          color: Color(0xFFCDD6F4),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11.5,
          color: Color(0xFF1E293B),
        ),
      ),
    );
  }

  List<_ParamItem> _parseParameters(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data
          .map((item) {
            if (item is Map) {
              return _ParamItem(
                name: (item['name'] ?? '').toString().trim(),
                type: (item['type'] ?? '').toString().trim(),
                description: (item['description'] ?? '').toString().trim(),
              );
            }
            final str = item.toString().trim();
            final parts = str
                .split(RegExp(r'[|,،]'))
                .map((e) => e.trim())
                .toList();
            return _ParamItem(
              name: parts.isNotEmpty ? parts[0] : '',
              type: parts.length > 1 ? parts[1] : '',
              description: parts.length > 2 ? parts.sublist(2).join(' ') : '',
            );
          })
          .where((p) => p.name.isNotEmpty)
          .toList();
    }
    if (data is String && data.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is List) return _parseParameters(decoded);
      } catch (_) {}
      return data
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .map((line) {
            final delimiter = line.contains('|')
                ? '|'
                : (line.contains('،') ? '،' : ',');
            final parts = line.split(delimiter).map((c) => c.trim()).toList();
            return _ParamItem(
              name: parts.isNotEmpty ? parts[0] : '',
              type: parts.length > 1 ? parts[1] : '',
              description: parts.length > 2 ? parts.sublist(2).join(' ') : '',
            );
          })
          .where((p) => p.name.isNotEmpty)
          .toList();
    }
    return [];
  }
}

class _ParamItem {
  final String name;
  final String type;
  final String description;

  const _ParamItem({
    required this.name,
    required this.type,
    required this.description,
  });
}
