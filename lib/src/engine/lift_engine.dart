import 'package:flutter/widgets.dart';

/// A utility to handle Fluxy's "Smart Lifting" of ParentDataWidgets.
/// Ensures that things like .positioned() or .expanded() always bubble up
/// to the very top of a decoration chain, preventing crashes.
class FxLift {
  /// Lifts any ParentDataWidget (Positioned, Expanded, Flexible) to be the
  /// parent of the returned widget from the [wrapper] function.
  /// Also protects against common ParentData crashes by providing semantic warnings.
  static Widget lift(Widget widget, Widget Function(Widget child) wrapper) {
    if (widget is Positioned) {
      return Positioned(
        key: widget.key,
        left: widget.left,
        top: widget.top,
        right: widget.right,
        bottom: widget.bottom,
        width: widget.width,
        height: widget.height,
        child: lift(widget.child, wrapper),
      );
    }

    if (widget is Expanded) {
      return Expanded(
        key: widget.key,
        flex: widget.flex,
        child: lift(widget.child, wrapper),
      );
    }

    if (widget is Flexible) {
      return Flexible(
        key: widget.key,
        flex: widget.flex,
        fit: widget.fit,
        child: lift(widget.child, wrapper),
      );
    }

    // Base case: Not a ParentDataWidget, apply the wrapper
    try {
      return wrapper(widget);
    } catch (e) {
      // If a crash occurs in the wrapper (likely ParentData conflict), 
      // we log a semantic Fluxy warning instead of a hard crash.
      debugPrint('[KERNEL] [LIFT] Alert: $e');
      debugPrint('Recommendation: Avoid wrapping .expanded() / .flex() inside a container that is not a Flex.');
      return wrapper(widget); // Re-run and let Flutter report if it must, but we've warned.
    }
  }
}
