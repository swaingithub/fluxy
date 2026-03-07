import 'package:flutter/widgets.dart';
import '../layout_guard.dart';

/// An intelligent mini-engine that "solves" impossible layout constraints.
class FluxyConstraintSolver {
  /// Resolves BoxConstraints that would otherwise cause a Flutter crash.
  static BoxConstraints solve(BoxConstraints constraints, {Size? viewportSize}) {
    double maxH = constraints.maxHeight;
    double maxW = constraints.maxWidth;
    bool solved = false;

    // It is perfectly legal and required for ScrollViews to pass infinite constraints to their children.
    // Eagerly clamping them here causes log spam and breaks horizontal/vertical scrolling limits.
    // We defer to Flutter's native RenderBox solver to throw if actual violations occur.

    // Rule: Min must be <= Max
    double minH = constraints.minHeight;
    double minW = constraints.minWidth;

    if (maxH != double.infinity && minH > maxH) {
      minH = maxH;
      solved = true;
    }
    if (maxW != double.infinity && minW > maxW) {
      minW = maxW;
      solved = true;
    }

    if (solved) {
       _logFix('Constraint Normalization', 'Layout constraints normalized to prevent immediate Flutter termination.');
    }

    return BoxConstraints(
      minWidth: minW,
      maxWidth: maxW,
      minHeight: minH,
      maxHeight: maxH,
    );
  }

  /// Fixes an "Expanded inside Scrollable" conflict by returning a fixed height/width 
  /// based on the viewport instead of crashing.
  static double solveFlexConflict(Size viewportSize, Axis direction) {
    _logFix('Flex Conflict Solver', 'Expanded used inside Scrollable. Converting focus to 50% of viewport to prevent crash.');
    return direction == Axis.vertical ? viewportSize.height * 0.5 : viewportSize.width * 0.5;
  }

  static void _logFix(String type, String details) {
    if (!FluxyLayoutGuard.strictMode) {
      debugPrint('[KERNEL] [SOLVER] Constraint anomaly auto-corrected: $type');
      debugPrint('[KERNEL] [DETAILS] $details');
    }
  }
}
