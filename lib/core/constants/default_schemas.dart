import '../../domain/schemas/block_schema.dart';
import '../../domain/schemas/field_definition.dart';
import '../../domain/schemas/field_type.dart';
import 'block_types.dart';

class DefaultSchemas {
  const DefaultSchemas._();

  static const List<BlockSchema> allSchemas = [
    // 1. Heading
    BlockSchema(
      type: BlockTypes.heading,
      displayName: 'عنوان',
      icon: 'format_size',
      category: 'النصوص الأساسية',
      defaultLayoutRules: BlockLayoutRules(
        keepTogether: true,
        keepWithNext: true,
        allowSplit: false,
        breakPriority: BreakPriority.never,
        spaceBefore: 6.0,
        spaceAfter: 4.0,
      ),
      fields: [
        FieldDefinition(
          key: 'text',
          label: 'نص العنوان',
          type: FieldType.text,
          defaultValue: '',
          placeholder: 'اكتب العنوان هنا...',
          validation: FieldValidationRules(isRequired: true, minLength: 1),
        ),
        FieldDefinition(
          key: 'level',
          label: 'مستوى العنوان',
          type: FieldType.dropdown,
          defaultValue: 'h1',
          options: [
            FieldOption(label: 'عنوان رئيسي (H1)', value: 'h1'),
            FieldOption(label: 'عنوان فرعي (H2)', value: 'h2'),
            FieldOption(label: 'عنوان قسم (H3)', value: 'h3'),
          ],
        ),
      ],
    ),

    // 2. Paragraph
    BlockSchema(
      type: BlockTypes.paragraph,
      displayName: 'فقرة نصية',
      icon: 'notes',
      category: 'النصوص الأساسية',
      defaultLayoutRules: BlockLayoutRules(
        keepTogether: false,
        allowSplit: true,
        breakPriority: BreakPriority.high,
        spaceBefore: 4.0,
        spaceAfter: 2.0,
      ),
      fields: [
        FieldDefinition(
          key: 'title',
          label: 'عنوان الفقرة  - إختياري',
          type: FieldType.text,
          defaultValue: '',
          placeholder: 'اكتب عنوان الفقرة هنا ... ',
        ),
        FieldDefinition(
          key: 'content',
          label: 'نص الفقرة',
          type: FieldType.multiline,
          defaultValue: '',
          placeholder: 'اكتب محتوى الشرح والتفاصيل...',
          validation: FieldValidationRules(isRequired: true),
        ),
      ],
    ),

    // 3. Bullet List
    BlockSchema(
      type: BlockTypes.bulletList,
      displayName: 'قائمة نقطية',
      icon: 'format_list_bulleted',
      category: 'النصوص الأساسية',
      defaultLayoutRules: BlockLayoutRules(
        keepTogether: false,
        allowSplit: true,
        breakPriority: BreakPriority.high,
        spaceBefore: 4.0,
        spaceAfter: 2.0,
      ),
      fields: [
        FieldDefinition(
          key: 'title',
          label: 'عنوان القائمة  - إختياري',
          type: FieldType.text,
          defaultValue: '',
          placeholder: 'اكتب عنوان القائمة النقطية هنا ... ',
        ),
        FieldDefinition(
          key: 'items',
          label: 'عناصر القائمة',
          type: FieldType.list,
          defaultValue: <String>[],
          subFields: [
            FieldDefinition(
              key: 'item_text',
              label: 'العنصر',
              type: FieldType.text,
              defaultValue: '',
            ),
          ],
        ),
      ],
    ),

    // 4. Numbered List
    BlockSchema(
      type: BlockTypes.numberedList,
      displayName: 'قائمة مرقمة',
      icon: 'format_list_numbered',
      category: 'النصوص الأساسية',
      defaultLayoutRules: BlockLayoutRules(
        keepTogether: false,
        allowSplit: true,
        breakPriority: BreakPriority.high,
        spaceBefore: 4.0,
        spaceAfter: 2.0,
      ),
      fields: [
        FieldDefinition(
          key: 'title',
          label: 'عنوان القائمة - إختياري',
          type: FieldType.text,
          defaultValue: '',
          placeholder: 'اكتب عنوان القائمة المرقمة هنا ... ',
        ),
        FieldDefinition(
          key: 'items',
          label: 'عناصر القائمة المرقمة',
          type: FieldType.list,
          defaultValue: <String>[],
          subFields: [
            FieldDefinition(
              key: 'item_text',
              label: 'الخطوة / العنصر',
              type: FieldType.text,
              defaultValue: '',
            ),
          ],
        ),
      ],
    ),

    // 5. Note Callout
    BlockSchema(
      type: BlockTypes.note,
      displayName: 'ملاحظة',
      icon: 'sticky_note_2',
      category: 'التنبيهات والملاحظات',
      defaultLayoutRules: BlockLayoutRules(
        keepTogether: true,
        allowSplit: false,
        breakPriority: BreakPriority.never,
        spaceBefore: 4.0,
        spaceAfter: 2.0,
      ),
      fields: [
        FieldDefinition(
          key: 'title',
          label: 'عنوان الملاحظة',
          type: FieldType.text,
          defaultValue: 'ملاحظة',
        ),
        FieldDefinition(
          key: 'content',
          label: 'نص الملاحظة',
          type: FieldType.multiline,
          defaultValue: '',
          validation: FieldValidationRules(isRequired: true),
        ),
      ],
    ),

    // 6. Information Callout
    BlockSchema(
      type: BlockTypes.information,
      displayName: 'معلومة هامة',
      icon: 'info',
      category: 'التنبيهات والملاحظات',
      defaultLayoutRules: BlockLayoutRules(
        keepTogether: true,
        allowSplit: false,
        breakPriority: BreakPriority.never,
        spaceBefore: 4.0,
        spaceAfter: 2.0,
      ),
      fields: [
        FieldDefinition(
          key: 'title',
          label: 'العنوان',
          type: FieldType.text,
          defaultValue: 'معلومة إضافية',
        ),
        FieldDefinition(
          key: 'content',
          label: 'المحتوى',
          type: FieldType.multiline,
          defaultValue: '',
          validation: FieldValidationRules(isRequired: true),
        ),
      ],
    ),

    // 7. Tip Callout
    BlockSchema(
      type: BlockTypes.tip,
      displayName: 'نصيحة ذكية',
      icon: 'lightbulb',
      category: 'التنبيهات والملاحظات',
      defaultLayoutRules: BlockLayoutRules(
        keepTogether: true,
        allowSplit: false,
        breakPriority: BreakPriority.never,
        spaceBefore: 4.0,
        spaceAfter: 2.0,
      ),
      fields: [
        FieldDefinition(
          key: 'title',
          label: 'عنوان النصيحة',
          type: FieldType.text,
          defaultValue: 'نصيحة احترافية',
        ),
        FieldDefinition(
          key: 'content',
          label: 'نص النصيحة',
          type: FieldType.multiline,
          defaultValue: '',
          validation: FieldValidationRules(isRequired: true),
        ),
      ],
    ),

    // 8. Warning Callout
    BlockSchema(
      type: BlockTypes.warning,
      displayName: 'تحذير',
      icon: 'warning',
      category: 'التنبيهات والملاحظات',
      defaultLayoutRules: BlockLayoutRules(
        keepTogether: true,
        allowSplit: false,
        breakPriority: BreakPriority.never,
        spaceBefore: 4.0,
        spaceAfter: 4.0,
      ),
      fields: [
        FieldDefinition(
          key: 'title',
          label: 'عنوان التحذير',
          type: FieldType.text,
          defaultValue: 'تحذير هام',
        ),
        FieldDefinition(
          key: 'content',
          label: 'نص التحذير',
          type: FieldType.multiline,
          defaultValue: '',
          validation: FieldValidationRules(isRequired: true),
        ),
      ],
    ),

    // 9. Error Callout
    BlockSchema(
      type: BlockTypes.error,
      displayName: 'خطأ برمجي / استثناء',
      icon: 'error',
      category: 'التنبيهات والملاحظات',
      defaultLayoutRules: BlockLayoutRules(
        keepTogether: true,
        allowSplit: false,
        breakPriority: BreakPriority.never,
        spaceBefore: 4.0,
        spaceAfter: 2.0,
      ),
      fields: [
        FieldDefinition(
          key: 'title',
          label: 'عنوان الخطأ',
          type: FieldType.text,
          defaultValue: 'خطأ شائع يجب تجنبه',
        ),
        FieldDefinition(
          key: 'content',
          label: 'تفاصيل الخطأ وسببه',
          type: FieldType.multiline,
          defaultValue: '',
          validation: FieldValidationRules(isRequired: true),
        ),
      ],
    ),

    // 10. Important Callout
    BlockSchema(
      type: BlockTypes.important,
      displayName: 'مهم جداً',
      icon: 'priority_high',
      category: 'التنبيهات والملاحظات',
      defaultLayoutRules: BlockLayoutRules(
        keepTogether: true,
        allowSplit: false,
        breakPriority: BreakPriority.never,
        spaceBefore: 4.0,
        spaceAfter: 2.0,
      ),
      fields: [
        FieldDefinition(
          key: 'title',
          label: 'العنوان',
          type: FieldType.text,
          defaultValue: 'مهم جداً للامتحان',
        ),
        FieldDefinition(
          key: 'content',
          label: 'المحتوى الرئيسي',
          type: FieldType.multiline,
          defaultValue: '',
          validation: FieldValidationRules(isRequired: true),
        ),
      ],
    ),

    // 11. Best Practice
    BlockSchema(
      type: BlockTypes.bestPractice,
      displayName: 'أفضل الممارسات',
      icon: 'verified',
      category: 'التنبيهات والملاحظات',
      defaultLayoutRules: BlockLayoutRules(
        keepTogether: true,
        allowSplit: false,
        breakPriority: BreakPriority.never,
        spaceBefore: 4.0,
        spaceAfter: 2.0,
      ),
      fields: [
        FieldDefinition(
          key: 'title',
          label: 'العنوان',
          type: FieldType.text,
          defaultValue: 'أفضل ممارسة معتمدة',
        ),
        FieldDefinition(
          key: 'content',
          label: 'التفاصيل والتعليمات',
          type: FieldType.multiline,
          defaultValue: '',
          validation: FieldValidationRules(isRequired: true),
        ),
      ],
    ),

    // 12. Common Mistake
    BlockSchema(
      type: BlockTypes.commonMistake,
      displayName: 'خطأ شائع وتصحيحه',
      icon: 'cancel',
      category: 'التنبيهات والملاحظات',
      defaultLayoutRules: BlockLayoutRules(
        keepTogether: true,
        allowSplit: false,
        breakPriority: BreakPriority.never,
        spaceBefore: 4.0,
        spaceAfter: 2.0,
      ),
      fields: [
        FieldDefinition(
          key: 'mistake',
          label: 'الخطأ الشائع',
          type: FieldType.multiline,
          defaultValue: '',
          validation: FieldValidationRules(isRequired: true),
        ),
        FieldDefinition(
          key: 'correction',
          label: 'التصحيح السليم والسبب',
          type: FieldType.multiline,
          defaultValue: '',
          validation: FieldValidationRules(isRequired: true),
        ),
      ],
    ),

    // 13. Example
    // BlockSchema(
    //   type: BlockTypes.example,
    //   displayName: 'مثال تطبيقي',
    //   icon: 'science',
    //   category: 'المحتوى التعليمي',
    //   defaultLayoutRules: BlockLayoutRules(
    //     keepTogether: false,
    //     allowSplit: true,
    //     breakPriority: BreakPriority.medium,
    //     spaceBefore: 4.0,
    //    spaceAfter: 2.0,
    //   ),
    //   fields: [
    //     FieldDefinition(
    //       key: 'title',
    //       label: 'عنوان المثال',
    //       type: FieldType.text,
    //       defaultValue: 'مثال تطبيقي',
    //     ),
    //     FieldDefinition(
    //       key: 'problem',
    //       label: 'المسألة أو المشكلة',
    //       type: FieldType.multiline,
    //       defaultValue: '',
    //     ),
    //     FieldDefinition(
    //       key: 'solution',
    //       label: 'الحل والخطوات',
    //       type: FieldType.multiline,
    //       defaultValue: '',
    //       validation: FieldValidationRules(isRequired: true),
    //     ),
    //   ],
    // ),

    // // 14. Exercise
    // BlockSchema(
    //   type: BlockTypes.exercise,
    //   displayName: 'تمرين / واجب',
    //   icon: 'assignment',
    //   category: 'المحتوى التعليمي',
    //   defaultLayoutRules: BlockLayoutRules(
    //     keepTogether: true,
    //     allowSplit: false,
    //     breakPriority: BreakPriority.low,
    //     spaceBefore: 4.0,
    //     spaceAfter: 2.0,
    //   ),
    //   fields: [
    //     FieldDefinition(
    //       key: 'title',
    //       label: 'عنوان التمرين',
    //       type: FieldType.text,
    //       defaultValue: 'تمرين عملي',
    //     ),
    //     FieldDefinition(
    //       key: 'question',
    //       label: 'نص السؤال أو المطلوب',
    //       type: FieldType.multiline,
    //       defaultValue: '',
    //       validation: FieldValidationRules(isRequired: true),
    //     ),
    //     FieldDefinition(
    //       key: 'hint',
    //       label: 'تلميح للحل (اختياري)',
    //       type: FieldType.text,
    //       defaultValue: '',
    //     ),
    //   ],
    // ),

    // 15. Image
    BlockSchema(
      type: BlockTypes.image,
      displayName: 'صورة توضيحية',
      icon: 'image',
      category: 'الوسائط والبيانات',
      defaultLayoutRules: BlockLayoutRules(
        keepTogether: true,
        allowSplit: false,
        breakPriority: BreakPriority.never,
        spaceBefore: 4.0,
        spaceAfter: 2.0,
      ),
      fields: [
        FieldDefinition(
          key: 'bytesBase64',
          label: 'بيانات الصورة (Base64)',
          type: FieldType.imagePath,
          defaultValue: '',
          validation: FieldValidationRules(isRequired: true),
        ),
        FieldDefinition(
          key: 'caption',
          label: 'العنوان التوضيحي (Caption)',
          type: FieldType.text,
          defaultValue: '',
        ),
        FieldDefinition(
          key: 'widthPercent',
          label: 'عرض الصورة بالنسبة المئوية',
          type: FieldType.number,
          defaultValue: 85,
          validation: FieldValidationRules(minValue: 20, maxValue: 100),
        ),
        FieldDefinition(
          key: 'alignment',
          label: 'المحاذاة',
          type: FieldType.dropdown,
          defaultValue: 'center',
          options: [
            FieldOption(label: 'وسط', value: 'center'),
            FieldOption(label: 'يمين', value: 'right'),
            FieldOption(label: 'يسار', value: 'left'),
          ],
        ),
      ],
    ),

    // 16. Table
    BlockSchema(
      type: BlockTypes.table,
      displayName: 'جدول بيانات',
      icon: 'table_chart',
      category: 'الوسائط والبيانات',
      defaultLayoutRules: BlockLayoutRules(
        keepTogether: false,
        allowSplit: true,
        breakPriority: BreakPriority.medium,
        spaceBefore: 4.0,
        spaceAfter: 2.0,
      ),
      fields: [
        FieldDefinition(
          key: 'headers',
          label: 'أعمدة الجدول',
          type: FieldType.list,
          defaultValue: <String>['العمود 1', 'العمود 2'],
          subFields: [
            FieldDefinition(
              key: 'column_name',
              label: 'اسم العمود',
              type: FieldType.text,
              defaultValue: '',
            ),
          ],
        ),
        FieldDefinition(
          key: 'rows',
          label: 'صفوف الجدول',
          type: FieldType.list,
          defaultValue: <List<String>>[],
        ),
      ],
    ),

    // 17. Comparison
    BlockSchema(
      type: BlockTypes.comparison,
      displayName: 'مقارنة جانبية',
      icon: 'compare_arrows',
      category: 'الوسائط والبيانات',
      defaultLayoutRules: BlockLayoutRules(
        keepTogether: true,
        allowSplit: false,
        breakPriority: BreakPriority.medium,
        spaceBefore: 4.0,
        spaceAfter: 2.0,
      ),
      fields: [
        FieldDefinition(
          key: 'itemATitle',
          label: 'عنوان العنصر الأول',
          type: FieldType.text,
          defaultValue: 'الخيار A',
          validation: FieldValidationRules(isRequired: true),
        ),
        FieldDefinition(
          key: 'itemAContent',
          label: 'تفاصيل العنصر الأول',
          type: FieldType.multiline,
          defaultValue: '',
          validation: FieldValidationRules(isRequired: true),
        ),
        FieldDefinition(
          key: 'itemBTitle',
          label: 'عنوان العنصر الثاني',
          type: FieldType.text,
          defaultValue: 'الخيار B',
          validation: FieldValidationRules(isRequired: true),
        ),
        FieldDefinition(
          key: 'itemBContent',
          label: 'تفاصيل العنصر الثاني',
          type: FieldType.multiline,
          defaultValue: '',
          validation: FieldValidationRules(isRequired: true),
        ),
      ],
    ),

    // 18. Code Block
    BlockSchema(
      type: BlockTypes.code,
      displayName: 'كود برمجى',
      icon: 'code',
      category: 'البرمجة والتطوير',
      defaultLayoutRules: BlockLayoutRules(
        keepTogether: false,
        allowSplit: true,
        breakPriority: BreakPriority.high,
        spaceBefore: 4.0,
        spaceAfter: 2.0,
      ),
      fields: [
        FieldDefinition(
          key: 'code',
          label: 'نص الشفرة البرمجية',
          type: FieldType.code,
          defaultValue: '',
          validation: FieldValidationRules(isRequired: true),
        ),
        FieldDefinition(
          key: 'language',
          label: 'لغة البرمجة',
          type: FieldType.dropdown,
          defaultValue: 'dart',
          options: [
            FieldOption(label: 'Dart / Flutter', value: 'dart'),
            FieldOption(label: 'JavaScript / TypeScript', value: 'javascript'),
            FieldOption(label: 'Python', value: 'python'),
            FieldOption(label: 'Java', value: 'java'),
            FieldOption(label: 'C++ / C#', value: 'cpp'),
            FieldOption(label: 'PHP', value: 'php'),
            FieldOption(label: 'SQL', value: 'sql'),
            FieldOption(label: 'JSON / YAML', value: 'json'),
            FieldOption(label: 'HTML / CSS', value: 'html'),
            FieldOption(label: 'Plain Text', value: 'plaintext'),
          ],
        ),
        FieldDefinition(
          key: 'fileName',
          label: 'اسم الملف / الترويسة',
          type: FieldType.text,
          defaultValue: '',
          placeholder: 'مثال: user_repository.dart',
        ),
        FieldDefinition(
          key: 'showLineNumbers',
          label: 'إظهار أرقام الأسطر',
          type: FieldType.boolean,
          defaultValue: true,
        ),
      ],
    ),

    // 19. Console Output
    // BlockSchema(
    //   type: BlockTypes.consoleOutput,
    //   displayName: 'مخرجات الطرفية (Console)',
    //   icon: 'terminal',
    //   category: 'البرمجة والتطوير',
    //   defaultLayoutRules: BlockLayoutRules(
    //     keepTogether: true,
    //     allowSplit: true,
    //     breakPriority: BreakPriority.high,
    //     spaceBefore: 4.0,
    //     spaceAfter: 2.0,
    //   ),
    //   fields: [
    //     FieldDefinition(
    //       key: 'output',
    //       label: 'نص المخرجات',
    //       type: FieldType.code,
    //       defaultValue: '',
    //       validation: FieldValidationRules(isRequired: true),
    //     ),
    //     FieldDefinition(
    //       key: 'command',
    //       label: 'الأمر المنفذ (Command)',
    //       type: FieldType.text,
    //       defaultValue: '',
    //       placeholder: 'مثال: flutter run',
    //     ),
    //   ],
    // ),

    // 20. Function Block
    BlockSchema(
      type: BlockTypes.functionDoc,
      displayName: 'دالة برمجية (Function)',
      icon: 'functions',
      category: 'الهياكل البرمجية المتقدمة',
      defaultLayoutRules: BlockLayoutRules(
        keepTogether: false,
        allowSplit: true,
        breakPriority: BreakPriority.medium,
        spaceBefore: 4.0,
        spaceAfter: 2.0,
      ),
      fields: [
        FieldDefinition(
          key: 'name',
          label: 'اسم الدالة',
          type: FieldType.text,
          defaultValue: 'myFunction',
          validation: FieldValidationRules(isRequired: true),
        ),
        FieldDefinition(
          key: 'returnType',
          label: 'نوع القيمة المرجعة',
          type: FieldType.text,
          defaultValue: 'void',
        ),
        FieldDefinition(
          key: 'description',
          label: 'شرح الغرض من الدالة',
          type: FieldType.multiline,
          defaultValue: '',
        ),
        FieldDefinition(
          key: 'parameters',
          label: 'المعاملات (Parameters)',
          type: FieldType.list,
          defaultValue: <Map<String, dynamic>>[],
          subFields: [
            FieldDefinition(
              key: 'paramName',
              label: 'اسم المعامل',
              type: FieldType.text,
              defaultValue: '',
            ),
            FieldDefinition(
              key: 'paramType',
              label: 'النوع',
              type: FieldType.text,
              defaultValue: 'String',
            ),
            FieldDefinition(
              key: 'isRequired',
              label: 'إلزامي',
              type: FieldType.boolean,
              defaultValue: true,
            ),
            FieldDefinition(
              key: 'paramDesc',
              label: 'الوصف',
              type: FieldType.text,
              defaultValue: '',
            ),
          ],
        ),
        FieldDefinition(
          key: 'code',
          label: 'جسم الدالة (Implementation)',
          type: FieldType.code,
          defaultValue: '',
        ),
      ],
    ),

    // 21. Class Block
    // BlockSchema(
    //   type: BlockTypes.classBlock,
    //   displayName: 'فئة كائنية (Class)',
    //   icon: 'account_tree',
    //   category: 'الهياكل البرمجية المتقدمة',
    //   defaultLayoutRules: BlockLayoutRules(
    //     keepTogether: false,
    //     allowSplit: true,
    //     breakPriority: BreakPriority.medium,
    //     spaceBefore: 4.0,
    //     spaceAfter: 2.0,
    //   ),
    //   fields: [
    //     FieldDefinition(
    //       key: 'name',
    //       label: 'اسم الكلاس',
    //       type: FieldType.text,
    //       defaultValue: 'UserEntity',
    //       validation: FieldValidationRules(isRequired: true),
    //     ),
    //     FieldDefinition(
    //       key: 'extendsClass',
    //       label: 'يرث من (Extends)',
    //       type: FieldType.text,
    //       defaultValue: '',
    //     ),
    //     FieldDefinition(
    //       key: 'description',
    //       label: 'وصف الفئة ومسؤوليتها',
    //       type: FieldType.multiline,
    //       defaultValue: '',
    //     ),
    //     FieldDefinition(
    //       key: 'properties',
    //       label: 'الخصائص (Fields / Properties)',
    //       type: FieldType.list,
    //       defaultValue: <Map<String, dynamic>>[],
    //       subFields: [
    //         FieldDefinition(
    //           key: 'propName',
    //           label: 'الاسم',
    //           type: FieldType.text,
    //           defaultValue: '',
    //         ),
    //         FieldDefinition(
    //           key: 'propType',
    //           label: 'النوع',
    //           type: FieldType.text,
    //           defaultValue: 'String',
    //         ),
    //         FieldDefinition(
    //           key: 'isFinal',
    //           label: 'Final',
    //           type: FieldType.boolean,
    //           defaultValue: true,
    //         ),
    //       ],
    //     ),
    //   ],
    // ),

    // // 22. Interface Block
    // BlockSchema(
    //   type: BlockTypes.interfaceBlock,
    //   displayName: 'واجهة مجردة (Interface)',
    //   icon: 'architecture',
    //   category: 'الهياكل البرمجية المتقدمة',
    //   defaultLayoutRules: BlockLayoutRules(
    //     keepTogether: false,
    //     allowSplit: true,
    //     breakPriority: BreakPriority.medium,
    //     spaceBefore: 4.0,
    //     spaceAfter: 2.0,
    //   ),
    //   fields: [
    //     FieldDefinition(
    //       key: 'name',
    //       label: 'اسم الواجهة',
    //       type: FieldType.text,
    //       defaultValue: 'AuthRepository',
    //       validation: FieldValidationRules(isRequired: true),
    //     ),
    //     FieldDefinition(
    //       key: 'description',
    //       label: 'وصف العقد البرمجي (Contract)',
    //       type: FieldType.multiline,
    //       defaultValue: '',
    //     ),
    //     FieldDefinition(
    //       key: 'methods',
    //       label: 'الدوال المجردة (Methods Contract)',
    //       type: FieldType.list,
    //       defaultValue: <Map<String, dynamic>>[],
    //       subFields: [
    //         FieldDefinition(
    //           key: 'methodSignature',
    //           label: 'التوقيع البرمجي للدالة',
    //           type: FieldType.text,
    //           defaultValue: 'Future<void> login();',
    //         ),
    //         FieldDefinition(
    //           key: 'methodDesc',
    //           label: 'الوصف',
    //           type: FieldType.text,
    //           defaultValue: '',
    //         ),
    //       ],
    //     ),
    //   ],
    // ),

    // 23. Enum Block
    // BlockSchema(
    //   type: BlockTypes.enumBlock,
    //   displayName: 'تعداد (Enum)',
    //   icon: 'list_alt',
    //   category: 'الهياكل البرمجية المتقدمة',
    //   defaultLayoutRules: BlockLayoutRules(
    //     keepTogether: true,
    //     allowSplit: false,
    //     breakPriority: BreakPriority.medium,
    //     spaceBefore: 4.0,
    //     spaceAfter: 2.0,
    //   ),
    //   fields: [
    //     FieldDefinition(
    //       key: 'name',
    //       label: 'اسم الـ Enum',
    //       type: FieldType.text,
    //       defaultValue: 'AppStatus',
    //       validation: FieldValidationRules(isRequired: true),
    //     ),
    //     FieldDefinition(
    //       key: 'values',
    //       label: 'القيم الممكنة',
    //       type: FieldType.list,
    //       defaultValue: <Map<String, dynamic>>[],
    //       subFields: [
    //         FieldDefinition(
    //           key: 'valName',
    //           label: 'القيمة',
    //           type: FieldType.text,
    //           defaultValue: 'initial',
    //         ),
    //         FieldDefinition(
    //           key: 'valDesc',
    //           label: 'الوصف',
    //           type: FieldType.text,
    //           defaultValue: '',
    //         ),
    //       ],
    //     ),
    //   ],
    // ),

    // 24. Widget Block
    // BlockSchema(
    //   type: BlockTypes.widgetBlock,
    //   displayName: 'مكون واجهة (Flutter Widget)',
    //   icon: 'widgets',
    //   category: 'الهياكل البرمجية المتقدمة',
    //   defaultLayoutRules: BlockLayoutRules(
    //     keepTogether: false,
    //     allowSplit: true,
    //     breakPriority: BreakPriority.medium,
    //     spaceBefore: 4.0,
    //     spaceAfter: 2.0,
    //   ),
    //   fields: [
    //     FieldDefinition(
    //       key: 'name',
    //       label: 'اسم الـ Widget',
    //       type: FieldType.text,
    //       defaultValue: 'CustomButton',
    //       validation: FieldValidationRules(isRequired: true),
    //     ),
    //     FieldDefinition(
    //       key: 'widgetType',
    //       label: 'نوع الـ Widget',
    //       type: FieldType.dropdown,
    //       defaultValue: 'StatelessWidget',
    //       options: [
    //         FieldOption(label: 'StatelessWidget', value: 'StatelessWidget'),
    //         FieldOption(label: 'StatefulWidget', value: 'StatefulWidget'),
    //         FieldOption(
    //           label: 'Inherited / Hook / Other',
    //           value: 'OtherWidget',
    //         ),
    //       ],
    //     ),
    //     FieldDefinition(
    //       key: 'description',
    //       label: 'شرح ودور المكون في الواجهة',
    //       type: FieldType.multiline,
    //       defaultValue: '',
    //     ),
    //     FieldDefinition(
    //       key: 'code',
    //       label: 'كود الـ Widget',
    //       type: FieldType.code,
    //       defaultValue: '',
    //     ),
    //   ],
    // ),

    // 25. API Endpoint Block
    // BlockSchema(
    //   type: BlockTypes.apiEndpoint,
    //   displayName: 'واجهة برمجية (API Endpoint)',
    //   icon: 'http',
    //   category: 'الهياكل البرمجية المتقدمة',
    //   defaultLayoutRules: BlockLayoutRules(
    //     keepTogether: true,
    //     allowSplit: false,
    //     breakPriority: BreakPriority.medium,
    //     spaceBefore: 4.0,
    //     spaceAfter: 2.0,
    //   ),
    //   fields: [
    //     FieldDefinition(
    //       key: 'path',
    //       label: 'المسار (Path)',
    //       type: FieldType.text,
    //       defaultValue: '/api/v1/users',
    //       validation: FieldValidationRules(isRequired: true),
    //     ),
    //     FieldDefinition(
    //       key: 'method',
    //       label: 'نوع الطلب (HTTP Method)',
    //       type: FieldType.dropdown,
    //       defaultValue: 'GET',
    //       options: [
    //         FieldOption(label: 'GET', value: 'GET'),
    //         FieldOption(label: 'POST', value: 'POST'),
    //         FieldOption(label: 'PUT', value: 'PUT'),
    //         FieldOption(label: 'PATCH', value: 'PATCH'),
    //         FieldOption(label: 'DELETE', value: 'DELETE'),
    //       ],
    //     ),
    //     FieldDefinition(
    //       key: 'description',
    //       label: 'وصف الطلب واستجابته',
    //       type: FieldType.multiline,
    //       defaultValue: '',
    //     ),
    //     FieldDefinition(
    //       key: 'headers',
    //       label: 'Headers المتوقعة',
    //       type: FieldType.text,
    //       defaultValue: 'Authorization: Bearer <token>',
    //     ),
    //     FieldDefinition(
    //       key: 'responsePayload',
    //       label: 'شكل الاستجابة (JSON Schema)',
    //       type: FieldType.code,
    //       defaultValue: '{\n  "status": 200,\n  "data": {}\n}',
    //     ),
    //   ],
    // ),
  ];

  static BlockSchema getSchemaForType(String type) {
    return allSchemas.firstWhere(
      (s) => s.type == type,
      orElse: () =>
          allSchemas.firstWhere((s) => s.type == BlockTypes.paragraph),
    );
  }
}
