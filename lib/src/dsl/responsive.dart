import 'package:flutter/widgets.dart';
import '../layout/breakpoint.dart';

/// Responsive value holder for Tailwind-like syntax
/// Example: Fx.text("Hello").fontSize(xs: 14, md: 18, lg: 24)
class FxResponsiveValue<T> {
  final T? xs;  // Mobile (< 480px)
  final T? sm;  // Mobile landscape (< 640px)
  final T? md;  // Tablet (< 900px)
  final T? lg;  // Desktop (< 1200px)
  final T? xl;  // Large desktop (>= 1200px)

  const FxResponsiveValue({
    this.xs,
    this.sm,
    this.md,
    this.lg,
    this.xl,
  });

  /// Get the value for current screen width
  T resolve(BuildContext context, T defaultValue) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= FxBreakpoint.lg) {
      return xl ?? lg ?? md ?? sm ?? xs ?? defaultValue;
    } else if (width >= FxBreakpoint.md) {
      return lg ?? md ?? sm ?? xs ?? defaultValue;
    } else if (width >= FxBreakpoint.sm) {
      return md ?? sm ?? xs ?? defaultValue;
    } else if (width >= FxBreakpoint.xs) {
      return sm ?? xs ?? defaultValue;
    } else {
      return xs ?? defaultValue;
    }
  }
}

/// Extension to make any widget responsive with Tailwind-like syntax
extension FxResponsiveWidgetExtension on Widget {
  /// Show widget only on specific breakpoints
  /// Example: MyWidget().showOn(mobile: true, desktop: false)
  Widget showOn({
    bool? mobile,
    bool? tablet,
    bool? desktop,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isMobile = width < FxBreakpoint.sm;
        final isTablet = width >= FxBreakpoint.sm && width < FxBreakpoint.lg;
        final isDesktop = width >= FxBreakpoint.lg;

        if (mobile == true && isMobile) return this;
        if (tablet == true && isTablet) return this;
        if (desktop == true && isDesktop) return this;
        
        // If no match, hide
        if (mobile != null || tablet != null || desktop != null) {
          return const SizedBox.shrink();
        }
        
        return this;
      },
    );
  }

  /// Hide widget on specific breakpoints
  /// Example: MyWidget().hideOn(mobile: true)
  Widget hideOn({
    bool? mobile,
    bool? tablet,
    bool? desktop,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isMobile = width < FxBreakpoint.sm;
        final isTablet = width >= FxBreakpoint.sm && width < FxBreakpoint.lg;
        final isDesktop = width >= FxBreakpoint.lg;

        if (mobile == true && isMobile) return const SizedBox.shrink();
        if (tablet == true && isTablet) return const SizedBox.shrink();
        if (desktop == true && isDesktop) return const SizedBox.shrink();
        
        return this;
      },
    );
  }
}

/// Helper to get responsive values easily
class FxResponsive {
  /// Get responsive value based on screen width
  /// Example: FxResponsive.value(context, xs: 12, md: 16, lg: 24)
  static T value<T>(
    BuildContext context, {
    required T xs,
    T? sm,
    T? md,
    T? lg,
    T? xl,
  }) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= FxBreakpoint.lg) {
      return xl ?? lg ?? md ?? sm ?? xs;
    } else if (width >= FxBreakpoint.md) {
      return lg ?? md ?? sm ?? xs;
    } else if (width >= FxBreakpoint.sm) {
      return md ?? sm ?? xs;
    } else if (width >= FxBreakpoint.xs) {
      return sm ?? xs;
    } else {
      return xs;
    }
  }

  /// Get responsive padding
  /// Example: FxResponsive.padding(xs: 16, md: 24, lg: 32)
  static EdgeInsets padding({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
  }) {
    return EdgeInsets.all(xs ?? 0);
  }
}
