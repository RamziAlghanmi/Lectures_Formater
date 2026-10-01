class PaginationConfig {
  const PaginationConfig._();

  /// The minimum remaining vertical space ratio required to consider splitting a block.
  /// If remainingSpace / totalPageHeight <= paginationBreakThreshold, the block moves entirely to the next page.
  static const double paginationBreakThreshold = 0.20;

  /// Default line height multiplier for typography measuring.
  static const double defaultLineHeightMultiplier = 1.35;

  /// Code block line height multiplier.
  static const double codeLineHeightMultiplier = 1.45;

  /// Maximum states kept in memory for undo/redo.
  static const int maxHistoryLimit = 35;

  /// Debounce duration in milliseconds for auto-recalculation and text inputs.
  static const int debounceDurationMs = 300;
}
