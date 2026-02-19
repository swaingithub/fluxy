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
    
    // Mobile-first logic:
    // If desktop (lg/xl) AND desktop widget provided -> Desktop
    if ((bp == Breakpoint.lg || bp == Breakpoint.xl) && desktop != null) {
      return desktop!;
    }
    
    // If tablet (md) AND tablet widget provided -> Tablet
    // If tablet (md) AND tablet widget MISSING -> Check if desktop provided? 
    // Usually standard is: MD is Tablet. If no Tablet widget, fallback to Mobile.
    // BUT, some prefer MD to be "Small Desktop" if tablet is missing. 
    // For now, adhere to strict fallback: MD -> Tablet -> Mobile.
    if ((bp == Breakpoint.sm || bp == Breakpoint.md) && tablet != null) {
      return tablet!;
    }

    // Default to mobile for xs, or if specific overrides are missing
    return mobile;
  }
}
