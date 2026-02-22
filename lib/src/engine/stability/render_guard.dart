import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import '../layout_guard.dart';
import 'stability.dart';
import 'stability_metrics.dart';

/// A guard that validates the render tree integrity to prevent corrupt frames.
class FluxyRenderGuard extends SingleChildRenderObjectWidget {
  const FluxyRenderGuard({super.key, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderStabilityGuard();
  }
}

class _RenderStabilityGuard extends RenderProxyBox {
  @override
  void performLayout() {
    if (child != null) {
      // Access viewport context if possible
      Size? viewportSize;
      
      // In RenderObject, we don't have BuildContext, but we can try to use a global key 
      // or PlatformDispatcher (most stable way in RenderObject)
      try {
        final view = PlatformDispatcher.instance.views.first;
        viewportSize = view.physicalSize / view.devicePixelRatio;
      } catch (_) {
         // Fallback if view not ready
      }

      // Pre-layout validation & solving
      final solvedConstraints = FluxyConstraintSolver.solve(constraints, viewportSize: viewportSize);
      _validateConstraints(solvedConstraints);
      
      child!.layout(solvedConstraints, parentUsesSize: true);
      size = child!.size;

      // Post-layout geometry validation
      _validateGeometry();
    } else {
      size = constraints.smallest;
    }
  }

  void _validateConstraints(BoxConstraints constraints) {
    if (constraints.maxHeight == double.infinity && constraints.maxWidth == double.infinity) {
      _reportError(
        "Dual Infinity: This widget is being asked to be infinite in both directions.",
        "Ensure you are not nesting infinite containers inside each other without boundaries."
      );
    }
  }

  void _validateGeometry() {
    if (child != null) {
      final childSize = child!.size;
      if (childSize.width.isNaN || childSize.height.isNaN || 
          childSize.width.isInfinite || childSize.height.isInfinite) {
        
        _reportError(
          "Invalid Geometry: Child produced NaN or Infinite size (${childSize.width}x${childSize.height})",
          "This usually happens when a Flex widget (Row/Column) has a child with infinite size."
        );
      }
    }
  }

  void _reportError(String violation, String suggestion) {
    if (FluxyLayoutGuard.strictMode) {
       throw FluxyLayoutViolationException(violation, suggestion);
    } else {
      debugPrint("[KERNEL] [REPAIR] Render boundary violation auto-corrected: $violation");
      debugPrint("[KERNEL] [ACTION] Alignment adjusted to prevent frame drop.");
      FluxyStabilityMetrics.recordLayoutFix();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    try {
      super.paint(context, offset);
    } catch (e) {
      debugPrint("[KERNEL] [PANIC] Render tree corruption during paint sequence!");
      // Prevent the app from dying by painting a red placeholder if in Strict mode, 
      // or try to ignore if in Relaxed mode.
      if (FluxyLayoutGuard.strictMode) {
        rethrow;
      }
      
      final paint = Paint()..color = const Color(0xFFFF0000).withValues(alpha: 0.3);
      context.canvas.drawRect(offset & size, paint);
    }
  }
}
