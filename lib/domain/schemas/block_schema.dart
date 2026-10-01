import 'field_definition.dart';

enum BreakPriority { high, medium, low, never }

class BlockLayoutRules {
  final bool keepTogether;
  final bool allowSplit;
  final BreakPriority breakPriority;
  final double spaceBefore;
  final double spaceAfter;
  final bool keepWithNext;
  final bool forcePageBreakBefore;
  final String? textDirection;

  const BlockLayoutRules({
    this.keepTogether = false,
    this.allowSplit = true,
    this.breakPriority = BreakPriority.medium,
    this.spaceBefore = 4.0,
    this.spaceAfter = 2.0,
    this.keepWithNext = false,
    this.forcePageBreakBefore = false,
    this.textDirection = 'rtl',
  });
  String get safeDirection => textDirection ?? 'rtl';
  BlockLayoutRules copyWith({
    bool? keepTogether,
    bool? allowSplit,
    BreakPriority? breakPriority,
    double? spaceBefore,
    double? spaceAfter,
    bool? keepWithNext,
    bool? forcePageBreakBefore,
    String? textDirection,
  }) {
    return BlockLayoutRules(
      keepTogether: keepTogether ?? this.keepTogether,
      allowSplit: allowSplit ?? this.allowSplit,
      breakPriority: breakPriority ?? this.breakPriority,
      spaceBefore: spaceBefore ?? this.spaceBefore,
      spaceAfter: spaceAfter ?? this.spaceAfter,
      keepWithNext: keepWithNext ?? this.keepWithNext,
      forcePageBreakBefore: forcePageBreakBefore ?? this.forcePageBreakBefore,
      textDirection: textDirection ?? this.textDirection,
    );
  }

  Map<String, dynamic> toJson() => {
    'keepTogether': keepTogether,
    'allowSplit': allowSplit,
    'breakPriority': breakPriority.name,
    'spaceBefore': spaceBefore,
    'spaceAfter': spaceAfter,
    'keepWithNext': keepWithNext,
    'forcePageBreakBefore': forcePageBreakBefore,
    'textDirection': textDirection,
  };

  factory BlockLayoutRules.fromJson(Map<String, dynamic> json) =>
      BlockLayoutRules(
        keepTogether: json['keepTogether'] as bool? ?? false,
        allowSplit: json['allowSplit'] as bool? ?? true,
        breakPriority: BreakPriority.values.firstWhere(
          (e) => e.name == json['breakPriority'],
          orElse: () => BreakPriority.medium,
        ),
        spaceBefore: (json['spaceBefore'] as num?)?.toDouble() ?? 4.0,
        spaceAfter: (json['spaceAfter'] as num?)?.toDouble() ?? 2.0,
        keepWithNext: json['keepWithNext'] as bool? ?? false,
        forcePageBreakBefore: json['forcePageBreakBefore'] as bool? ?? false,
        textDirection: (json['textDirection'] as String?) ?? 'rtl',
      );
}

class BlockSchema {
  final String type;
  final String displayName;
  final String icon;
  final String category;
  final BlockLayoutRules defaultLayoutRules;
  final List<FieldDefinition> fields;

  const BlockSchema({
    required this.type,
    required this.displayName,
    required this.icon,
    required this.category,
    this.defaultLayoutRules = const BlockLayoutRules(),
    required this.fields,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'displayName': displayName,
    'icon': icon,
    'category': category,
    'defaultLayoutRules': defaultLayoutRules.toJson(),
    'fields': fields.map((f) => f.toJson()).toList(),
  };

  factory BlockSchema.fromJson(Map<String, dynamic> json) => BlockSchema(
    type: json['type'] as String,
    displayName: json['displayName'] as String,
    icon: json['icon'] as String,
    category: json['category'] as String,
    defaultLayoutRules: json['defaultLayoutRules'] != null
        ? BlockLayoutRules.fromJson(
            json['defaultLayoutRules'] as Map<String, dynamic>,
          )
        : const BlockLayoutRules(),
    fields: (json['fields'] as List)
        .map((f) => FieldDefinition.fromJson(f as Map<String, dynamic>))
        .toList(),
  );
}
