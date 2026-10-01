import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../domain/entities/block_node.dart';

class TableBuilder extends StatelessWidget {
  final BlockNode node;

  const TableBuilder({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    final isRtl = (node.layoutRules.textDirection ?? 'rtl') != 'ltr';
    final textDirection = isRtl ? TextDirection.rtl : TextDirection.ltr;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final headers = _parseHeaders(node.fields['headers']);
    final rowsData = _parseRows(node.fields['rows']);
    final caption = (node.fields['caption'] as String?)?.trim() ?? '';

    int columnCount = headers.length;
    for (final row in rowsData) {
      if (row.length > columnCount) {
        columnCount = row.length;
      }
    }

    if (columnCount == 0 && rowsData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(6.0),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Text(
          'جدول فارغ (قم بإضافة الأعمدة والصفوف من لوحة الخصائص)',
          style: TextStyle(color: Colors.grey, fontSize: 13.0),
        ),
      );
    }

    return Directionality(
      textDirection: textDirection,
      child: Container(
        margin: EdgeInsets.only(
          top: node.layoutRules.spaceBefore,
          bottom: node.layoutRules.spaceAfter,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.0),
          border: Border.all(color: const Color(0xFFCBD5E1), width: 0.8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Table(
              border: TableBorder.all(
                color: const Color(0xFFCBD5E1),
                width: 0.8,
              ),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                // ترويسة الجدول
                if (headers.isNotEmpty)
                  TableRow(
                    decoration: BoxDecoration(color: primaryColor),
                    children: List.generate(columnCount, (colIdx) {
                      final title = colIdx < headers.length
                          ? headers[colIdx]
                          : '';
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 7.0,
                        ),
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }),
                  ),
                // صفوف البيانات
                ...List.generate(rowsData.length, (rowIdx) {
                  final row = rowsData[rowIdx];
                  final isEven = rowIdx % 2 == 0;
                  return TableRow(
                    decoration: BoxDecoration(
                      color: isEven ? Colors.white : const Color(0xFFF8FAFC),
                    ),
                    children: List.generate(columnCount, (colIdx) {
                      final cellText = colIdx < row.length ? row[colIdx] : '';
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 6.0,
                        ),
                        child: Text(
                          cellText,
                          style: const TextStyle(
                            fontSize: 12.0,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ],
            ),
            if (caption.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 6.0,
                ),
                color: const Color(0xFFF1F5F9),
                child: Text(
                  caption,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<String> _parseHeaders(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data
          .map((e) {
            if (e is Map) return (e['column_name'] ?? '').toString().trim();
            return e.toString().trim();
          })
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (data is String && data.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is List) return _parseHeaders(decoded);
      } catch (_) {}
      final delimiter = data.contains('|')
          ? '|'
          : (data.contains('،') ? '،' : ',');
      return data
          .split(delimiter)
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
  }

  List<List<String>> _parseRows(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.map((item) {
        if (item is List) {
          return item.map((cell) => cell.toString().trim()).toList();
        }
        if (item is Map) {
          return item.values.map((v) => v.toString().trim()).toList();
        }
        final str = item.toString().trim();
        final delimiter = str.contains('|')
            ? '|'
            : (str.contains('،') ? '،' : ',');
        return str.split(delimiter).map((c) => c.trim()).toList();
      }).toList();
    }
    if (data is String && data.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is List) return _parseRows(decoded);
      } catch (_) {}
      return data
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .map((line) {
            final delimiter = line.contains('|')
                ? '|'
                : (line.contains('،') ? '،' : ',');
            return line.split(delimiter).map((cell) => cell.trim()).toList();
          })
          .toList();
    }
    return [];
  }
}
