import 'package:flutter/widgets.dart';
import '../styles/style.dart';

/// DiffEngine compares two states of a UI component to determine
/// if a rebuild or a relayout is necessary.
class DiffEngine {
  /// Returns true if the style or structure has changed enough to require a rebuild.
  static bool shouldRebuild({
    Style? oldStyle,
    Style? newStyle,
    String? oldClassName,
    String? newClassName,
    bool? structuralChange,
  }) {
    if (structuralChange == true) return true;
    if (oldClassName != newClassName) return true;
    if (oldStyle != newStyle) return true;
    
    return false;
  }

  /// Calculates the difference between two LayoutNode trees.
  /// (Simplified version for this DSL)
  static bool hasTreeChanged(List<Widget> oldChildren, List<Widget> newChildren) {
    if (oldChildren.length != newChildren.length) return true;
    
    for (int i = 0; i < oldChildren.length; i++) {
      if (!identical(oldChildren[i], newChildren[i])) {
        return true;
      }
    }
    
    return false;
  }
}
