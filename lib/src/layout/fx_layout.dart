import 'package:flutter/widgets.dart';
import 'breakpoint.dart';

class FxLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const FxLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final device = FxBreakpoint.deviceType(context);
    
    if (device == FxDeviceType.desktop && desktop != null) return desktop!;
    if (device == FxDeviceType.tablet && tablet != null) return tablet!;
    return mobile;
  }
}
