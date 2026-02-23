import 'package:flutter/material.dart';
import '../styles/tokens.dart';
import '../widgets/box.dart';
import '../widgets/text_box.dart';
import '../widgets/flex_box.dart';
import '../widgets/grid_box.dart';
import '../widgets/stack_box.dart';
import '../widgets/list_box.dart';
import '../widgets/button.dart';
import '../routing/fluxy_router.dart';
import '../di/fluxy_di.dart';
import '../widgets/avatar.dart';
import '../widgets/table.dart';
import '../widgets/fx_widget.dart';
import '../engine/lift_engine.dart';
import '../engine/layout_guard.dart';
import '../engine/stability/interaction_guard.dart';
import '../engine/haptics.dart';
import 'fx.dart';

extension FluxyStringExtension on String {
  /// Transforms a string into a primary button.
  FxButton primaryBtn({VoidCallback? onTap}) =>
      Fx.primaryButton(this, onTap: onTap);

  /// Transforms a string into a secondary button.
  FxButton secondaryBtn({VoidCallback? onTap}) =>
      Fx.secondaryButton(this, onTap: onTap);

  /// Transforms a string into a danger button.
  FxButton dangerBtn({VoidCallback? onTap}) =>
      Fx.dangerButton(this, onTap: onTap);

  /// Transforms a string into a success button.
  FxButton successBtn({VoidCallback? onTap}) =>
      Fx.successButton(this, onTap: onTap);

  /// Transforms a string into an outline button.
  FxButton outlineBtn({VoidCallback? onTap}) =>
      Fx.outlineButton(this, onTap: onTap);

  /// Transforms a string into a ghost button.
  FxButton ghostBtn({VoidCallback? onTap}) =>
      Fx.ghostButton(this, onTap: onTap);

  /// Transforms a string into a raw button.
  FxButton btn({VoidCallback? onTap}) => Fx.btn(label: this, onTap: onTap);
}

/// Extension to provide a fluent DSL experience for any Widget.
extension FluxyWidgetExtension on Widget {
  /// Internal helper to apply style to any supported widget or wrap in Box.
  Widget _applyGenericStyle(FxStyle style) {
    return FxLift.lift(this, (child) {
      final self = child;

      // --- Intercept Flex Styles to prevent ParentData issues ---
      // If we're applying a style with flex/flexGrow, we wrap externally here.
      if (style.flex != null || style.flexGrow != null) {
        final flexVal = style.flexGrow ?? style.flex ?? 1;
        final fitVal =
            style.flexFit ??
            (style.flexGrow != null ? FlexFit.loose : FlexFit.tight);

        // Create a new style without flex properties to avoid infinite recursion
        final innerStyle = FxStyle(
          width: style.width,
          height: style.height,
          minWidth: style.minWidth,
          minHeight: style.minHeight,
          maxWidth: style.maxWidth,
          maxHeight: style.maxHeight,
          padding: style.padding,
          margin: style.margin,
          backgroundColor: style.backgroundColor,
          gradient: style.gradient,
          shadows: style.shadows,
          glass: style.glass,
          borderRadius: style.borderRadius,
          border: style.border,
          justifyContent: style.justifyContent,
          alignItems: style.alignItems,
          mainAxisSize: style.mainAxisSize,
          direction: style.direction,
          // Explicitly omit flex, flexGrow, flexShrink, flexFit
          gap: style.gap,
          crossAxisCount: style.crossAxisCount,
          minColumnWidth: style.minColumnWidth,
          childAspectRatio: style.childAspectRatio,
          alignment: style.alignment,
          clipBehavior: style.clipBehavior,
          top: style.top,
          right: style.right,
          bottom: style.bottom,
          left: style.left,
          zIndex: style.zIndex,
          color: style.color,
          fontSize: style.fontSize,
          fontWeight: style.fontWeight,
          textAlign: style.textAlign,
          fontFamily: style.fontFamily,
          overflow: style.overflow,
          maxLines: style.maxLines,
          letterSpacing: style.letterSpacing,
          wordSpacing: style.wordSpacing,
          textDecoration: style.textDecoration,
          lineHeight: style.lineHeight,
          hover: style.hover,
          pressed: style.pressed,
          transition: style.transition,
          cursor: style.cursor,
          opacity: style.opacity,
          aspectRatio: style.aspectRatio,
          transformScale: style.transformScale,
          transformRotation: style.transformRotation,
          fit: style.fit,
          imageBlur: style.imageBlur,
          grayscale: style.grayscale,
          loading: style.loading,
          error: style.error,
          placeholder: style.placeholder,
          imageSrc: style.imageSrc,
        );

        return FxSafeExpansion(
          flex: flexVal,
          fit: fitVal,
          direction: style.direction,
          child: self is FxWidget
              ? self.copyWithStyle(innerStyle)
              : Box(style: innerStyle, child: self),
        );
      }

      // New Attribute Accumulation Logic
      if (self is FxWidget) {
        return self.copyWithStyle(style);
      }

      // Wrap generic widget
      return Box(style: style, child: self);
    });
  }

  /// Applies a custom style object to the widget.
  Widget style(FxStyle style) => _applyGenericStyle(style);

  /// Internal helper to apply responsive style.
  Widget _applyResponsive(FxResponsiveStyle responsive) {
    return FxLift.lift(this, (child) {
      if (child is FxWidget) {
        return child.copyWithResponsive(responsive);
      }
      return Box(responsive: responsive, child: child);
    });
  }


  /// Positions a widget within a Stack.
  Widget positioned({
    double? top,
    double? right,
    double? bottom,
    double? left,
    double? width,
    double? height,
  }) {
    return Positioned(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
      width: width,
      height: height,
      child: this,
    );
  }

  /// Internal helper to apply a shadow to the widget.
  Widget _applyShadow({
    Color color = const Color(0x1F000000),
    double blur = 4,
    Offset offset = const Offset(0, 2),
  }) {
    return _applyGenericStyle(
      FxStyle(
        shadows: [
          BoxShadow(
            color: color,
            blurRadius: blur,
            offset: offset,
          ),
        ],
      ),
    );
  }

  // --- Proxy Properties for New Syntax ---

  /// Background styling proxy: .bg.white, .bg.color(Colors.blue)
  FxBgProxy get bg => FxBgProxy(this);

  /// Width styling proxy: .width(100), .width.full
  FxWidthProxy get width => FxWidthProxy(this);

  /// Height styling proxy: .height(100), .height.full
  FxHeightProxy get height => FxHeightProxy(this);

  /// Weight styling proxy: .weight.bold, .weight.medium
  FxWeightProxy get weight => FxWeightProxy(this);

  // --- Spacing Modifiers ---

  /// Padding modifier with Tailwind-like responsive overrides.
  /// Example: .p(16, md: 24, lg: 32)
  Widget p(double xs, {double? md, double? lg}) {
    if (md == null && lg == null) {
      return _applyGenericStyle(FxStyle(padding: EdgeInsets.all(xs)));
    }
    return _applyResponsive(
      FxResponsiveStyle(
        xs: FxStyle(padding: EdgeInsets.all(xs)),
        md: md != null ? FxStyle(padding: EdgeInsets.all(md)) : null,
        lg: lg != null ? FxStyle(padding: EdgeInsets.all(lg)) : null,
      ),
    );
  }

  Widget px(double xs, {double? md, double? lg}) {
    if (md == null && lg == null) {
      return _applyGenericStyle(
        FxStyle(padding: EdgeInsets.symmetric(horizontal: xs)),
      );
    }
    return _applyResponsive(
      FxResponsiveStyle(
        xs: FxStyle(padding: EdgeInsets.symmetric(horizontal: xs)),
        md: md != null
            ? FxStyle(padding: EdgeInsets.symmetric(horizontal: md))
            : null,
        lg: lg != null
            ? FxStyle(padding: EdgeInsets.symmetric(horizontal: lg))
            : null,
      ),
    );
  }

  Widget py(double xs, {double? md, double? lg}) {
    if (md == null && lg == null) {
      return _applyGenericStyle(
        FxStyle(padding: EdgeInsets.symmetric(vertical: xs)),
      );
    }
    return _applyResponsive(
      FxResponsiveStyle(
        xs: FxStyle(padding: EdgeInsets.symmetric(vertical: xs)),
        md: md != null
            ? FxStyle(padding: EdgeInsets.symmetric(vertical: md))
            : null,
        lg: lg != null
            ? FxStyle(padding: EdgeInsets.symmetric(vertical: lg))
            : null,
      ),
    );
  }

  Widget pt(double xs, {double? md, double? lg}) {
    if (md == null && lg == null) {
      return _applyGenericStyle(FxStyle(padding: EdgeInsets.only(top: xs)));
    }
    return _applyResponsive(
      FxResponsiveStyle(
        xs: FxStyle(padding: EdgeInsets.only(top: xs)),
        md: md != null ? FxStyle(padding: EdgeInsets.only(top: md)) : null,
        lg: lg != null ? FxStyle(padding: EdgeInsets.only(top: lg)) : null,
      ),
    );
  }

  Widget pb(double xs, {double? md, double? lg}) {
    if (md == null && lg == null) {
      return _applyGenericStyle(FxStyle(padding: EdgeInsets.only(bottom: xs)));
    }
    return _applyResponsive(
      FxResponsiveStyle(
        xs: FxStyle(padding: EdgeInsets.only(bottom: xs)),
        md: md != null ? FxStyle(padding: EdgeInsets.only(bottom: md)) : null,
        lg: lg != null ? FxStyle(padding: EdgeInsets.only(bottom: lg)) : null,
      ),
    );
  }

  Widget pl(double xs, {double? md, double? lg}) {
    if (md == null && lg == null) {
      return _applyGenericStyle(FxStyle(padding: EdgeInsets.only(left: xs)));
    }
    return _applyResponsive(
      FxResponsiveStyle(
        xs: FxStyle(padding: EdgeInsets.only(left: xs)),
        md: md != null ? FxStyle(padding: EdgeInsets.only(left: md)) : null,
        lg: lg != null ? FxStyle(padding: EdgeInsets.only(left: lg)) : null,
      ),
    );
  }

  Widget pr(double xs, {double? md, double? lg}) {
    if (md == null && lg == null) {
      return _applyGenericStyle(FxStyle(padding: EdgeInsets.only(right: xs)));
    }
    return _applyResponsive(
      FxResponsiveStyle(
        xs: FxStyle(padding: EdgeInsets.only(right: xs)),
        md: md != null ? FxStyle(padding: EdgeInsets.only(right: md)) : null,
        lg: lg != null ? FxStyle(padding: EdgeInsets.only(right: lg)) : null,
      ),
    );
  }



  /// Aliases for Padding
  Widget padding(double v, {double? md, double? lg}) => p(v, md: md, lg: lg);
  Widget pad(double v, {double? md, double? lg}) => p(v, md: md, lg: lg);
  Widget paddingX(double v, {double? md, double? lg}) => px(v, md: md, lg: lg);
  Widget paddingY(double v, {double? md, double? lg}) => py(v, md: md, lg: lg);

  /// Margin modifier with responsive overrides.
  Widget m(double xs, {double? md, double? lg}) {
    if (md == null && lg == null) {
      return _applyGenericStyle(FxStyle(margin: EdgeInsets.all(xs)));
    }
    return _applyResponsive(
      FxResponsiveStyle(
        xs: FxStyle(margin: EdgeInsets.all(xs)),
        md: md != null ? FxStyle(margin: EdgeInsets.all(md)) : null,
        lg: lg != null ? FxStyle(margin: EdgeInsets.all(lg)) : null,
      ),
    );
  }

  Widget mx(double xs, {double? md, double? lg}) {
    if (md == null && lg == null) {
      return _applyGenericStyle(
        FxStyle(margin: EdgeInsets.symmetric(horizontal: xs)),
      );
    }
    return _applyResponsive(
      FxResponsiveStyle(
        xs: FxStyle(margin: EdgeInsets.symmetric(horizontal: xs)),
        md: md != null
            ? FxStyle(margin: EdgeInsets.symmetric(horizontal: md))
            : null,
        lg: lg != null
            ? FxStyle(margin: EdgeInsets.symmetric(horizontal: lg))
            : null,
      ),
    );
  }

  Widget my(double xs, {double? md, double? lg}) {
    if (md == null && lg == null) {
      return _applyGenericStyle(
        FxStyle(margin: EdgeInsets.symmetric(vertical: xs)),
      );
    }
    return _applyResponsive(
      FxResponsiveStyle(
        xs: FxStyle(margin: EdgeInsets.symmetric(vertical: xs)),
        md: md != null
            ? FxStyle(margin: EdgeInsets.symmetric(vertical: md))
            : null,
        lg: lg != null
            ? FxStyle(margin: EdgeInsets.symmetric(vertical: lg))
            : null,
      ),
    );
  }

  Widget mt(double xs, {double? md, double? lg}) {
    if (md == null && lg == null) {
      return _applyGenericStyle(FxStyle(margin: EdgeInsets.only(top: xs)));
    }
    return _applyResponsive(
      FxResponsiveStyle(
        xs: FxStyle(margin: EdgeInsets.only(top: xs)),
        md: md != null ? FxStyle(margin: EdgeInsets.only(top: md)) : null,
        lg: lg != null ? FxStyle(margin: EdgeInsets.only(top: lg)) : null,
      ),
    );
  }

  Widget mb(double xs, {double? md, double? lg}) {
    if (md == null && lg == null) {
      return _applyGenericStyle(FxStyle(margin: EdgeInsets.only(bottom: xs)));
    }
    return _applyResponsive(
      FxResponsiveStyle(
        xs: FxStyle(margin: EdgeInsets.only(bottom: xs)),
        md: md != null ? FxStyle(margin: EdgeInsets.only(bottom: md)) : null,
        lg: lg != null ? FxStyle(margin: EdgeInsets.only(bottom: lg)) : null,
      ),
    );
  }

  Widget ml(double xs, {double? md, double? lg}) {
    if (md == null && lg == null) {
      return _applyGenericStyle(FxStyle(margin: EdgeInsets.only(left: xs)));
    }
    return _applyResponsive(
      FxResponsiveStyle(
        xs: FxStyle(margin: EdgeInsets.only(left: xs)),
        md: md != null ? FxStyle(margin: EdgeInsets.only(left: md)) : null,
        lg: lg != null ? FxStyle(margin: EdgeInsets.only(left: lg)) : null,
      ),
    );
  }

  Widget mr(double xs, {double? md, double? lg}) {
    if (md == null && lg == null) {
      return _applyGenericStyle(FxStyle(margin: EdgeInsets.only(right: xs)));
    }
    return _applyResponsive(
      FxResponsiveStyle(
        xs: FxStyle(margin: EdgeInsets.only(right: xs)),
        md: md != null ? FxStyle(margin: EdgeInsets.only(right: md)) : null,
        lg: lg != null ? FxStyle(margin: EdgeInsets.only(right: lg)) : null,
      ),
    );
  }



  /// Aliases for Margin
  Widget margin(double v, {double? md, double? lg}) => m(v, md: md, lg: lg);
  Widget marginX(double v, {double? md, double? lg}) => mx(v, md: md, lg: lg);
  Widget marginY(double v, {double? md, double? lg}) => my(v, md: md, lg: lg);



  Widget rounded(double xs, {double? md, double? lg}) {
    if (md == null && lg == null) {
      return _applyGenericStyle(
        FxStyle(borderRadius: BorderRadius.circular(xs)),
      );
    }
    return _applyResponsive(
      FxResponsiveStyle(
        xs: FxStyle(borderRadius: BorderRadius.circular(xs)),
        md: md != null
            ? FxStyle(borderRadius: BorderRadius.circular(md))
            : null,
        lg: lg != null
            ? FxStyle(borderRadius: BorderRadius.circular(lg))
            : null,
      ),
    );
  }

  Widget circle() => _applyGenericStyle(
    const FxStyle(borderRadius: BorderRadius.all(Radius.circular(9999))),
  );

  Widget radius(double xs, {double? md, double? lg}) =>
      rounded(xs, md: md, lg: lg);
  Widget borderRadius(double xs, {double? md, double? lg}) =>
      rounded(xs, md: md, lg: lg);
  Widget roundedFull() => rounded(999);

  Widget border({Color? color, double width = 1, Border? border}) {
    if (border != null) return _applyGenericStyle(FxStyle(border: border));
    return _applyGenericStyle(
      FxStyle(
        border: Border.all(
          color: color ?? const Color(0xFF000000),
          width: width,
        ),
      ),
    );
  }

  Widget borderColor(Color color) =>
      _applyGenericStyle(FxStyle(border: Border.all(color: color)));

  // --- Dimension Modifiers ---

  Widget w(double xs, {double? md, double? lg}) {
    if (md == null && lg == null) return _applyGenericStyle(FxStyle(width: xs));
    return _applyResponsive(
      FxResponsiveStyle(
        xs: FxStyle(width: xs),
        md: md != null ? FxStyle(width: md) : null,
        lg: lg != null ? FxStyle(width: lg) : null,
      ),
    );
  }

  Widget h(double xs, {double? md, double? lg}) {
    if (md == null && lg == null) {
      return _applyGenericStyle(FxStyle(height: xs));
    }
    return _applyResponsive(
      FxResponsiveStyle(
        xs: FxStyle(height: xs),
        md: md != null ? FxStyle(height: md) : null,
        lg: lg != null ? FxStyle(height: lg) : null,
      ),
    );
  }

  Widget wFull() => _applyGenericStyle(const FxStyle(width: double.infinity));
  Widget hFull() => _applyGenericStyle(const FxStyle(height: double.infinity));
  Widget fullWidth() => wFull();
  Widget fullHeight() => hFull();

  Widget size(double xs, {double? h, double? md, double? lg}) {
    if (h == null) {
      if (this is TextBox) return fontSize(xs, md: md, lg: lg);
      return w(xs, md: md, lg: lg).h(xs, md: md, lg: lg);
    }
    return w(xs, md: md, lg: lg).h(h); 
  }

  /// Suffix transparency. Clamped between 0.0 and 1.0 for engine safety.
  Widget opacity(double value) => _applyGenericStyle(FxStyle(opacity: value.clamp(0.0, 1.0)));
  Widget op(double value) => opacity(value);

  /// Standard SafeArea wrapper.
  Widget safe({bool top = true, bool bottom = true}) => 
      FxLift.lift(this, (child) => SafeArea(top: top, bottom: bottom, child: child));

  /// Full control SafeArea wrapper.
  Widget safeArea({
    bool left = true,
    bool top = true,
    bool right = true,
    bool bottom = true,
    EdgeInsets minimum = EdgeInsets.zero,
    bool maintainBottomViewPadding = false,
  }) =>
      FxLift.lift(
        this,
        (child) => SafeArea(
          left: left,
          top: top,
          right: right,
          bottom: bottom,
          minimum: minimum,
          maintainBottomViewPadding: maintainBottomViewPadding,
          child: child,
        ),
      );

  // --- Styling Modifiers ---

  Widget background(Color color) =>
      _applyGenericStyle(FxStyle(backgroundColor: color));
  Widget backgroundWhite() => background(const Color(0xFFFFFFFF));
  Widget backgroundBlack() => background(const Color(0xFF000000));
  Widget gradient(Gradient value) =>
      _applyGenericStyle(FxStyle(gradient: value));

  // --- Image Modifiers ---
  Widget fit(BoxFit value) => _applyGenericStyle(FxStyle(fit: value));
  Widget cover() => fit(BoxFit.cover);
  Widget contain() => fit(BoxFit.contain);
  Widget fill() => fit(BoxFit.fill);

  Widget blur(double value) => _applyGenericStyle(FxStyle(imageBlur: value));
  Widget grayscale() => _applyGenericStyle(const FxStyle(grayscale: true));
  Widget glass([double blur = 10]) => _applyGenericStyle(FxStyle(glass: blur));

  Widget imgLoading(Widget widget) =>
      _applyGenericStyle(FxStyle(loading: widget));
  Widget imgError(Widget widget) => _applyGenericStyle(FxStyle(error: widget));
  Widget imgPlaceholder(Widget widget) =>
      _applyGenericStyle(FxStyle(placeholder: widget));

  Widget scale(double value) =>
      _applyGenericStyle(FxStyle(transformScale: value));
  Widget rotate(double value) =>
      _applyGenericStyle(FxStyle(transformRotation: value));

  Widget clipBehavior(Clip value) =>
      _applyGenericStyle(FxStyle(clipBehavior: value));
  Widget clip() => clipBehavior(Clip.antiAlias);

  // --- Flex/Layout Modifiers ---
  Widget flex([int value = 1]) => _applyGenericStyle(FxStyle(flex: value, flexFit: FlexFit.loose));
  Widget expanded([int value = 1]) => _applyGenericStyle(FxStyle(flex: value, flexFit: FlexFit.tight));
  Widget shrink() => Flexible(fit: FlexFit.loose, child: this);

  FxShadowProxy get shadow => FxShadowProxy(this);

  Widget shadowSmall() =>
      _applyGenericStyle(FxStyle(shadows: FxTokens.shadow.sm));
  Widget shadowMedium() =>
      _applyGenericStyle(FxStyle(shadows: FxTokens.shadow.md));
  Widget shadowLarge() =>
      _applyGenericStyle(FxStyle(shadows: FxTokens.shadow.lg));

  Widget card() => _applyGenericStyle(
    FxStyle(
      backgroundColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
      shadows: FxTokens.shadow.md,
      padding: const EdgeInsets.all(16),
    ),
  );

  // --- Typography ---

  FxFontProxy get font => FxFontProxy(this);

  Widget fontSize(double xs, {double? md, double? lg}) {
    if (md == null && lg == null) {
      return _applyGenericStyle(FxStyle(fontSize: xs));
    }
    return _applyResponsive(
      FxResponsiveStyle(
        xs: FxStyle(fontSize: xs),
        md: md != null ? FxStyle(fontSize: md) : null,
        lg: lg != null ? FxStyle(fontSize: lg) : null,
      ),
    );
  }
  Widget fontWeight(FontWeight weight) =>
      _applyGenericStyle(FxStyle(fontWeight: weight));
  Widget color(Color value) => _applyGenericStyle(FxStyle(color: value));
  Widget textAlign(TextAlign align) =>
      _applyGenericStyle(FxStyle(textAlign: align));
  Widget textCenter() => textAlign(TextAlign.center);

  Widget textXs() => fontSize(FxTokens.font.xs);
  Widget textSm() => fontSize(FxTokens.font.sm);
  Widget textBase() => fontSize(FxTokens.font.md);
  Widget textLg() => fontSize(FxTokens.font.lg);
  Widget textXl() => fontSize(FxTokens.font.xl);

  Widget bold() => fontWeight(FontWeight.bold);
  Widget semiBold() => fontWeight(FontWeight.w600);
  Widget medium() => fontWeight(FontWeight.w500);
  Widget light() => fontWeight(FontWeight.w300);

  // --- Advanced Text Modifiers ---
  Widget spacing(double value) =>
      _applyGenericStyle(FxStyle(letterSpacing: value));
  Widget letterSpacing(double value) => spacing(value);
  Widget wordSpacing(double value) =>
      _applyGenericStyle(FxStyle(wordSpacing: value));
  Widget decoration(TextDecoration value) =>
      _applyGenericStyle(FxStyle(textDecoration: value));
  Widget italic() => _applyGenericStyle(const FxStyle(fontStyle: FontStyle.italic));
  Widget maxLines(int value) => _applyGenericStyle(FxStyle(maxLines: value));
  Widget ellipsis() =>
      _applyGenericStyle(const FxStyle(overflow: TextOverflow.ellipsis));

  // --- Button/Input State Modifiers ---
  Widget loading([bool value = true]) {
    final self = this;
    if (self is FxButton) return self.loading(value);
    return this;
  }

  Widget disabled([bool value = true]) {
    final self = this;
    if (self is FxButton) {
      return self.copyWith(onTap: value ? null : self.onTap);
    }
    return this;
  }

  Widget icon(IconData data, {double? size, Color? color}) {
    final self = this;
    if (self is FxButton) {
      return self.withIcon(Icon(data, size: size, color: color));
    }
    return this;
  }

  // --- Themed Colors ---
  Widget primary() => color(FxTokens.colors.primary);
  Widget secondary() => color(FxTokens.colors.secondary);
  Widget success() => color(FxTokens.colors.success);
  Widget error() => color(FxTokens.colors.error);
  Widget warning() => color(FxTokens.colors.warning);
  Widget info() => color(FxTokens.colors.info);
  Widget whiteText() => color(const Color(0xFFFFFFFF));
  Widget blackText() => color(const Color(0xFF000000));

  // --- Design Tokens (Typography) ---
  Widget h1() => fontSize(FxTokens.font.x4l).bold();
  Widget h2() => fontSize(FxTokens.font.xxxl).bold();
  Widget h3() => fontSize(FxTokens.font.xxl).bold();
  Widget heading() => h2();
  Widget body() => fontSize(FxTokens.font.md);
  Widget caption() => fontSize(FxTokens.font.xs).color(FxTokens.colors.muted);
  Widget muted() => color(FxTokens.colors.muted);

  // --- Flex Layout Modifiers ---

  Widget justify(MainAxisAlignment value) =>
      _applyGenericStyle(FxStyle(justifyContent: value));
  /// Align children along the cross-axis.
  Widget alignItems(CrossAxisAlignment value) =>
      _applyGenericStyle(FxStyle(alignItems: value));

  @Deprecated('Use alignItems() instead for consistency with Fluxy styles.')
  Widget items(CrossAxisAlignment value) => alignItems(value);

  @Deprecated('Use Fx.gap() widget instead for better layout performance')
  Widget gap(double value) => _applyGenericStyle(FxStyle(gap: value));

  /// Sets the min height of the widget.
  Widget minH(double value) => _applyGenericStyle(FxStyle(minHeight: value));

  /// Sets the max height of the widget.
  Widget maxH(double value) => _applyGenericStyle(FxStyle(maxHeight: value));

  /// Sets the min width of the widget.
  Widget minW(double value) => _applyGenericStyle(FxStyle(minWidth: value));

  /// Sets the max width of the widget.
  Widget maxW(double value) => _applyGenericStyle(FxStyle(maxWidth: value));

  /// Justify Shorthands
  Widget justifyStart() => justify(MainAxisAlignment.start);
  Widget justifyCenter() => justify(MainAxisAlignment.center);
  Widget justifyEnd() => justify(MainAxisAlignment.end);
  Widget justifyBetween() => justify(MainAxisAlignment.spaceBetween);
  Widget justifyAround() => justify(MainAxisAlignment.spaceAround);
  Widget justifyEvenly() => justify(MainAxisAlignment.spaceEvenly);

  /// Items Shorthands (Cross Axis)
  Widget itemsStart() => items(CrossAxisAlignment.start);
  Widget itemsCenter() => items(CrossAxisAlignment.center);
  Widget itemsEnd() => items(CrossAxisAlignment.end);
  Widget itemsStretch() => items(CrossAxisAlignment.stretch);
  Widget itemsBaseline() => items(CrossAxisAlignment.baseline);

  /// Direction Switching (Responsive Row/Col)
  Widget direction(Axis value) => _applyGenericStyle(FxStyle(direction: value));
  Widget asRow() => direction(Axis.horizontal);
  Widget asCol() => direction(Axis.vertical);

  /// Row alignment aliases
  Widget get alignCenter => justifyCenter();
  Widget get alignStart => justifyStart();
  Widget get alignEnd => justifyEnd();

  /// Grid Modifiers
  Widget gridCols(int value) =>
      _applyGenericStyle(FxStyle(crossAxisCount: value));
  Widget cols(int value) => gridCols(value);
  Widget colSpan(int value) =>
      _applyGenericStyle(FxStyle(flex: value)); // Generic span using flex

  // --- Advanced Modifiers ---

  Widget stagger([double interval = 0.05]) {
    final self = this;
    if (self is FlexBox) {
      return self.copyWith(
        children: Fx.stagger(self.children, interval: interval),
      );
    }
    return this;
  }

  Widget pack() =>
      _applyGenericStyle(const FxStyle(mainAxisSize: MainAxisSize.min));
  Widget stretch() =>
      _applyGenericStyle(const FxStyle(mainAxisSize: MainAxisSize.max));
  Widget expand({int flex = 1}) =>
      _applyGenericStyle(FxStyle(flex: flex, flexFit: FlexFit.tight));
  Widget flexible({int flex = 1}) =>
      _applyGenericStyle(FxStyle(flex: flex, flexFit: FlexFit.loose));

  Widget show(bool condition) => condition ? this : const SizedBox.shrink();
  Widget hide(bool condition) => condition ? const SizedBox.shrink() : this;
  Widget visibility(bool condition) => show(condition);

  /// Responsive visibility
  Widget hideXs() => responsive(xs: (w) => w.opacity(0));
  Widget hideSm() => responsive(sm: (w) => w.opacity(0));
  Widget hideMd() => responsive(md: (w) => w.opacity(0));
  Widget hideLg() => responsive(lg: (w) => w.opacity(0));
  Widget hideXl() => responsive(xl: (w) => w.opacity(0));

  Widget onPressed(FxStyle Function(FxStyle s) builder) {
    final s = builder(FxStyle.none);
    return _applyGenericStyle(FxStyle(pressed: s));
  }

  Widget onHover(FxStyle Function(FxStyle s) builder) {
    final s = builder(FxStyle.none);
    return _applyGenericStyle(FxStyle(hover: s));
  }

  Widget transition(Duration duration) =>
      _applyGenericStyle(FxStyle(transition: duration));

  Widget liftOnHover([double amount = 1.05]) => onHover((s) => s.scale(amount));
  Widget glowOnHover([Color? color]) => onHover(
    (s) => s.withShadows([
      BoxShadow(
        color: (color ?? Colors.blue).withValues(alpha: 0.3),
        blurRadius: 15,
        spreadRadius: 2,
      ),
    ]),
  );

  Widget align(AlignmentGeometry alignment) =>
      _applyGenericStyle(FxStyle(alignment: alignment));
  Widget center() => align(Alignment.center);

  // --- Buttonizers ---

  /// Wraps any widget in a raw button interaction layer.
  FxButton btn({VoidCallback? onTap}) => Fx.btn(child: this, onTap: onTap);

  /// Quick button variant wrappers
  FxButton primaryBtn({VoidCallback? onTap}) =>
      Fx.primaryButton('', onTap: onTap).copyWith(child: this);
  FxButton secondaryBtn({VoidCallback? onTap}) =>
      Fx.secondaryButton('', onTap: onTap).copyWith(child: this);
  FxButton dangerBtn({VoidCallback? onTap}) =>
      Fx.dangerButton('', onTap: onTap).copyWith(child: this);
  FxButton successBtn({VoidCallback? onTap}) =>
      Fx.successButton('', onTap: onTap).copyWith(child: this);
  FxButton outlineBtn({VoidCallback? onTap}) =>
      Fx.outlineButton('', onTap: onTap).copyWith(child: this);
  FxButton ghostBtn({VoidCallback? onTap}) =>
      Fx.ghostButton('', onTap: onTap).copyWith(child: this);
  Widget pointer() =>
      _applyGenericStyle(const FxStyle(cursor: SystemMouseCursors.click));

  Widget mouseCursor(MouseCursor cursor) => 
      _applyGenericStyle(FxStyle(cursor: cursor));

  
  Widget onDoubleTap(VoidCallback? action) => 
      FxLift.lift(this, (child) => GestureDetector(onDoubleTap: action, child: child));
      
  Widget onLongPress(VoidCallback? action) =>
      FxLift.lift(this, (child) => GestureDetector(onLongPress: action, child: child));

  // --- Haptic Modifiers ---

  /// Triggers a haptic feedback when the widget is tapped.
  Widget haptic() => onTap(FxHaptic.medium);

  /// Light haptic feedback.
  Widget hapticLight() => onTap(FxHaptic.light);

  /// Medium haptic feedback.
  Widget hapticMedium() => onTap(FxHaptic.medium);

  /// Heavy haptic feedback.
  Widget hapticHeavy() => onTap(FxHaptic.heavy);

  /// Error haptic feedback.
  Widget hapticError() => onTap(FxHaptic.error);

  /// A fused interaction modifier that applies a slight scale effect
  /// and haptic feedback when pressed.
  Widget pressScale({double amount = 0.97, bool haptic = true}) {
    Widget w = onPressed((s) => s.scale(amount)).transition(const Duration(milliseconds: 100));
    if (haptic) return w.hapticLight();
    return w;
  }

  // --- Interaction Safety ---

  /// A debounced tap that prevents "Double Tap Ghosting".
  /// Useful for navigation and API submission buttons.
  Widget onTapSafe(VoidCallback callback, {String? id}) {
    return onTap(() {
      FluxyInteractionGuard.debounce(id ?? callback.hashCode.toString(), callback);
    });
  }

  /// Triggers when the mouse enter the widget area.
  Widget onHoverEnter(VoidCallback? action) => 
      FxLift.lift(this, (child) => MouseRegion(onEnter: (_) => action?.call(), child: child));

  /// Triggers when the mouse leaves the widget area.
  Widget onHoverExit(VoidCallback? action) => 
      FxLift.lift(this, (child) => MouseRegion(onExit: (_) => action?.call(), child: child));

  /// Accessibility
  Widget tooltip(String message) => 
      FxLift.lift(this, (child) => Tooltip(message: message, child: child));

  /// Layout Helpers
  Widget scrollable({Axis direction = Axis.vertical}) => 
      FxLift.lift(this, (child) => SingleChildScrollView(scrollDirection: direction, child: child));

  Widget intrinsicH() => FxLift.lift(this, (child) => IntrinsicHeight(child: child));
  Widget intrinsicW() => FxLift.lift(this, (child) => IntrinsicWidth(child: child));

  /// Allows conditional chaining.
  /// Example: .then((w) => condition ? w.expand() : w)
  Widget then(Widget Function(Widget w) builder) => builder(this);

  Widget paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) => _applyGenericStyle(
    FxStyle(
      padding: EdgeInsets.only(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      ),
    ),
  );
  Widget marginOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) => _applyGenericStyle(
    FxStyle(
      margin: EdgeInsets.only(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      ),
    ),
  );

  Widget child(Widget childWidget) {
    final self = this;
    if (self is Box) return self.copyWith(child: childWidget);
    if (self is FlexBox) return self.copyWith(children: [childWidget]);
    if (self is GridBox) return self.copyWith(children: [childWidget]);
    if (self is StackBox) return self.copyWith(children: [childWidget]);
    return Box(child: childWidget);
  }

  /// Responsive styling modifier.
  Widget responsive({
    Widget Function(Widget w)? xs,
    Widget Function(Widget w)? sm,
    Widget Function(Widget w)? md,
    Widget Function(Widget w)? lg,
    Widget Function(Widget w)? xl,
  }) {
    return _applyResponsive(
      FxResponsiveStyle(
        xs: xs != null ? _extractStyle(xs(this)) : FxStyle.none,
        sm: sm != null ? _extractStyle(sm(this)) : null,
        md: md != null ? _extractStyle(md(this)) : null,
        lg: lg != null ? _extractStyle(lg(this)) : null,
        xl: xl != null ? _extractStyle(xl(this)) : null,
      ),
    );
  }

  FxStyle _extractStyle(Widget w) {
    if (w is FxWidget) return w.style;
    return FxStyle.none;
  }

  Widget children(List<Widget> value) {
    final self = this;
    if (self is Box) return self.copyWith(children: value);
    if (self is FlexBox) return self.copyWith(children: value);
    return Box(children: value);
  }

  Widget onTap(VoidCallback callback) {
    final self = this;
    if (self is FxWidget) {
      // If it's a Box, FlexBox, etc., it might have a native onTap field
      // We should use structural recursion to find the right way to apply it.
      // For FxWidget, we can use copyWithStyle if it's purely about interactive states,
      // but many Fluxy widgets have a dedicated onTap constructor param.
      
      // Let's check for specific types that support onTap natively
      if (self is Box) return self.copyWith(onTap: callback);
      if (self is FlexBox) return self.copyWith(onTap: callback);
      if (self is GridBox) return self.copyWith(onTap: callback);
      if (self is StackBox) return self.copyWith(onTap: callback);
      if (self is ListBox) return self.copyWith(onTap: callback);
      if (self is FxButton) return self.copyWith(onTap: callback);
      if (self is FxAvatar) return self.copyWith(onTap: callback);
      if (self is FxTable) return self.copyWith(onRowTap: callback);
    }
    
    return GestureDetector(onTap: callback, child: self);
  }
}

// --- Proxy Classes ---

class FxBgProxy {
  final Widget _widget;
  FxBgProxy(this._widget);

  Widget call(Color value) => _widget.background(value);

  Widget get white => _widget.background(const Color(0xFFFFFFFF));
  Widget get black => _widget.background(const Color(0xFF000000));
  Widget get transparent => _widget.background(const Color(0x00000000));
  Widget get slate50 => _widget.background(FxTokens.colors.slate50);
  Widget get slate100 => _widget.background(FxTokens.colors.slate100);
  Widget get slate800 => _widget.background(FxTokens.colors.slate800);
  Widget get blue500 => _widget.background(FxTokens.colors.blue500);

  Widget get primary => _widget.background(FxTokens.colors.primary);
  Widget get secondary => _widget.background(FxTokens.colors.secondary);
  Widget get success => _widget.background(FxTokens.colors.success);
  Widget get error => _widget.background(FxTokens.colors.error);
  Widget get surface => _widget.background(FxTokens.colors.surface);

  Widget color(Color value) => _widget.background(value);
}

class FxWidthProxy {
  final Widget _widget;
  FxWidthProxy(this._widget);

  Widget call(double value) => _widget.w(value);
  Widget get full => _widget.fullWidth();
}

class FxHeightProxy {
  final Widget _widget;
  FxHeightProxy(this._widget);

  Widget call(double value) => _widget.h(value);
  Widget get full => _widget.fullHeight();
}

class FxWeightProxy {
  final Widget _widget;
  FxWeightProxy(this._widget);

  Widget call(FontWeight value) => _widget.fontWeight(value);
  Widget get bold => _widget.fontWeight(FontWeight.bold);
  Widget get semiBold => _widget.fontWeight(FontWeight.w600);
  Widget get medium => _widget.fontWeight(FontWeight.w500);
  Widget get normal => _widget.fontWeight(FontWeight.normal);
  Widget get light => _widget.fontWeight(FontWeight.w300);
}

class FxShadowProxy {
  final Widget _widget;
  FxShadowProxy(this._widget);

  Widget call({
    Color color = const Color(0x1F000000),
    double blur = 4,
    Offset offset = const Offset(0, 2),
  }) => _widget._applyShadow(color: color, blur: blur, offset: offset);

  Widget get sm => _widget.shadowSmall();
  Widget get md => _widget.shadowMedium();
  Widget get lg => _widget.shadowLarge();
  Widget get none => _widget.shadow(color: Colors.transparent, blur: 0);
}

class FxFontProxy {
  final Widget _widget;
  FxFontProxy(this._widget);

  // Sizes
  Widget xs() => _widget.textXs();
  Widget sm() => _widget.textSm();
  Widget md() => _widget.textBase();
  Widget lg() => _widget.textLg();
  Widget xl() => _widget.textXl();
  Widget xl2() => _widget.fontSize(FxTokens.font.xxl);
  Widget xl3() => _widget.fontSize(FxTokens.font.xxxl);
  Widget xl4() => _widget.fontSize(FxTokens.font.x4l);
  Widget xl5() => _widget.fontSize(FxTokens.font.x5l);
  Widget xl6() => _widget.fontSize(FxTokens.font.x6l);
  
  // Legacy/Aliases
  Widget xxl() => xl2();
  Widget xxxl() => xl3();

  // Semantic
  Widget h1() => _widget.h1();
  Widget h2() => _widget.h2();
  Widget h3() => _widget.h3();
  Widget h4() => _widget.fontSize(FxTokens.font.lg).bold();
  Widget body() => _widget.body();
  Widget caption() => _widget.caption();
  Widget muted() => _widget.muted();

  // Colors
  Widget primary() => _widget.primary();
  Widget secondary() => _widget.secondary();
  Widget error() => _widget.error();
  Widget success() => _widget.success();

  // Weights
  Widget bold() => _widget.bold();
  Widget semiBold() => _widget.semiBold();
  Widget medium() => _widget.medium();
  Widget normal() => _widget.fontWeight(FontWeight.normal);
  Widget light() => _widget.light();
}

/// Extensions on FxStyle to allow fluent composition in callbacks.
extension FluxyStyleFluentExtension on FxStyle {
  FxStyle pad(double value) => copyWith(padding: EdgeInsets.all(value));
  FxStyle padX(double value) =>
      copyWith(padding: EdgeInsets.symmetric(horizontal: value));
  FxStyle padY(double value) =>
      copyWith(padding: EdgeInsets.symmetric(vertical: value));

  FxStyle marg(double value) => copyWith(margin: EdgeInsets.all(value));
  FxStyle margX(double value) =>
      copyWith(margin: EdgeInsets.symmetric(horizontal: value));
  FxStyle margY(double value) =>
      copyWith(margin: EdgeInsets.symmetric(vertical: value));

  FxStyle radius(double value) =>
      copyWith(borderRadius: BorderRadius.circular(value));

  FxStyle bg(Color color) => copyWith(backgroundColor: color);
  FxStyle textColor(Color color) => copyWith(color: color);

  FxStyle size(double value) => copyWith(fontSize: value);
  FxStyle weight(FontWeight weight) => copyWith(fontWeight: weight);

  FxStyle w(double value) => copyWith(width: value);
  FxStyle h(double value) => copyWith(height: value);
  FxStyle wFull() => copyWith(width: double.infinity);
  FxStyle hFull() => copyWith(height: double.infinity);
  FxStyle op(double value) => copyWith(opacity: value);

  // Flex Fluent
  FxStyle justify(MainAxisAlignment val) => copyWith(justifyContent: val);
  FxStyle items(CrossAxisAlignment val) => copyWith(alignItems: val);
  FxStyle spacing(double val) => copyWith(gap: val);
  FxStyle direction(Axis val) => copyWith(direction: val);
  FxStyle gridCols(int val) => copyWith(crossAxisCount: val);

  FxStyle scale(double val) => copyWith(transformScale: val);
  FxStyle rotate(double val) => copyWith(transformRotation: val);
  FxStyle withShadows(List<BoxShadow> val) => copyWith(shadows: val);
  FxStyle border({Color? color, double width = 1}) => copyWith(
    border: Border.all(color: color ?? const Color(0x00000000), width: width),
  );

  // Advanced Visuals
  FxStyle glass([double blur = 10]) => copyWith(glass: blur);
  FxStyle blur(double val) => copyWith(imageBlur: val);
  FxStyle grayscale([bool val = true]) => copyWith(grayscale: val);
  FxStyle transition(Duration val) => copyWith(transition: val);
  FxStyle cursor(MouseCursor val) => copyWith(cursor: val);
  FxStyle aspectRatio(double val) => copyWith(aspectRatio: val);

  // Typography
  FxStyle bold() => copyWith(fontWeight: FontWeight.bold);
  FxStyle italic() => copyWith(fontStyle: FontStyle.italic);
  FxStyle align(AlignmentGeometry val) => copyWith(alignment: val);
  FxStyle textAlign(TextAlign val) => copyWith(textAlign: val);
  FxStyle maxLines(int val) => copyWith(maxLines: val);
  FxStyle overflow(TextOverflow val) => copyWith(overflow: val);
}

/// Helper for context extensions
extension FluxyContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colors => Theme.of(this).colorScheme;
  Size get screenSize => MediaQuery.sizeOf(this);
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Navigates to a new page.
  Future<T?> to<T>(String route, {Map<String, dynamic>? arguments}) =>
      FluxyRouter.to<T>(route, arguments: arguments);

  /// Replaces current page.
  Future<T?> off<T, TO>(
    String route, {
    TO? result,
    Map<String, dynamic>? arguments,
  }) => FluxyRouter.off<T, TO>(route, result: result, arguments: arguments);

  /// Clears stack and navigates.
  Future<T?> offAll<T>(String route, {Map<String, dynamic>? arguments}) =>
      FluxyRouter.offAll<T>(route, arguments: arguments);

  /// Goes back.
  void back<T>([T? result]) => FluxyRouter.back<T>(result);

  /// Finds a dependency.
  T find<T>({String? tag}) => FluxyDI.find<T>(tag: tag);
}
