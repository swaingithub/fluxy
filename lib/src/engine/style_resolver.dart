import 'package:flutter/material.dart';
import '../styles/style.dart';
import '../styles/tokens.dart';
import 'tailwind_parser.dart';

/// FxStyleResolver is responsible for merging and resolving the final
/// computed style of a Fluxy widget.
class FxStyleResolver {
  /// Resolves the final style from a widget's static style and responsive options.
  static FxStyle resolve(
    BuildContext context, {
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

    // 5. Final Theme Resolution (colors, fonts, etc.)
    return _resolveTheme(context, finalStyle);
  }

  static FxStyle _resolveTheme(BuildContext context, FxStyle style) {
    Color? color = style.color;
    Color? bgColor = style.backgroundColor;

    if (color is FxThemeColor) {
      color = _resolveColor(context, color);
    }
    if (bgColor is FxThemeColor) {
      bgColor = _resolveColor(context, bgColor);
    }

    // Resolve interactive styles recursively
    FxStyle? hover = style.hover;
    if (hover != null) hover = _resolveTheme(context, hover);

    FxStyle? pressed = style.pressed;
    if (pressed != null) pressed = _resolveTheme(context, pressed);

    return style.copyWith(
      color: color,
      backgroundColor: bgColor,
      hover: hover,
      pressed: pressed,
    );
  }

  static Color _resolveColor(BuildContext context, FxThemeColor themeColor) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    switch (themeColor.key) {
      case FxThemeColorKey.primary:
        return scheme.primary;
      case FxThemeColorKey.secondary:
        return scheme.secondary;
      case FxThemeColorKey.success:
        return const Color(0xFF10B981); // Evergreen success color
      case FxThemeColorKey.error:
        return scheme.error;
      case FxThemeColorKey.warning:
        return const Color(0xFFF59E0B);
      case FxThemeColorKey.info:
        return const Color(0xFF3B82F6);
      case FxThemeColorKey.background:
        return scheme.surface;
      case FxThemeColorKey.surface:
        return scheme.surfaceContainerHighest;
      case FxThemeColorKey.text:
        return scheme.onSurface;
      case FxThemeColorKey.muted:
        return scheme.onSurfaceVariant;
    }
  }

  /// Resolves the final style considering interactive states.
  static FxStyle resolveInteractive(
    FxStyle base, {
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
