import 'package:flutter/widgets.dart';
import '../responsive/responsive_engine.dart';

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
    final bp = ResponsiveEngine.of(context);
    
    if ((bp == Breakpoint.lg || bp == Breakpoint.xl) && desktop != null) {
      return desktop!;
    }
    if ((bp == Breakpoint.sm || bp == Breakpoint.md) && tablet != null) {
      return tablet!;
    }
    return mobile;
  }
}
