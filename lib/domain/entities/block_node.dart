import '../schemas/block_schema.dart';

class CustomInsets {
  final double top;
  final double bottom;
  final double left;
  final double right;

  const CustomInsets({
    this.top = 0.0,
    this.bottom = 0.0,
    this.left = 0.0,
    this.right = 0.0,
  });

  const CustomInsets.all(double value)
      : top = value,
        bottom = value,
        left = value,
        right = value;

  const CustomInsets.symmetric({double vertical = 0.0, double horizontal = 0.0})
      : top = vertical,
        bottom = vertical,
        left = horizontal,
        right = horizontal;

  Map<String, dynamic> toJson() => {
    'top': top,
    'bottom': bottom,
    'left': left,
    'right': right,
  };

  factory CustomInsets.fromJson(Map<String, dynamic> json) => CustomInsets(
    top: (json['top'] as num?)?.toDouble() ?? 0.0,
    bottom: (json['bottom'] as num?)?.toDouble() ?? 0.0,
    left: (json['left'] as num?)?.toDouble() ?? 0.0,
    right: (json['right'] as num?)?.toDouble() ?? 0.0,
  );
}

class BlockStyleOverride {
  final int? customColor;
  final int? customBackgroundColor;
  final double? customBorderRadius;
  final CustomInsets? customPadding;
  final CustomInsets? customMargin;
  final double? fontSizeMultiplier;
  final String? alignment;

  const BlockStyleOverride({
    this.customColor,
    this.customBackgroundColor,
    this.customBorderRadius,
    this.customPadding,
    this.customMargin,
    this.fontSizeMultiplier,
    this.alignment,
  });

  BlockStyleOverride copyWith({
    int? customColor,
    int? customBackgroundColor,
    double? customBorderRadius,
    CustomInsets? customPadding,
    CustomInsets? customMargin,
    double? fontSizeMultiplier,
    String? alignment,
  }) {
    return BlockStyleOverride(
      customColor: customColor ?? this.customColor,
      customBackgroundColor:
          customBackgroundColor ?? this.customBackgroundColor,
      customBorderRadius: customBorderRadius ?? this.customBorderRadius,
      customPadding: customPadding ?? this.customPadding,
      customMargin: customMargin ?? this.customMargin,
      fontSizeMultiplier: fontSizeMultiplier ?? this.fontSizeMultiplier,
      alignment: alignment ?? this.alignment,
    );
  }

  Map<String, dynamic> toJson() => {
    if (customColor != null) 'customColor': customColor,
    if (customBackgroundColor != null)
      'customBackgroundColor': customBackgroundColor,
    if (customBorderRadius != null) 'customBorderRadius': customBorderRadius,
    if (customPadding != null) 'customPadding': customPadding!.toJson(),
    if (customMargin != null) 'customMargin': customMargin!.toJson(),
    if (fontSizeMultiplier != null) 'fontSizeMultiplier': fontSizeMultiplier,
    if (alignment != null) 'alignment': alignment,
  };

  factory BlockStyleOverride.fromJson(Map<String, dynamic> json) =>
      BlockStyleOverride(
        customColor: json['customColor'] as int?,
        customBackgroundColor: json['customBackgroundColor'] as int?,
        customBorderRadius:
            (json['customBorderRadius'] as num?)?.toDouble(),
        customPadding: json['customPadding'] != null
            ? CustomInsets.fromJson(
                json['customPadding'] as Map<String, dynamic>)
            : null,
        customMargin: json['customMargin'] != null
            ? CustomInsets.fromJson(
                json['customMargin'] as Map<String, dynamic>)
            : null,
        fontSizeMultiplier:
            (json['fontSizeMultiplier'] as num?)?.toDouble(),
        alignment: json['alignment'] as String?,
      );
}

class BlockNode {
  final String id;
  final String type;
  final String? title;
  final Map<String, dynamic> fields;
  final List<BlockNode> children;
  final BlockStyleOverride style;
  final BlockLayoutRules layoutRules;
  final Map<String, dynamic> metadata;

  const BlockNode({
    required this.id,
    required this.type,
    this.title,
    this.fields = const {},
    this.children = const [],
    this.style = const BlockStyleOverride(),
    this.layoutRules = const BlockLayoutRules(),
    this.metadata = const {},
  });

  BlockNode copyWith({
    String? id,
    String? type,
    String? title,
    Map<String, dynamic>? fields,
    List<BlockNode>? children,
    BlockStyleOverride? style,
    BlockLayoutRules? layoutRules,
    Map<String, dynamic>? metadata,
  }) {
    return BlockNode(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      fields: fields ?? this.fields,
      children: children ?? this.children,
      style: style ?? this.style,
      layoutRules: layoutRules ?? this.layoutRules,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    if (title != null) 'title': title,
    'fields': fields,
    'children': children.map((c) => c.toJson()).toList(),
    'style': style.toJson(),
    'layoutRules': layoutRules.toJson(),
    'metadata': metadata,
  };

  factory BlockNode.fromJson(Map<String, dynamic> json) => BlockNode(
    id: json['id'] as String,
    type: json['type'] as String,
    title: json['title'] as String?,
    fields: json['fields'] as Map<String, dynamic>? ?? const {},
    children: json['children'] != null
        ? (json['children'] as List)
            .map((c) => BlockNode.fromJson(c as Map<String, dynamic>))
            .toList()
        : const [],
    style: json['style'] != null
        ? BlockStyleOverride.fromJson(json['style'] as Map<String, dynamic>)
        : const BlockStyleOverride(),
    layoutRules: json['layoutRules'] != null
        ? BlockLayoutRules.fromJson(
            json['layoutRules'] as Map<String, dynamic>)
        : const BlockLayoutRules(),
    metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
  );
}
