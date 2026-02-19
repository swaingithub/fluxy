import 'package:flutter/widgets.dart';
import '../layout_guard.dart';
import 'stability_metrics.dart';

/// A widget that protects against the "Unbounded Height/Width" crash in scrollables.
class FluxyViewportGuard extends StatelessWidget {
  final Widget child;
  final Axis direction;
  final double? fallbackMaxHeight;
  final double? fallbackMaxWidth;

  const FluxyViewportGuard({
    super.key,
    required this.child,
    this.direction = Axis.vertical,
    this.fallbackMaxHeight,
    this.fallbackMaxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isVertical = direction == Axis.vertical;
        final bool isUnbounded = isVertical 
            ? !constraints.hasBoundedHeight 
            : !constraints.hasBoundedWidth;

        if (isUnbounded) {
          if (FluxyLayoutGuard.strictMode) {
            throw FluxyLayoutViolationException(
              "Viewport Guard: Unbounded ${isVertical ? 'Height' : 'Width'} detected.",
              "Wrap your scrollable in a container with a fixed ${isVertical ? 'height' : 'width'} or use Relaxed Mode for auto-repair."
            );
          }

          // Relaxed Mode: Auto-repair
          final mediaQuery = MediaQuery.of(context);
          final safeMaxHeight = fallbackMaxHeight ?? mediaQuery.size.height;
          final safeMaxWidth = fallbackMaxWidth ?? mediaQuery.size.width;

          FluxyStabilityMetrics.recordViewportFix();

          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: isVertical ? safeMaxHeight : constraints.maxHeight,
              maxWidth: !isVertical ? safeMaxWidth : constraints.maxWidth,
            ),
            child: child,
          );
        }

        return child;
      },
    );
  }
}
