import 'package:flutter/widgets.dart';
import '../styles/style.dart';
import 'tailwind_parser.dart';

/// FxStyleResolver is responsible for merging and resolving the final 
/// computed style of a Fluxy widget.
class FxStyleResolver {
  /// Resolves the final style from a widget's static style and responsive options.
  static FxStyle resolve(BuildContext context, {
    FxStyle? style,
    String? className,
    FxResponsiveStyle? responsive,
    List<FxStyle>? baseStyles,
  }) {
    FxStyle finalStyle = FxStyle.none;

    // 1. Apply base styles (like global CSS defaults)
    if (baseStyles != null) {
      for (var s in baseStyles) {
        finalStyle = finalStyle.merge(s);
      }
    }

    // 2. Apply utility classes (Tailwind style)
    if (className != null) {
      finalStyle = finalStyle.merge(Tailwind.parse(className));
    }

    // 3. Apply responsive style if present
    if (responsive != null) {
      finalStyle = finalStyle.merge(responsive.resolve(context));
    }

    // 4. Apply the specific style (inline style override)
    if (style != null) {
      finalStyle = finalStyle.merge(style);
    }

    return finalStyle;
  }

  /// Resolves the final style considering interactive states.
  static FxStyle resolveInteractive(FxStyle base, {
    required bool isHovered,
    required bool isPressed,
  }) {
    FxStyle finalStyle = base;
    if (isHovered && base.hover != null) {
      finalStyle = finalStyle.merge(base.hover);
    }
    if (isPressed && base.pressed != null) {
      finalStyle = finalStyle.merge(base.pressed);
    }
    return finalStyle;
  }

  /// Merges a list of styles with right-to-left precedence.
  static FxStyle merge(List<FxStyle?> styles) {
    FxStyle finalStyle = FxStyle.none;
    for (var s in styles) {
      if (s != null) {
        finalStyle = finalStyle.merge(s);
      }
    }
    return finalStyle;
  }
}
