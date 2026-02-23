import 'package:flutter/widgets.dart';
import '../styles/style.dart';

/// Standard policy returned by the guard to instruct widgets how to behave safely.
class FxSafePolicy {
  final bool useShrinkWrap;
  final ScrollPhysics? physics;
  final bool shouldBypassExpanded;
  final String? violation;

  const FxSafePolicy({
    this.useShrinkWrap = false,
    this.physics,
    this.shouldBypassExpanded = false,
    this.violation,
  });
}

/// The core exception thrown when Fluxy detects a layout violation in Strict Mode.
class FluxyLayoutViolationException implements Exception {
  final String violation;
  final String suggestion;

  FluxyLayoutViolationException(this.violation, this.suggestion);

  @override
  String toString() {
    return '[LAYOUT] Violation: $violation | Recommendation: $suggestion';
  }
}

/// The core engine behind Fluxy SafeUI.
/// Dynamically detects and auto-fixes common Flutter layout violations.
class FluxyLayoutGuard {
  static bool debugMode = true;
  static bool strictMode = false;
  static final List<String> _violationLog = [];

  static List<String> get violations => List.unmodifiable(_violationLog);

  /// Evaluates constraints for a scrollable child.
  static FxSafePolicy evaluateScrollable(BoxConstraints constraints, Axis direction) {
    final bool isVertical = direction == Axis.vertical;
    final bool isUnbounded = isVertical ? !constraints.hasBoundedHeight : !constraints.hasBoundedWidth;

    if (isUnbounded) {
      final msg = "Scrollable detected in Unbounded ${isVertical ? 'Height' : 'Width'}";
      _logViolation(msg, 'Apply a height/width constraint or use shrinkWrap: true.');
      return FxSafePolicy(
        useShrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        violation: msg,
      );
    }

    return const FxSafePolicy();
  }

  /// Evaluates if an Expanded/Flexible widget can safely be used.
  static bool canExpand(BoxConstraints constraints, Axis direction) {
    final bool isVertical = direction == Axis.vertical;
    final bool isUnbounded = isVertical ? !constraints.hasBoundedHeight : !constraints.hasBoundedWidth;

    if (isUnbounded) {
      _logViolation(
        "Expansion Alert: Attempted to flex in Unbounded ${isVertical ? 'Height' : 'Width'}", 
        'Expansion (Expanded/Flexible) requires bounded constraints. In scrollables, children must have a fixed size or intrinsic size.'
      );
      return false;
    }
    return true;
  }

  /// Guards against infinite cross-axis stretching in scrollable contexts.
  static CrossAxisAlignment guardCrossAxis(
    BuildContext context,
    Axis flexDirection,
    CrossAxisAlignment alignment,
  ) {
    if (alignment != CrossAxisAlignment.stretch) return alignment;

    final scrollInfo = FxScrollInfo.of(context);
    if (scrollInfo == null) return alignment;

    // If the flex's cross-axis is the same as the scroll-axis, it will have infinite constraints.
    // Row cross-axis is vertical. Col cross-axis is horizontal.
    final bool isIllegal = (flexDirection == Axis.horizontal && scrollInfo.direction == Axis.vertical) ||
                         (flexDirection == Axis.vertical && scrollInfo.direction == Axis.horizontal);

    if (isIllegal) {
      final msg = 'Cross-Axis Stretch detected in Unbounded ${scrollInfo.direction.name}';
      _logViolation(msg, 'Switched to CrossAxisAlignment.center to prevent crash.');
      return CrossAxisAlignment.center;
    }

    return alignment;
  }


  /// Evaluates a Box's dimensions against constraints to prevent infinite size crashes.
  static FxStyle evaluateBoxSafety(BoxConstraints constraints, FxStyle base) {
    final isInfiniteH = base.height == double.infinity;
    final isInfiniteW = base.width == double.infinity;
    
    bool hasViolation = false;
    double? safeHeight = base.height;
    double? safeWidth = base.width;

    if (isInfiniteH && !constraints.hasBoundedHeight) {
      hasViolation = true;
      safeHeight = null; // Fallback to auto
      _logViolation(
        'Box .hFull() inside Unbounded Height', 
        'Remove .hFull() or wrap in a constrained parent.'
      );
    }
    
    if (isInfiniteW && !constraints.hasBoundedWidth) {
      hasViolation = true;
      safeWidth = null; // Fallback to auto
      _logViolation(
        'Box .wFull() inside Unbounded Width', 
        'Remove .wFull() or wrap in a constrained parent.'
      );
    }

    if (hasViolation) {
      return base.copyWith(
        width: safeWidth,
        height: safeHeight,
        autoWidth: safeWidth == null,
        autoHeight: safeHeight == null,
      );
    }
    return base;
  }

  static void _logViolation(String violation, String suggestion) {
    final entry = '[$violation] -> $suggestion';
    if (!_violationLog.contains(entry)) {
        _violationLog.add(entry);
    }
    
    if (strictMode) {
      throw FluxyLayoutViolationException(violation, suggestion);
    }
    
    if (!debugMode) return;
    debugPrint('┌───────────────────────────────────────────┐');
    debugPrint('│ [KERNEL] [AUDIT] Layout anomaly detected   │');
    debugPrint('├───────────────────────────────────────────┤');
    debugPrint('│ Type: $violation');
    debugPrint('│ Rec:  $suggestion');
    debugPrint('└───────────────────────────────────────────┘');
  }

  static void clearLogs() => _violationLog.clear();
}

/// Inherited widget to pass scroll context down the tree.
/// Used by FxSafeExpansion to prevent layout crashes.
class FxScrollInfo extends InheritedWidget {
  final Axis direction;
  final BoxConstraints viewportConstraints;
  const FxScrollInfo({
    super.key,
    required this.direction,
    required this.viewportConstraints,
    required super.child,
  });

  static FxScrollInfo? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FxScrollInfo>();

  @override
  bool updateShouldNotify(FxScrollInfo oldWidget) =>
      direction != oldWidget.direction || viewportConstraints != oldWidget.viewportConstraints;
}

/// Inherited widget to pass down the current Flex direction (Row vs Column).
/// Used by FxSafeExpansion to prevent layout crashes.
class FxFlexInfo extends InheritedWidget {
  final Axis direction;
  const FxFlexInfo({
    super.key,
    required this.direction,
    required super.child,
  });

  static Axis? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FxFlexInfo>()?.direction;

  @override
  bool updateShouldNotify(FxFlexInfo oldWidget) => direction != oldWidget.direction;
}

/// A wrapper that dynamically decides whether to apply Flexible/Expanded
/// based on the surrounding scroll context.
class FxSafeExpansion extends StatelessWidget {
  final Widget child;
  final int flex;
  final FlexFit fit;
  final Axis? direction;

  const FxSafeExpansion({
    super.key,
    required this.child,
    this.flex = 1,
    this.fit = FlexFit.loose,
    this.direction,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Determine expansion direction
    // If direction is provided, use it. Otherwise, try to infer from parent FxRow/FxCol.
    final parentFlexDirection = FxFlexInfo.of(context);
    final effectiveDirection = direction ?? parentFlexDirection ?? Axis.horizontal;

    // 2. Check if we are inside a Fluxy Scrollable
    final scrollInfo = context.dependOnInheritedWidgetOfExactType<FxScrollInfo>();

    // VITAL SAFETY CHECK:
    // If we are in a scrollview and trying to expand in the SAME direction as the scroll,
    // we MUST block expansion to prevent a hard Flutter viewport crash.
    if (scrollInfo != null && scrollInfo.direction == effectiveDirection) {
      if (FluxyLayoutGuard.debugMode) {
        debugPrint('[KERNEL] [AUDIT] Intercepted illegal expansion in ${effectiveDirection.name} scroll axis.');
      }
      return child; 
    }

    return Flexible(
      flex: flex,
      fit: fit,
      child: child,
    );
  }
}
