import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'layout_node.dart';

/// Specialized solver for Grid layouts.
/// Implements CSS-like grid behaviors including auto-fit and responsive columns.
class GridLayoutSolver {
  /// Solves the grid layout for a node and its children.
  static void solve(LayoutNode node, BoxConstraints constraints) {
    final style = node.style;
    final double maxWidth = constraints.maxWidth;
    final double gap = style.gap ?? 0;

    // 1. Calculate column count
    int columnCount = style.crossAxisCount ?? 2;
    
    // Auto-fit behavior: If minColumnWidth is provided, calculate columns based on available space
    if (style.minColumnWidth != null && style.minColumnWidth! > 0) {
      columnCount = (maxWidth / (style.minColumnWidth! + gap)).floor();
      columnCount = math.max(1, columnCount);
    }

    // 2. Calculate cell dimensions
    final double totalGapWidth = (columnCount - 1) * gap;
    final double cellWidth = (maxWidth - totalGapWidth) / columnCount;
    final double cellHeight = cellWidth / (style.childAspectRatio ?? 1.0);

    // 3. Solve each child with tight constraints
    final childConstraints = BoxConstraints.tightFor(
      width: cellWidth,
      height: cellHeight,
    );

    for (var child in node.children) {
      _solveChild(child, childConstraints);
    }

    // 4. Calculate total grid height
    final int rowCount = (node.children.length / columnCount).ceil();
    final double totalHeight = (rowCount * cellHeight) + (math.max(0, rowCount - 1) * gap);

    node.computedWidth = maxWidth;
    node.computedHeight = style.height ?? totalHeight;
    
    // Store calculated meta-data if needed for the widget pass
    // (In a real implementation, we'd store columnCount on the node)
  }

  static void _solveChild(LayoutNode child, BoxConstraints constraints) {
    child.computedWidth = constraints.maxWidth;
    child.computedHeight = constraints.maxHeight;
    
    // Recursive solve for nested structures would go here
  }

  /// Utility to calculate column count for a given width and style.
  static int calculateColumnCount(double width, {int? crossAxisCount, double? minColumnWidth, double gap = 0}) {
    if (minColumnWidth != null && minColumnWidth > 0) {
      return math.max(1, (width / (minColumnWidth + gap)).floor());
    }
    return crossAxisCount ?? 2;
  }
}
