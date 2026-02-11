import 'package:flutter/widgets.dart';
import '../styles/style.dart';

enum NodeType {
  box,
  flex,
  grid,
  stack,
  text,
  leaf,
}

/// A node in the Fluxy Layout Abstract Syntax Tree (AST).
/// This represents an intermediate representation between the DSL and Flutter RenderObjects.
class LayoutNode {
  final String id;
  final NodeType type;
  final Axis? direction;
  final Style style;
  final List<LayoutNode> children;
  
  // Computed layout data (caching)
  double? computedWidth;
  double? computedHeight;
  double? x = 0;
  double? y = 0;

  LayoutNode({
    required this.id,
    required this.type,
    this.direction,
    required this.style,
    this.children = const [],
  });

  /// Deep copy of the node for diffing purposes.
  LayoutNode clone() {
    return LayoutNode(
      id: id,
      type: type,
      style: style,
      children: children.map((c) => c.clone()).toList(),
    );
  }

  /// Traverses the tree and applies an action to each node.
  void visit(void Function(LayoutNode node) action) {
    action(this);
    for (var child in children) {
      child.visit(action);
    }
  }

  /// Finds a node by its ID using DFS.
  LayoutNode? findById(String targetId) {
    if (id == targetId) return this;
    for (var child in children) {
      final found = child.findById(targetId);
      if (found != null) return found;
    }
    return null;
  }

  @override
  String toString() {
    return 'LayoutNode(id: $id, type: $type, children: ${children.length})';
  }
}
