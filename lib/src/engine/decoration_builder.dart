import 'package:flutter/widgets.dart';
import '../styles/style.dart';
import '../debug/debug_config.dart';

/// FxDecorationBuilder converts a Fluxy FxStyle into optimized Flutter visual objects.
class FxDecorationBuilder {
  /// Builds a BoxDecoration from a Fluxy FxStyle.
  static BoxDecoration build(FxStyle style) {
    BoxBorder? border = style.border;

    // Inject debug border if active
    if (FluxyDebugConfig.showLayoutBorders) {
      border = Border.all(color: const Color(0xFFFF00FF), width: 1);
    }

    return BoxDecoration(
      color: style.backgroundColor,
      gradient: style.gradient,
      boxShadow: style.shadows,
      borderRadius: style.borderRadius,
      border: border,
    );
  }

  /// Extracts textual styling.
  static TextStyle textStyle(FxStyle style) {
    return TextStyle(
      color: style.color,
      fontSize: style.fontSize,
      fontWeight: style.fontWeight,
      fontFamily: style.fontFamily,
      letterSpacing: style.letterSpacing,
      height: style.lineHeight,
    );
  }

  /// Determines if a style requires a Container/Decoration wrapper.
  static bool hasVisuals(FxStyle style) {
    return style.backgroundColor != null ||
        style.gradient != null ||
        style.shadows != null ||
        style.borderRadius != null ||
        style.border != null ||
        style.opacity != null;
  }
}
