import 'block_node.dart';

class SpatialRect {
  final double left;
  final double top;
  final double width;
  final double height;

  const SpatialRect({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  double get right => left + width;
  double get bottom => top + height;

  Map<String, dynamic> toJson() => {
    'left': left,
    'top': top,
    'width': width,
    'height': height,
  };

  factory SpatialRect.fromJson(Map<String, dynamic> json) => SpatialRect(
    left: (json['left'] as num).toDouble(),
    top: (json['top'] as num).toDouble(),
    width: (json['width'] as num).toDouble(),
    height: (json['height'] as num).toDouble(),
  );
}

enum ChunkSliceType { full, lineRange, itemRange, tableRowsRange }

class BlockRenderChunk {
  final BlockNode originalBlock;
  final ChunkSliceType sliceType;
  final int startIndex;
  final int endIndex;
  final dynamic customSliceData;

  const BlockRenderChunk({
    required this.originalBlock,
    this.sliceType = ChunkSliceType.full,
    this.startIndex = 0,
    this.endIndex = -1,
    this.customSliceData,
  });

  bool get isPartial => sliceType != ChunkSliceType.full;
}

class PageElementLayout {
  final String blockId;
  final SpatialRect bounds;
  final BlockRenderChunk renderChunk;
  final bool isContinuation;

  const PageElementLayout({
    required this.blockId,
    required this.bounds,
    required this.renderChunk,
    this.isContinuation = false,
  });
}

class PageHeaderData {
  final String title;
  final String subtitle;
  final String lessonNumber;
  final String courseName;
  final String unit;
  final bool isVisible;

  const PageHeaderData({
    required this.title,
    this.subtitle = '',
    this.lessonNumber = '01',
    this.courseName = '',
    this.unit = '',
    this.isVisible = true,
  });
}

class PageFooterData {
  final int pageIndex;
  final int totalPages;
  final String formattedPageNumber;
  final String customNote;
  final bool isVisible;

  const PageFooterData({
    required this.pageIndex,
    required this.totalPages,
    required this.formattedPageNumber,
    this.customNote = '',
    this.isVisible = true,
  });
}

class DocumentPage {
  final int pageIndex;
  final int totalPages;
  final double width;
  final double height;
  final PageHeaderData header;
  final PageFooterData footer;
  final List<PageElementLayout> elements;

  const DocumentPage({
    required this.pageIndex,
    required this.totalPages,
    required this.width,
    required this.height,
    required this.header,
    required this.footer,
    required this.elements,
    required double occupiedHeight,
  });
}
