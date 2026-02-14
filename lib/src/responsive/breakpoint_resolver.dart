import '../styles/style.dart';
import 'responsive_engine.dart';

/// BreakpointResolver implements the mobile-first style override pipeline.
class BreakpointResolver {
  /// Resolves the effective style for the current breakpoint using a cascade approach.
  /// (sm inherits from xs, md from sm, and so on).
  static FxStyle resolve(FxResponsiveStyle responsive, Breakpoint current) {
    FxStyle effective = responsive.xs;

    if (current == Breakpoint.xs) return effective;

    // sm
    if (responsive.sm != null) {
      effective = effective.merge(responsive.sm);
    }
    if (current == Breakpoint.sm) return effective;

    // md
    if (responsive.md != null) {
      effective = effective.merge(responsive.md);
    }
    if (current == Breakpoint.md) return effective;

    // lg
    if (responsive.lg != null) {
      effective = effective.merge(responsive.lg);
    }
    if (current == Breakpoint.lg) return effective;

    // xl
    if (responsive.xl != null) {
      effective = effective.merge(responsive.xl);
    }

    return effective;
  }
}
