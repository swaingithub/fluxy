import 'package:flutter/widgets.dart';
import '../styles/style.dart';
import 'layout_node.dart';

/// Builder logic for constructing the LayoutNode AST.
class LayoutTreeBuilder {
  static int _idCounter = 0;

  static String _generateId() => 'node_${_idCounter++}';

  /// Builds a Box node.
  static LayoutNode box({FxStyle? style, List<LayoutNode> children = const []}) {
    return LayoutNode(
      id: _generateId(),
      type: NodeType.box,
      style: style ?? FxStyle.none,
      children: children,
    );
  }

  /// Builds a Flex node (Row/Column).
  static LayoutNode flex({required Axis direction, FxStyle? style, List<LayoutNode> children = const []}) {
    return LayoutNode(
      id: _generateId(),
      type: NodeType.flex,
      direction: direction,
      style: style ?? FxStyle.none,
      children: children,
    );
  }

  /// Builds a Text node.
  static LayoutNode text(String content, {FxStyle? style}) {
    return LayoutNode(
      id: _generateId(),
      type: NodeType.text,
      style: style ?? FxStyle.none,
    );
  }

  /// Reset counter (useful for hot-reloads or new tree generations).
  static void resetCounter() {
    _idCounter = 0;
  }
}
