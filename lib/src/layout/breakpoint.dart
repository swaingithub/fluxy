import 'package:flutter/widgets.dart';

enum FxDeviceType { mobile, tablet, desktop }

class FxBreakpoint {
  final double width;
  const FxBreakpoint(this.width);

  static const double xs = 480;
  static const double sm = 640;
  static const double md = 900;
  static const double lg = 1200;

  static FxDeviceType deviceType(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < sm) return FxDeviceType.mobile;
    if (w < lg) return FxDeviceType.tablet;
    return FxDeviceType.desktop;
  }

  static T value<T>(
    BuildContext context, {
    required T xs,
    T? sm,
    T? md,
    T? lg,
    T? xl,
  }) {
    final w = MediaQuery.of(context).size.width;
    if (w < FxBreakpoint.xs) return xs;
    if (w < FxBreakpoint.sm) return sm ?? xs;
    if (w < FxBreakpoint.md) return md ?? sm ?? xs;
    if (w < FxBreakpoint.lg) return lg ?? md ?? sm ?? xs;
    return xl ?? lg ?? md ?? sm ?? xs;
  }
}
