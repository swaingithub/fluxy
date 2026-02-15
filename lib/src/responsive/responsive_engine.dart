import 'package:flutter/widgets.dart';

/// Defines standard web-style breakpoints for Fluxy.
enum Breakpoint {
  xs, // < 600
  sm, // >= 600
  md, // >= 900
  lg, // >= 1200
  xl, // >= 1536
}

/// ResponsiveEngine manages the detection and configuration of viewport breakpoints.
class ResponsiveEngine {
  static double xs = 0;
  static double sm = 600;
  static double md = 900;
  static double lg = 1200;
  static double xl = 1536;

  /// Standard container max-widths.
  static double containerXs = double.infinity;
  static double containerSm = 540;
  static double containerMd = 720;
  static double containerLg = 960;
  static double containerXl = 1140;

  /// Detects the current breakpoint based on screen width.
  static Breakpoint getBreakpoint(double width) {
    if (width >= xl) return Breakpoint.xl;
    if (width >= lg) return Breakpoint.lg;
    if (width >= md) return Breakpoint.md;
    if (width >= sm) return Breakpoint.sm;
    return Breakpoint.xs;
  }

  /// Convenience method to get breakpoint from context.
  static Breakpoint of(BuildContext context) {
    return getBreakpoint(MediaQuery.of(context).size.width);
  }

  /// Gets the recommended container width for the current breakpoint.
  static double containerWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= xl) return containerXl;
    if (width >= lg) return containerLg;
    if (width >= md) return containerMd;
    if (width >= sm) return containerSm;
    return containerXs;
  }

  /// Selects a value based on the current breakpoint.
  static T value<T>(
    BuildContext context, {
    required T xs,
    T? sm,
    T? md,
    T? lg,
    T? xl,
  }) {
    final bp = of(context);
    switch (bp) {
      case Breakpoint.xs:
        return xs;
      case Breakpoint.sm:
        return sm ?? xs;
      case Breakpoint.md:
        return md ?? sm ?? xs;
      case Breakpoint.lg:
        return lg ?? md ?? sm ?? xs;
      case Breakpoint.xl:
        return xl ?? lg ?? md ?? sm ?? xs;
    }
  }
}
