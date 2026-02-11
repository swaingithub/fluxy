import 'package:flutter/widgets.dart';
import 'layout_node.dart';

/// Specialized solver for Flex (Row/Column) layouts.
class FlexLayoutSolver {
  /// Solves the flex layout for a node and its children.
  static void solve(LayoutNode node, BoxConstraints constraints, Axis direction) {
    final style = node.style;
    final isHorizontal = direction == Axis.horizontal;
    
    // 1. Calculate available space and gaps
    double totalGap = (node.children.length - 1) * (style.gap ?? 0);
    double availableMainSpace = (isHorizontal ? constraints.maxWidth : constraints.maxHeight) - totalGap;
    
    // 2. Identify flexible children and calculate base sizes
    double usedMainSpace = 0;
    double totalFlexGrow = 0;
    final List<LayoutNode> flexibleChildren = [];

    for (var child in node.children) {
      if ((child.style.flex ?? 0) > 0 || (child.style.flexGrow ?? 0) > 0) {
        flexibleChildren.add(child);
        totalFlexGrow += (child.style.flex ?? child.style.flexGrow ?? 0).toDouble();
      } else {
        // Solve non-flexible child with loosen constraints
        // For web-like behavior, non-flexible children usually shrink-wrap
        final childConstraints = isHorizontal 
            ? BoxConstraints(maxHeight: constraints.maxHeight) 
            : BoxConstraints(maxWidth: constraints.maxWidth);
        
        _solveChild(child, childConstraints);
        usedMainSpace += isHorizontal ? (child.computedWidth ?? 0) : (child.computedHeight ?? 0);
      }
    }

    // 3. Distribute remaining space among flexible children
    double remainingSpace = availableMainSpace - usedMainSpace;
    if (remainingSpace < 0) remainingSpace = 0;

    for (var child in flexibleChildren) {
      double flexValue = (child.style.flex ?? child.style.flexGrow ?? 0).toDouble();
      double childMainAllocated = (flexValue / totalFlexGrow) * remainingSpace;
      
      final childConstraints = isHorizontal
          ? BoxConstraints.tightFor(width: childMainAllocated, height: constraints.maxHeight)
          : BoxConstraints.tightFor(width: constraints.maxWidth, height: childMainAllocated);
      
      _solveChild(child, childConstraints);
    }

    // 4. Finalize node size based on children
    if (isHorizontal) {
      node.computedWidth = constraints.maxWidth;
      node.computedHeight = style.height ?? constraints.maxHeight;
    } else {
      node.computedWidth = style.width ?? constraints.maxWidth;
      node.computedHeight = constraints.maxHeight;
    }
  }

  static void _solveChild(LayoutNode child, BoxConstraints constraints) {
    // This would typically involve delegating back to the main LayoutEngine
    // but for now, we'll implement a simple recursive solve.
    double width = (child.style.width ?? constraints.maxWidth).clamp(constraints.minWidth, constraints.maxWidth);
    double height = (child.style.height ?? constraints.maxHeight).clamp(constraints.minHeight, constraints.maxHeight);
    
    child.computedWidth = width;
    child.computedHeight = height;

    // Recurse if needed
    if (child.children.isNotEmpty) {
      // For now, assume child handles its own layout in subsequent passes
    }
  }
}
