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
      color = resolveColor(context, color);
    }
    if (bgColor is FxThemeColor) {
      bgColor = resolveColor(context, bgColor);
    }

    // Resolve interactive styles recursively
    FxStyle? hover = style.hover;
    if (hover != null) hover = _resolveTheme(context, hover);

    FxStyle? pressed = style.pressed;
    if (pressed != null) pressed = _resolveTheme(context, pressed);

    return style.copyWith(
      color: color,
      backgroundColor: bgColor,
      border: _resolveBorder(context, style.border),
      borderTop: _resolveBorderSideNullable(context, style.borderTop),
      borderBottom: _resolveBorderSideNullable(context, style.borderBottom),
      borderLeft: _resolveBorderSideNullable(context, style.borderLeft),
      borderRight: _resolveBorderSideNullable(context, style.borderRight),
      shadows: _resolveShadows(context, style.shadows),
      gradient: _resolveGradient(context, style.gradient),
      hover: hover,
      pressed: pressed,
    );
  }

  static BorderSide? _resolveBorderSideNullable(BuildContext context, BorderSide? side) {
    if (side == null) return null;
    return _resolveBorderSide(context, side);
  }

  static BoxBorder? _resolveBorder(BuildContext context, BoxBorder? border) {
    if (border == null) return null;
    if (border is Border) {
      return Border(
        top: _resolveBorderSide(context, border.top),
        bottom: _resolveBorderSide(context, border.bottom),
        left: _resolveBorderSide(context, border.left),
        right: _resolveBorderSide(context, border.right),
      );
    }
    return border;
  }

  static BorderSide _resolveBorderSide(BuildContext context, BorderSide side) {
    if (side.color is FxThemeColor) {
      return side.copyWith(color: resolveColor(context, side.color as FxThemeColor));
    }
    return side;
  }

  static List<BoxShadow>? _resolveShadows(BuildContext context, List<BoxShadow>? shadows) {
    if (shadows == null) return null;
    return shadows.map((s) {
      if (s.color is FxThemeColor) {
        return BoxShadow(
          color: resolveColor(context, s.color as FxThemeColor),
          offset: s.offset,
          blurRadius: s.blurRadius,
          spreadRadius: s.spreadRadius,
          blurStyle: s.blurStyle,
        );
      }
      return s;
    }).toList();
  }

  static Gradient? _resolveGradient(BuildContext context, Gradient? gradient) {
    if (gradient == null) return null;
    List<Color> resolveList(List<Color> colors) =>
        colors.map((c) => c is FxThemeColor ? resolveColor(context, c) : c).toList();

    if (gradient is LinearGradient) {
      return LinearGradient(
        colors: resolveList(gradient.colors),
        stops: gradient.stops,
        begin: gradient.begin,
        end: gradient.end,
        tileMode: gradient.tileMode,
        transform: gradient.transform,
      );
    }
    if (gradient is RadialGradient) {
      return RadialGradient(
        colors: resolveList(gradient.colors),
        stops: gradient.stops,
        center: gradient.center,
        radius: gradient.radius,
        focal: gradient.focal,
        focalRadius: gradient.focalRadius,
        tileMode: gradient.tileMode,
        transform: gradient.transform,
      );
    }
    if (gradient is SweepGradient) {
      return SweepGradient(
        colors: resolveList(gradient.colors),
        stops: gradient.stops,
        center: gradient.center,
        startAngle: gradient.startAngle,
        endAngle: gradient.endAngle,
        tileMode: gradient.tileMode,
        transform: gradient.transform,
      );
    }
    return gradient;
  }

  static Color resolveColor(BuildContext context, Color color) {
    if (color is FxThemeColor) {
      final theme = Theme.of(context);
      final scheme = theme.colorScheme;

      switch (color.key) {
        case FxThemeColorKey.primary:
          return scheme.primary;
        case FxThemeColorKey.secondary:
          return scheme.secondary;
        case FxThemeColorKey.success:
          return const Color(0xFF10B981);
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
    return color;
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

  /// NEW: Infers alignment from flex properties (justify/items) for single-child boxes.
  static AlignmentGeometry? inferAlignment(FxStyle style) {
    if (style.alignment != null) return style.alignment;
    if (style.justifyContent == null && style.alignItems == null) return null;

    final isVertical = style.direction != Axis.horizontal;
    double x = 0; 
    double y = 0;

    // Map MainAxis (justify)
    final justify = style.justifyContent ?? MainAxisAlignment.start;
    if (justify == MainAxisAlignment.start) {
      if (isVertical) y = -1; else x = -1;
    } else if (justify == MainAxisAlignment.center) {
      if (isVertical) y = 0; else x = 0;
    } else if (justify == MainAxisAlignment.end) {
      if (isVertical) y = 1; else x = 1;
    }

    // Map CrossAxis (items)
    final items = style.alignItems ?? CrossAxisAlignment.center;
    if (items == CrossAxisAlignment.start) {
      if (isVertical) x = -1; else y = -1;
    } else if (items == CrossAxisAlignment.center) {
      if (isVertical) x = 0; else y = 0;
    } else if (items == CrossAxisAlignment.end) {
      if (isVertical) x = 1; else y = 1;
    }

    return Alignment(x, y);
  }
}
