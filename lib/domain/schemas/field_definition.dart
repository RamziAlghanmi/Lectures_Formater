import 'field_type.dart';

class FieldOption {
  final String label;
  final dynamic value;

  const FieldOption({
    required this.label,
    required this.value,
  });

  Map<String, dynamic> toJson() => {
    'label': label,
    'value': value,
  };

  factory FieldOption.fromJson(Map<String, dynamic> json) => FieldOption(
    label: json['label'] as String,
    value: json['value'],
  );
}

class FieldValidationRules {
  final bool isRequired;
  final num? minValue;
  final num? maxValue;
  final int? minLength;
  final int? maxLength;
  final String? regexPattern;

  const FieldValidationRules({
    this.isRequired = false,
    this.minValue,
    this.maxValue,
    this.minLength,
    this.maxLength,
    this.regexPattern,
  });

  Map<String, dynamic> toJson() => {
    'isRequired': isRequired,
    if (minValue != null) 'minValue': minValue,
    if (maxValue != null) 'maxValue': maxValue,
    if (minLength != null) 'minLength': minLength,
    if (maxLength != null) 'maxLength': maxLength,
    if (regexPattern != null) 'regexPattern': regexPattern,
  };

  factory FieldValidationRules.fromJson(Map<String, dynamic> json) =>
      FieldValidationRules(
        isRequired: json['isRequired'] as bool? ?? false,
        minValue: json['minValue'] as num?,
        maxValue: json['maxValue'] as num?,
        minLength: json['minLength'] as int?,
        maxLength: json['maxLength'] as int?,
        regexPattern: json['regexPattern'] as String?,
      );
}

class FieldDefinition {
  final String key;
  final String label;
  final FieldType type;
  final dynamic defaultValue;
  final String? placeholder;
  final String? description;
  final List<FieldOption>? options;
  final FieldValidationRules validation;
  final List<FieldDefinition>? subFields;

  const FieldDefinition({
    required this.key,
    required this.label,
    required this.type,
    this.defaultValue,
    this.placeholder,
    this.description,
    this.options,
    this.validation = const FieldValidationRules(),
    this.subFields,
  });

  Map<String, dynamic> toJson() => {
    'key': key,
    'label': label,
    'type': type.name,
    if (defaultValue != null) 'defaultValue': defaultValue,
    if (placeholder != null) 'placeholder': placeholder,
    if (description != null) 'description': description,
    if (options != null) 'options': options!.map((o) => o.toJson()).toList(),
    'validation': validation.toJson(),
    if (subFields != null)
      'subFields': subFields!.map((f) => f.toJson()).toList(),
  };

  factory FieldDefinition.fromJson(Map<String, dynamic> json) =>
      FieldDefinition(
        key: json['key'] as String,
        label: json['label'] as String,
        type: FieldType.fromString(json['type'] as String),
        defaultValue: json['defaultValue'],
        placeholder: json['placeholder'] as String?,
        description: json['description'] as String?,
        options: json['options'] != null
            ? (json['options'] as List)
                .map((o) => FieldOption.fromJson(o as Map<String, dynamic>))
                .toList()
            : null,
        validation: json['validation'] != null
            ? FieldValidationRules.fromJson(
                json['validation'] as Map<String, dynamic>)
            : const FieldValidationRules(),
        subFields: json['subFields'] != null
            ? (json['subFields'] as List)
                .map((f) => FieldDefinition.fromJson(f as Map<String, dynamic>))
                .toList()
            : null,
      );
}
