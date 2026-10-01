// enum PreflightSeverity {
//   error,
//   warning,
//   info;

//   String get displayNameArabic => switch (this) {
//     PreflightSeverity.error => 'خطأ حرج',
//     PreflightSeverity.warning => 'تحذير تنسيقي',
//     PreflightSeverity.info => 'ملاحظة',
//   };
// }

// class PreflightIssue {
//   final String id;
//   final String? blockId;
//   final int? pageIndex;
//   final PreflightSeverity severity;
//   final String title;
//   final String description;
//   final String? suggestedFix;

//   const PreflightIssue({
//     required this.id,
//     this.blockId,
//     this.pageIndex,
//     required this.severity,
//     required this.title,
//     required this.description,
//     this.suggestedFix,
//   });

//   Map<String, dynamic> toJson() => {
//     'id': id,
//     if (blockId != null) 'blockId': blockId,
//     if (pageIndex != null) 'pageIndex': pageIndex,
//     'severity': severity.name,
//     'title': title,
//     'description': description,
//     if (suggestedFix != null) 'suggestedFix': suggestedFix,
//   };

//   factory PreflightIssue.fromJson(Map<String, dynamic> json) => PreflightIssue(
//     id: json['id'] as String,
//     blockId: json['blockId'] as String?,
//     pageIndex: json['pageIndex'] as int?,
//     severity: PreflightSeverity.values.firstWhere(
//       (e) => e.name == json['severity'],
//       orElse: () => PreflightSeverity.warning,
//     ),
//     title: json['title'] as String,
//     description: json['description'] as String,
//     suggestedFix: json['suggestedFix'] as String?,
//   );
// }
