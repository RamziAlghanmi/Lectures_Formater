import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../domain/schemas/field_definition.dart';
import '../../domain/schemas/field_type.dart';

class DynamicFieldFactory {
  const DynamicFieldFactory._();

  static Widget buildField({
    required String blockId,
    required FieldDefinition fieldDef,
    required dynamic currentValue,
    required ValueChanged<dynamic> onChanged,
  }) {
    switch (fieldDef.type) {
      case FieldType.text:
        return _DynamicTextFormField(
          key: ValueKey('${blockId}_${fieldDef.key}'),
          fieldDef: fieldDef,
          initialValue: currentValue?.toString() ?? '',
          maxLines: 1,
          onChanged: onChanged,
        );

      case FieldType.multiline:
        return _DynamicTextFormField(
          key: ValueKey('${blockId}_${fieldDef.key}'),
          fieldDef: fieldDef,
          initialValue: currentValue?.toString() ?? '',
          maxLines: 4,
          onChanged: onChanged,
        );

      case FieldType.code:
        return _DynamicTextFormField(
          key: ValueKey('${blockId}_${fieldDef.key}'),
          fieldDef: fieldDef,
          initialValue: currentValue?.toString() ?? '',
          maxLines: 6,
          isCode: true,
          onChanged: onChanged,
        );

      case FieldType.number:
        return _DynamicTextFormField(
          key: ValueKey('${blockId}_${fieldDef.key}'),
          fieldDef: fieldDef,
          initialValue: currentValue?.toString() ?? '0',
          maxLines: 1,
          isNumber: true,
          onChanged: (val) {
            final parsed = num.tryParse(val);
            if (parsed != null) onChanged(parsed);
          },
        );

      case FieldType.boolean:
        return _buildBooleanField(fieldDef, currentValue, onChanged);

      case FieldType.dropdown:
        return _buildDropdownField(fieldDef, currentValue, onChanged);

      case FieldType.imagePath:
        return _buildImagePickerField(fieldDef, currentValue, onChanged);

      case FieldType.list:
        return _buildListField(blockId, fieldDef, currentValue, onChanged);

      default:
        return _DynamicTextFormField(
          key: ValueKey('${blockId}_${fieldDef.key}'),
          fieldDef: fieldDef,
          initialValue: currentValue?.toString() ?? '',
          maxLines: 1,
          onChanged: onChanged,
        );
    }
  }

  static Widget _buildBooleanField(
    FieldDefinition fieldDef,
    dynamic currentValue,
    ValueChanged<dynamic> onChanged,
  ) {
    final isChecked = currentValue is bool
        ? currentValue
        : (fieldDef.defaultValue as bool? ?? false);
    return SwitchListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(
        fieldDef.label,
        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
      ),
      value: isChecked,
      onChanged: onChanged,
    );
  }

  static Widget _buildDropdownField(
    FieldDefinition fieldDef,
    dynamic currentValue,
    ValueChanged<dynamic> onChanged,
  ) {
    final options = fieldDef.options ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fieldDef.label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0),
        ),
        const SizedBox(height: 4.0),
        DropdownButtonFormField<dynamic>(
          value: currentValue ?? fieldDef.defaultValue,
          isDense: true,
          items: options.map((opt) {
            return DropdownMenuItem<dynamic>(
              value: opt.value,
              child: Text(opt.label, style: const TextStyle(fontSize: 12.5)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
        const SizedBox(height: 10.0),
      ],
    );
  }

  static Widget _buildImagePickerField(
    FieldDefinition fieldDef,
    dynamic currentValue,
    ValueChanged<dynamic> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fieldDef.label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0),
        ),
        const SizedBox(height: 4.0),
        OutlinedButton.icon(
          icon: const Icon(Icons.upload_file, size: 16.0),
          label: const Text('اختيار صورة من الجهاز'),
          onPressed: () async {
            final result = await FilePicker.pickFile(type: FileType.image);
            if (result != null) {
              final bytes = result.readAsBytes();

              final base64Str = base64Encode(await bytes);
              onChanged(base64Str);
            }
          },
        ),
        const SizedBox(height: 10.0),
      ],
    );
  }

  static Widget _buildListField(
    String blockId,
    FieldDefinition fieldDef,
    dynamic currentValue,
    ValueChanged<dynamic> onChanged,
  ) {
    final list = currentValue is List
        ? List<dynamic>.from(currentValue)
        : <dynamic>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              fieldDef.label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12.0,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.add_circle,
                size: 18.0,
                color: Colors.blue,
              ),
              visualDensity: VisualDensity.compact,
              onPressed: () {
                list.add('');
                onChanged(list);
              },
            ),
          ],
        ),
        ...list.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(
              children: [
                Expanded(
                  child: _DynamicTextFormField(
                    key: ValueKey('${blockId}_${fieldDef.key}_item_$idx'),
                    fieldDef: FieldDefinition(
                      key: 'item_$idx',
                      label: '',
                      type: FieldType.text,
                      placeholder: 'عنصر #${idx + 1}',
                    ),
                    initialValue: item.toString(),
                    maxLines: 1,
                    onChanged: (val) {
                      list[idx] = val;
                      onChanged(list);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    size: 16.0,
                    color: Colors.redAccent,
                  ),
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    list.removeAt(idx);
                    onChanged(list);
                  },
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 10.0),
      ],
    );
  }
}

// كلاس مساعد مستقل للحفاظ على التركيز ومؤشر الكتابة
class _DynamicTextFormField extends StatefulWidget {
  final FieldDefinition fieldDef;
  final String initialValue;
  final int maxLines;
  final bool isCode;
  final bool isNumber;
  final ValueChanged<String> onChanged;

  const _DynamicTextFormField({
    super.key,
    required this.fieldDef,
    required this.initialValue,
    required this.maxLines,
    this.isCode = false,
    this.isNumber = false,
    required this.onChanged,
  });

  @override
  State<_DynamicTextFormField> createState() => _DynamicTextFormFieldState();
}

class _DynamicTextFormFieldState extends State<_DynamicTextFormField> {
  late final TextEditingController _controller;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant _DynamicTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != _controller.text &&
        !(_debounceTimer?.isActive ?? false)) {
      _controller.text = widget.initialValue;
    }
  }

  void _onTextChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 180), () {
      widget.onChanged(value);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fieldWidget = TextFormField(
      controller: _controller,
      maxLines: widget.maxLines,
      keyboardType: widget.isNumber ? TextInputType.number : null,
      style: TextStyle(
        fontFamily: widget.isCode ? 'FiraCode' : null,
        fontSize: widget.isCode ? 11.5 : 12.5,
      ),
      decoration: InputDecoration(
        hintText: widget.fieldDef.placeholder,
        isDense: true,
      ),
      onChanged: _onTextChanged,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.fieldDef.label.isNotEmpty) ...[
          Text(
            widget.fieldDef.label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0),
          ),
          const SizedBox(height: 4.0),
        ],
        if (widget.isCode)
          Directionality(textDirection: TextDirection.ltr, child: fieldWidget)
        else
          fieldWidget,
        const SizedBox(height: 10.0),
      ],
    );
  }
}
