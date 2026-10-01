class DocumentMetadata {
  final String title;
  final String subtitle;
  final String lessonNumber;
  final String courseName;
  final String unit;
  final String author;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final Map<String, dynamic> customProperties;

  const DocumentMetadata({
    required this.title,
    this.subtitle = '',
    this.lessonNumber = '01',
    this.courseName = '',
    this.unit = '',
    this.author = '',
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.customProperties = const {},
  });

  DocumentMetadata copyWith({
    String? title,
    String? subtitle,
    String? lessonNumber,
    String? courseName,
    String? unit,
    String? author,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    Map<String, dynamic>? customProperties,
  }) {
    return DocumentMetadata(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      lessonNumber: lessonNumber ?? this.lessonNumber,
      courseName: courseName ?? this.courseName,
      unit: unit ?? this.unit,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      customProperties: customProperties ?? this.customProperties,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'subtitle': subtitle,
    'lessonNumber': lessonNumber,
    'courseName': courseName,
    'unit': unit,
    'author': author,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'tags': tags,
    'customProperties': customProperties,
  };

  factory DocumentMetadata.fromJson(Map<String, dynamic> json) =>
      DocumentMetadata(
        title: json['title'] as String? ?? 'عنوان الدرس التعليمي',
        subtitle: json['subtitle'] as String? ?? '',
        lessonNumber: json['lessonNumber'] as String? ?? '01',
        courseName: json['courseName'] as String? ?? '',
        unit: json['unit'] as String? ?? '',
        author: json['author'] as String? ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
            : DateTime.now(),
        tags:
            (json['tags'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        customProperties:
            json['customProperties'] as Map<String, dynamic>? ?? const {},
      );
}
