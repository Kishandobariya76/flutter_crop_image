import 'package:flutter/widgets.dart';

/// Alignment guide styles for the crop grid.
enum CropGridStyle {
  /// Classic Rule of Thirds (3x3 grid).
  ruleOfThirds,

  /// Golden Ratio composition grid lines (~0.382 and ~0.618).
  goldenRatio,

  /// Center crosshair dividing the frame into 4 quadrants.
  crosshair,

  /// Custom grid based on arbitrary rows and columns count.
  custom,

  /// No grid lines.
  none,
}

/// Configuration options for composition guide grid lines.
@immutable
class CropGridConfiguration {
  /// Creates a [CropGridConfiguration].
  const CropGridConfiguration({
    this.showGrid = true,
    this.gridColor = const Color(0x66FFFFFF), // ~40% white
    this.gridWidth = 1.0,
    this.rows = 3,
    this.columns = 3,
    this.style = CropGridStyle.ruleOfThirds,
    this.showOnlyOnInteraction = false,
  });

  /// Whether the alignment grid is visible.
  final bool showGrid;

  /// Line color of the grid dividers.
  final Color gridColor;

  /// Line width of the grid dividers in logical pixels.
  final double gridWidth;

  /// Number of horizontal divisions (applicable when [style] is [CropGridStyle.custom]).
  final int rows;

  /// Number of vertical divisions (applicable when [style] is [CropGridStyle.custom]).
  final int columns;

  /// Preset or custom style for grid alignment.
  final CropGridStyle style;

  /// If true, grid lines fade in only during pan/pinch interactions and fade out on release.
  final bool showOnlyOnInteraction;

  /// Creates a copy with modified properties.
  CropGridConfiguration copyWith({
    bool? showGrid,
    Color? gridColor,
    double? gridWidth,
    int? rows,
    int? columns,
    CropGridStyle? style,
    bool? showOnlyOnInteraction,
  }) {
    return CropGridConfiguration(
      showGrid: showGrid ?? this.showGrid,
      gridColor: gridColor ?? this.gridColor,
      gridWidth: gridWidth ?? this.gridWidth,
      rows: rows ?? this.rows,
      columns: columns ?? this.columns,
      style: style ?? this.style,
      showOnlyOnInteraction:
          showOnlyOnInteraction ?? this.showOnlyOnInteraction,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CropGridConfiguration &&
        other.showGrid == showGrid &&
        other.gridColor == gridColor &&
        other.gridWidth == gridWidth &&
        other.rows == rows &&
        other.columns == columns &&
        other.style == style &&
        other.showOnlyOnInteraction == showOnlyOnInteraction;
  }

  @override
  int get hashCode => Object.hash(
        showGrid,
        gridColor,
        gridWidth,
        rows,
        columns,
        style,
        showOnlyOnInteraction,
      );
}
