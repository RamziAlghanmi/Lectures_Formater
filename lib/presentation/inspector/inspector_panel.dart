import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/default_schemas.dart';
import '../providers/document_provider.dart';
import '../providers/editor_provider.dart';
import 'dynamic_field_factory.dart';

class InspectorPanel extends StatelessWidget {
  const InspectorPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final editorProvider = context.watch<EditorProvider>();
    final docProvider = context.watch<DocumentProvider>();

    final selectedId = editorProvider.selectedBlockId;
    final block = selectedId != null
        ? docProvider.document.findBlockById(selectedId)
        : null;

    // في حال عدم تحديد كتلة تظهر إعدادات الترويسة والمستند
    if (block == null) {
      return _buildDocumentHeaderSettings(context, docProvider);
    }

    final schema = DefaultSchemas.getSchemaForType(block.type);

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              labelColor: Theme.of(context).colorScheme.primary,
              indicatorColor: Theme.of(context).colorScheme.primary,
              tabs: const [
                Tab(text: 'المحتوى والحقول'),
                Tab(text: 'الطباعة والكسر'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Tab 1: Content & Fields
                ListView(
                  padding: const EdgeInsets.all(14.0),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 1. تغليف النص بـ Expanded مع قص الفائض لتجنب الانهيار
                        Expanded(
                          child: Text(
                            'نوع الكتلة: ${schema.displayName}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 4.0),
                        // 2. ضغط حواف الزر لتقليل المساحة الأفقية المستهلكة
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6.0,
                              vertical: 2.0,
                            ),
                            visualDensity: VisualDensity.compact,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          icon: const Icon(Icons.settings, size: 14.0),
                          label: const Text(
                            'إعدادات الترويسة',
                            style: TextStyle(fontSize: 11.0),
                          ),
                          onPressed: () => editorProvider.deselectBlock(),
                        ),
                      ],
                    ),
                    const Divider(height: 16.0),
                    ...schema.fields.map((fDef) {
                      final val = block.fields[fDef.key];
                      return DynamicFieldFactory.buildField(
                        blockId: block.id,
                        fieldDef: fDef,
                        currentValue: val,
                        onChanged: (newVal) {
                          docProvider.updateBlockField(
                            block.id,
                            fDef.key,
                            newVal,
                          );
                        },
                      );
                    }),
                  ],
                ),

                // Tab 2: Layout & Printing Rules
                ListView(
                  padding: const EdgeInsets.all(14.0),
                  children: [
                    SwitchListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'بدء في صفحة جديدة (Force Page Break)',
                        style: TextStyle(fontSize: 12.5),
                      ),
                      subtitle: const Text(
                        'إجبار هذه الكتلة على الانتقال لبداية صفحة جديدة دائماً',
                        style: TextStyle(fontSize: 11.0, color: Colors.grey),
                      ),
                      value: block.layoutRules.forcePageBreakBefore,
                      onChanged: (val) {
                        docProvider.updateBlockLayoutRules(
                          block.id,
                          block.layoutRules.copyWith(forcePageBreakBefore: val),
                        );
                      },
                    ),
                    const Divider(height: 16.0),
                    SwitchListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'إبقاء الكتلة كوحدة واحدة (Keep Together)',
                        style: TextStyle(fontSize: 12.5),
                      ),
                      subtitle: const Text(
                        'منع تجزئة الكتلة بين صفحتين إذا اتسعت لصفحة كاملة',
                        style: TextStyle(fontSize: 11.0, color: Colors.grey),
                      ),
                      value: block.layoutRules.keepTogether,
                      onChanged: (val) {
                        docProvider.updateBlockLayoutRules(
                          block.id,
                          block.layoutRules.copyWith(keepTogether: val),
                        );
                      },
                    ),
                    SwitchListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'السماح بالتقسيم الذكي (Allow Split)',
                        style: TextStyle(fontSize: 12.5),
                      ),
                      value: block.layoutRules.allowSplit,
                      onChanged: (val) {
                        docProvider.updateBlockLayoutRules(
                          block.id,
                          block.layoutRules.copyWith(allowSplit: val),
                        );
                      },
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      'المسافة السابقة (Space Before: ${block.layoutRules.spaceBefore.toInt()}pt)',
                      style: const TextStyle(fontSize: 12.0),
                    ),
                    Slider(
                      value: block.layoutRules.spaceBefore,
                      min: 0,
                      max: 32,
                      onChanged: (val) {
                        docProvider.updateBlockLayoutRules(
                          block.id,
                          block.layoutRules.copyWith(spaceBefore: val),
                        );
                      },
                    ),
                    Text(
                      'المسافة اللاحقة (Space After: ${block.layoutRules.spaceAfter.toInt()}pt)',
                      style: const TextStyle(fontSize: 12.0),
                    ),
                    Slider(
                      value: block.layoutRules.spaceAfter,
                      min: 0,
                      max: 32,
                      onChanged: (val) {
                        docProvider.updateBlockLayoutRules(
                          block.id,
                          block.layoutRules.copyWith(spaceAfter: val),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentHeaderSettings(
    BuildContext context,
    DocumentProvider docProvider,
  ) {
    final meta = docProvider.document.metadata;
    final docId = docProvider.document.id;

    return ListView(
      padding: const EdgeInsets.all(12.0),
      children: [
        Card(
          elevation: 0.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 10.0,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(8.0),
                  ),
                  border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.format_size,
                      size: 18.0,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 6.0),
                    const Text(
                      'بيانات الدرس والترويسة',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.expand_more,
                      size: 20.0,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'اسم الدورة',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.0,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    TextFormField(
                      key: ValueKey('${docId}_course_field'),
                      initialValue: meta.courseName,
                      style: const TextStyle(fontSize: 12.5),
                      decoration: const InputDecoration(
                        hintText: 'دورة تطوير التطبيقات',
                        isDense: true,
                      ),
                      onChanged: (val) => docProvider.updateMetadata(
                        meta.copyWith(courseName: val),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    const Text(
                      'اسم الوحدة',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.0,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    TextFormField(
                      key: ValueKey('${docId}_unit_field'),
                      initialValue: meta.unit,
                      style: const TextStyle(fontSize: 12.5),
                      decoration: const InputDecoration(
                        hintText: 'الوحدة الأولى: المفاهيم الأساسية',
                        isDense: true,
                      ),
                      onChanged: (val) =>
                          docProvider.updateMetadata(meta.copyWith(unit: val)),
                    ),
                    const SizedBox(height: 10.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'عنوان الدرس',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.0,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              TextFormField(
                                key: ValueKey('${docId}_title_field'),
                                initialValue: meta.title,
                                style: const TextStyle(fontSize: 12.5),
                                decoration: const InputDecoration(
                                  hintText: 'عنوان الدرس التعليمي',
                                  isDense: true,
                                ),
                                onChanged: (val) => docProvider.updateMetadata(
                                  meta.copyWith(title: val),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'رقم الدرس',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.0,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              TextFormField(
                                key: ValueKey('${docId}_num_field'),
                                initialValue: meta.lessonNumber,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12.5),
                                decoration: const InputDecoration(
                                  hintText: '01',
                                  isDense: true,
                                ),
                                onChanged: (val) => docProvider.updateMetadata(
                                  meta.copyWith(lessonNumber: val),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    const Text(
                      'العنوان الفرعي',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.0,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    TextFormField(
                      key: ValueKey('${docId}_sub_field'),
                      initialValue: meta.subtitle,
                      style: const TextStyle(fontSize: 12.5),
                      decoration: const InputDecoration(
                        hintText: 'شرح تفصيلي وآليات العمل التطبيقي',
                        isDense: true,
                      ),
                      onChanged: (val) => docProvider.updateMetadata(
                        meta.copyWith(subtitle: val),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
