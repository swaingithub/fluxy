import 'package:flutter/widgets.dart';
import '../styles/style.dart';
import 'layout_node.dart';
import 'flex_layout_solver.dart';
import 'grid_layout_solver.dart';

/// The LayoutEngine is responsible for translating Fluxy AST nodes
/// into solved layout dimensions and constraints.
class LayoutEngine {
  /// Solves the layout for a given node tree starting from top-level constraints.
  static void solve(LayoutNode node, BoxConstraints constraints) {
    // Delegate to specialized solvers based on node type
    if (node.type == NodeType.flex) {
      FlexLayoutSolver.solve(
        node,
        constraints,
        node.direction ?? Axis.vertical,
      );
      return;
    }

    if (node.type == NodeType.grid) {
      GridLayoutSolver.solve(node, constraints);
      return;
    }

    // Default solving logic for basic Box nodes
    final resolvedConstraints = _resolveConstraints(node.style, constraints);

    // 2. Initial size calculation
    node.computedWidth = resolvedConstraints.hasTightWidth
        ? resolvedConstraints.maxWidth
        : (node.style.width ?? constraints.maxWidth);

    node.computedHeight = resolvedConstraints.hasTightHeight
        ? resolvedConstraints.maxHeight
        : (node.style.height ?? constraints.maxHeight);

    // 3. Child layout solving (Recursive)
    if (node.children.isNotEmpty) {
      for (var child in node.children) {
        // Pass down constraints (simplified for now, doesn't handle flex-grow/shrink yet)
        solve(child, resolvedConstraints);
      }
    }

    // 4. Perform final size adjustments (e.g., shrink-wrap to children if no fixed size)
    // This is where web-style "fit-content" behavior would be implemented.
  }

  /// Resolves the final constraints for a Fluxy FxStyle.
  static BoxConstraints _resolveConstraints(
    FxStyle style,
    BoxConstraints constraints,
  ) {
    double minWidth = 0;
    double maxWidth = constraints.maxWidth;
    double minHeight = 0;
    double maxHeight = constraints.maxHeight;

    if (style.width != null) {
      minWidth = style.width!;
      maxWidth = style.width!;
    }

    if (style.height != null) {
      minHeight = style.height!;
      maxHeight = style.height!;
    }

    return BoxConstraints(
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
    );
  }

  /// Diffing utility to determine if layout solver needs to run again.
  static bool shouldRelayout(LayoutNode oldTree, LayoutNode newTree) {
    if (oldTree.type != newTree.type) return true;
    if (oldTree.style != newTree.style) return true;
    if (oldTree.children.length != newTree.children.length) return true;

    for (int i = 0; i < oldTree.children.length; i++) {
      if (shouldRelayout(oldTree.children[i], newTree.children[i])) return true;
    }

    return false;
  }
}
