// import 'package:uuid/uuid.dart';
// import '../../core/constants/block_types.dart';
// import '../../domain/entities/document_model.dart';
// import '../../domain/entities/page_model.dart';
// import '../../domain/entities/preflight_issue.dart';

// class PreflightEngine {
//   final Uuid _uuid;

//   const PreflightEngine({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

//   List<PreflightIssue> analyzeDocument({
//     required DocumentModel document,
//     required List<DocumentPage> pages,
//   }) {
//     final issues = <PreflightIssue>[];

//     // 1. Check Document-Level Metadata
//     if (document.metadata.title.trim().isEmpty ||
//         document.metadata.title == 'محاضرة جديدة') {
//       issues.add(
//         PreflightIssue(
//           id: _uuid.v4(),
//           severity: PreflightSeverity.warning,
//           title: 'عنوان المحاضرة افتراضي',
//           description: 'لم يتم تعيين عنوان مخصص للمحاضرة في البيانات الوصفية.',
//           suggestedFix: 'قم بتحديث عنوان المستند في شريط الأدوات أو الإعدادات.',
//         ),
//       );
//     }

//     if (document.blocks.isEmpty) {
//       issues.add(
//         PreflightIssue(
//           id: _uuid.v4(),
//           severity: PreflightSeverity.error,
//           title: 'المستند فارغ',
//           description: 'لا يحتوي المستند على أي كتل أو محتوى قابل للتصدير.',
//           suggestedFix: 'أضف كتلة واحدة على الأقل قبل تصدير ملف PDF.',
//         ),
//       );
//       return issues;
//     }

//     // 2. Block-Level Inspection
//     for (int i = 0; i < document.blocks.length; i++) {
//       final block = document.blocks[i];

//       switch (block.type) {
//         case BlockTypes.heading:
//           final text = block.fields['text'] as String? ?? '';
//           if (text.trim().isEmpty) {
//             issues.add(
//               PreflightIssue(
//                 id: _uuid.v4(),
//                 blockId: block.id,
//                 severity: PreflightSeverity.error,
//                 title: 'عنوان فارغ (Heading)',
//                 description: 'الكتلة رقم ${i + 1} عبارة عن عنوان لا يحتوي على نص.',
//                 suggestedFix: 'اكتب نص العنوان أو احذف الكتلة.',
//               ),
//             );
//           }
//           break;

//         case BlockTypes.paragraph:
//           final content = block.fields['content'] as String? ?? '';
//           if (content.trim().isEmpty) {
//             issues.add(
//               PreflightIssue(
//                 id: _uuid.v4(),
//                 blockId: block.id,
//                 severity: PreflightSeverity.warning,
//                 title: 'فقرة نصية فارغة',
//                 description: 'الكتلة رقم ${i + 1} فقرة بدون محتوى نصي.',
//                 suggestedFix: 'أدخل نص الشرح أو احذف الكتلة.',
//               ),
//             );
//           }
//           break;

//         case BlockTypes.code:
//           final code = block.fields['code'] as String? ?? '';
//           if (code.trim().isEmpty) {
//             issues.add(
//               PreflightIssue(
//                 id: _uuid.v4(),
//                 blockId: block.id,
//                 severity: PreflightSeverity.error,
//                 title: 'كتلة كود فارغة',
//                 description: 'الكتلة رقم ${i + 1} مخصصة لكود برمجي ولكنها فارغة.',
//                 suggestedFix: 'اكتب الشفرة البرمجية أو احذف الكتلة.',
//               ),
//             );
//           }
//           break;

//         case BlockTypes.image:
//           final base64Data = block.fields['bytesBase64'] as String? ?? '';
//           if (base64Data.trim().isEmpty) {
//             issues.add(
//               PreflightIssue(
//                 id: _uuid.v4(),
//                 blockId: block.id,
//                 severity: PreflightSeverity.error,
//                 title: 'صورة مفقودة',
//                 description: 'الكتلة رقم ${i + 1} لم يتم تحديد ملف صورة محلي لها.',
//                 suggestedFix: 'اختر صورة من جهازك لتضمينها في المستند.',
//               ),
//             );
//           }
//           break;

//         case BlockTypes.table:
//           final headers = block.fields['headers'];
//           final rows = block.fields['rows'];
//           final headersEmpty = headers is! List || headers.isEmpty;
//           final rowsEmpty = rows is! List || rows.isEmpty;
//           if (headersEmpty && rowsEmpty) {
//             issues.add(
//               PreflightIssue(
//                 id: _uuid.v4(),
//                 blockId: block.id,
//                 severity: PreflightSeverity.warning,
//                 title: 'جدول بدون صفوف أو بيانات',
//                 description: 'الكتلة رقم ${i + 1} جدول فارغ من البيانات.',
//                 suggestedFix: 'أضف أعمدة وصفوفاً للجدول أو احذفه.',
//               ),
//             );
//           }
//           break;
//       }
//     }

//     // 3. Page-Level Inspection
//     for (final page in pages) {
//       if (page.elements.isEmpty) {
//         issues.add(
//           PreflightIssue(
//             id: _uuid.v4(),
//             pageIndex: page.pageIndex,
//             severity: PreflightSeverity.warning,
//             title: 'صفحة فارغة (صفحة ${page.pageIndex})',
//             description: 'تم إنشاء صفحة لا تحتوي على أي عناصر مرئية.',
//             suggestedFix: 'تحقق من الهوامش وقواعد الكسر للكتل السابقة.',
//           ),
//         );
//       }
//     }

//     return issues;
//   }
// }
