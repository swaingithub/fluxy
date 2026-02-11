import 'package:flutter/widgets.dart';
import '../styles/style.dart';
import '../debug/debug_config.dart';

/// DecorationBuilder converts a Fluxy Style into optimized Flutter visual objects.
class DecorationBuilder {
  /// Builds a BoxDecoration from a Fluxy Style.
  static BoxDecoration build(Style style) {
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
  static TextStyle textStyle(Style style) {
    return TextStyle(
      color: style.color,
      fontSize: style.fontSize,
      fontWeight: style.fontWeight,
      fontFamily: style.fontFamily,
    );
  }

  /// Determines if a style requires a Container/Decoration wrapper.
  static bool hasVisuals(Style style) {
    return style.backgroundColor != null ||
           style.gradient != null ||
           style.shadows != null ||
           style.borderRadius != null ||
           style.border != null;
  }
}
