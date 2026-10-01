import 'block_node.dart';
import 'document_metadata.dart';
import 'document_settings.dart';
import 'document_theme_config.dart';

class DocumentModel {
  final String id;
  final int schemaVersion;
  final DocumentMetadata metadata;
  final DocumentSettings settings;
  final DocumentThemeConfig theme;
  final List<BlockNode> blocks;

  const DocumentModel({
    required this.id,
    this.schemaVersion = 1,
    required this.metadata,
    this.settings = const DocumentSettings(),
    this.theme = const DocumentThemeConfig(),
    this.blocks = const [],
  });

  DocumentModel copyWith({
    String? id,
    int? schemaVersion,
    DocumentMetadata? metadata,
    DocumentSettings? settings,
    DocumentThemeConfig? theme,
    List<BlockNode>? blocks,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      metadata: metadata ?? this.metadata,
      settings: settings ?? this.settings,
      theme: theme ?? this.theme,
      blocks: blocks ?? this.blocks,
    );
  }

  BlockNode? findBlockById(String id) {
    BlockNode? search(List<BlockNode> nodes) {
      for (final node in nodes) {
        if (node.id == id) return node;
        final foundInChildren = search(node.children);
        if (foundInChildren != null) return foundInChildren;
      }
      return null;
    }

    return search(blocks);
  }

  DocumentModel updateBlock(BlockNode updatedNode) {
    List<BlockNode> updateList(List<BlockNode> nodes) {
      return nodes.map((node) {
        if (node.id == updatedNode.id) {
          return updatedNode;
        }
        if (node.children.isNotEmpty) {
          return node.copyWith(children: updateList(node.children));
        }
        return node;
      }).toList();
    }

    return copyWith(
      blocks: updateList(blocks),
      metadata: metadata.copyWith(updatedAt: DateTime.now()),
    );
  }

  DocumentModel removeBlock(String id) {
    List<BlockNode> removeRecursive(List<BlockNode> nodes) {
      final filtered = nodes.where((n) => n.id != id).toList();
      return filtered.map((n) {
        if (n.children.isNotEmpty) {
          return n.copyWith(children: removeRecursive(n.children));
        }
        return n;
      }).toList();
    }

    return copyWith(
      blocks: removeRecursive(blocks),
      metadata: metadata.copyWith(updatedAt: DateTime.now()),
    );
  }

  DocumentModel insertBlock(int index, BlockNode block) {
    final updatedList = List<BlockNode>.from(blocks);
    final safeIndex = index.clamp(0, updatedList.length);
    updatedList.insert(safeIndex, block);
    return copyWith(
      blocks: updatedList,
      metadata: metadata.copyWith(updatedAt: DateTime.now()),
    );
  }

  DocumentModel moveBlock(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= blocks.length) return this;
    if (newIndex < 0 || newIndex >= blocks.length) return this;
    if (oldIndex == newIndex) return this;

    final updatedList = List<BlockNode>.from(blocks);
    final item = updatedList.removeAt(oldIndex);
    updatedList.insert(newIndex, item);

    return copyWith(
      blocks: updatedList,
      metadata: metadata.copyWith(updatedAt: DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'schemaVersion': schemaVersion,
    'metadata': metadata.toJson(),
    'settings': settings.toJson(),
    'theme': theme.toJson(),
    'blocks': blocks.map((b) => b.toJson()).toList(),
  };

  factory DocumentModel.fromJson(Map<String, dynamic> json) => DocumentModel(
    id: json['id'] as String,
    schemaVersion: json['schemaVersion'] as int? ?? 1,
    metadata: DocumentMetadata.fromJson(
      json['metadata'] as Map<String, dynamic>? ?? {},
    ),
    settings: json['settings'] != null
        ? DocumentSettings.fromJson(json['settings'] as Map<String, dynamic>)
        : const DocumentSettings(),
    theme: json['theme'] != null
        ? DocumentThemeConfig.fromJson(json['theme'] as Map<String, dynamic>)
        : const DocumentThemeConfig(),
    blocks: json['blocks'] != null
        ? (json['blocks'] as List)
              .map((b) => BlockNode.fromJson(b as Map<String, dynamic>))
              .toList()
        : const [],
  );
}
