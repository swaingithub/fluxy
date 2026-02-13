
import 'package:flutter/widgets.dart';
import '../styles/style.dart';
import '../styles/tokens.dart';
import '../widgets/box.dart';
import '../widgets/text_box.dart';
import '../widgets/flex_box.dart';
import '../widgets/grid_box.dart';
import '../widgets/stack_box.dart';
import '../widgets/button.dart';

/// Extension to provide a fluent DSL experience for any Widget.
extension FluxyWidgetExtension on Widget {
  
  /// Internal helper to apply style to any supported widget or wrap in Box.
  Widget _applyGenericStyle(FxStyle style) {
    final self = this;
    if (self is Box) return self.copyWith(style: self.style.merge(style));
    if (self is TextBox) return self.copyWith(style: self.style.merge(style));
    if (self is FlexBox) return self.copyWith(style: self.style.merge(style));
    if (self is GridBox) return self.copyWith(style: self.style.merge(style));
    if (self is StackBox) return self.copyWith(style: self.style.merge(style));
    if (self is FxButton) return self.copyWith(style: self.style.merge(style));
    
    // Wrap generic widget
    return Box(
      style: style,
      child: self,
    );
  }

  /// Internal helper to apply responsive style.
  Widget _applyResponsive(FxResponsiveStyle responsive) {
    final self = this;
    if (self is Box) return self.copyWith(responsive: self.responsive?.merge(responsive) ?? responsive);
    if (self is TextBox) return self.copyWith(responsive: self.responsive?.merge(responsive) ?? responsive);
    if (self is FlexBox) return self.copyWith(responsive: self.responsive?.merge(responsive) ?? responsive);
    if (self is GridBox) return self.copyWith(responsive: self.responsive?.merge(responsive) ?? responsive);
    if (self is StackBox) return self.copyWith(responsive: self.responsive?.merge(responsive) ?? responsive);
    
    // Wrap generic widget
    return Box(
      responsive: responsive,
      child: self,
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

  Widget padding(double value) => _applyGenericStyle(FxStyle(padding: EdgeInsets.all(value)));
  Widget paddingX(double value) => _applyGenericStyle(FxStyle(padding: EdgeInsets.symmetric(horizontal: value)));
  Widget paddingY(double value) => _applyGenericStyle(FxStyle(padding: EdgeInsets.symmetric(vertical: value)));
  
  /// Aliases
  Widget p(double v) => padding(v);
  Widget px(double v) => paddingX(v);
  Widget py(double v) => paddingY(v);
  Widget pad(double v) => padding(v);

  Widget margin(double value) => _applyGenericStyle(FxStyle(margin: EdgeInsets.all(value)));
  Widget marginX(double value) => _applyGenericStyle(FxStyle(margin: EdgeInsets.symmetric(horizontal: value)));
  Widget marginY(double value) => _applyGenericStyle(FxStyle(margin: EdgeInsets.symmetric(vertical: value)));

  /// Aliases
  Widget m(double v) => margin(v);
  Widget mx(double v) => marginX(v);
  Widget my(double v) => marginY(v);
  Widget mb(double value) => _applyGenericStyle(FxStyle(margin: EdgeInsets.only(bottom: value)));
  Widget mt(double value) => _applyGenericStyle(FxStyle(margin: EdgeInsets.only(top: value)));
  Widget ml(double value) => _applyGenericStyle(FxStyle(margin: EdgeInsets.only(left: value)));
  Widget mr(double value) => _applyGenericStyle(FxStyle(margin: EdgeInsets.only(right: value)));

  Widget radius(double value) => _applyGenericStyle(FxStyle(borderRadius: BorderRadius.circular(value)));
  Widget rounded(double value) => radius(value);
  Widget borderRadius(double value) => radius(value);
  Widget roundedFull() => radius(999);

  // --- Dimension Modifiers ---

  Widget w(double value) => _applyGenericStyle(FxStyle(width: value));
  Widget h(double value) => _applyGenericStyle(FxStyle(height: value));
  Widget fullWidth() => _applyGenericStyle(const FxStyle(width: double.infinity));
  Widget fullHeight() => _applyGenericStyle(const FxStyle(height: double.infinity));
  Widget wFull() => fullWidth();
  Widget hFull() => fullHeight();
  
  Widget size(double w, [double? h]) {
    if (h == null) {
      if (this is TextBox) return _applyGenericStyle(FxStyle(fontSize: w));
      return _applyGenericStyle(FxStyle(width: w, height: w));
    }
    return _applyGenericStyle(FxStyle(width: w, height: h));
  }

  // --- Styling Modifiers ---

  Widget background(Color color) => _applyGenericStyle(FxStyle(backgroundColor: color));
  Widget backgroundWhite() => background(const Color(0xFFFFFFFF));
  Widget backgroundBlack() => background(const Color(0xFF000000));
  
  Widget shadow({Color color = const Color(0x1F000000), double blur = 4, Offset offset = const Offset(0, 2)}) => 
      _applyGenericStyle(FxStyle(shadows: [BoxShadow(color: color, blurRadius: blur, offset: offset)]));

  Widget shadowSmall() => _applyGenericStyle(FxStyle(shadows: FxTokens.shadow.sm));
  Widget shadowMedium() => _applyGenericStyle(FxStyle(shadows: FxTokens.shadow.md));
  Widget shadowLarge() => _applyGenericStyle(FxStyle(shadows: FxTokens.shadow.lg));

  // --- Typography ---

  Widget fontSize(double size) => _applyGenericStyle(FxStyle(fontSize: size));
  Widget fontWeight(FontWeight weight) => _applyGenericStyle(FxStyle(fontWeight: weight));
  Widget color(Color value) => _applyGenericStyle(FxStyle(color: value));
  Widget textAlign(TextAlign align) => _applyGenericStyle(FxStyle(textAlign: align));
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

  // --- Advanced Modifiers ---
  
  Widget pack() => _applyGenericStyle(const FxStyle(mainAxisSize: MainAxisSize.min));
  Widget stretch() => _applyGenericStyle(const FxStyle(mainAxisSize: MainAxisSize.max));
  Widget expand({int flex = 1}) => _applyGenericStyle(FxStyle(flex: flex, flexFit: FlexFit.tight));
  Widget flexible({int flex = 1}) => _applyGenericStyle(FxStyle(flex: flex, flexFit: FlexFit.loose));

  Widget show(bool condition) => condition ? this : const SizedBox.shrink();
  Widget hide(bool condition) => condition ? const SizedBox.shrink() : this;
  
  Widget onPressed(FxStyle Function(FxStyle s) builder) {
    final s = builder(FxStyle.none);
    return _applyGenericStyle(FxStyle(pressed: s));
  }
  
  Widget onHover(FxStyle Function(FxStyle s) builder) {
    final s = builder(FxStyle.none);
    return _applyGenericStyle(FxStyle(hover: s));
  }

  Widget align(AlignmentGeometry alignment) => _applyGenericStyle(FxStyle(alignment: alignment));
  Widget center() => align(Alignment.center);
  Widget pointer() => _applyGenericStyle(const FxStyle(cursor: SystemMouseCursors.click));

  Widget paddingOnly({double left = 0, double top = 0, double right = 0, double bottom = 0}) => 
      _applyGenericStyle(FxStyle(padding: EdgeInsets.only(left: left, top: top, right: right, bottom: bottom)));
  Widget marginOnly({double left = 0, double top = 0, double right = 0, double bottom = 0}) => 
      _applyGenericStyle(FxStyle(margin: EdgeInsets.only(left: left, top: top, right: right, bottom: bottom)));

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
    Widget Function(Widget w)? sm,
    Widget Function(Widget w)? md,
    Widget Function(Widget w)? lg,
    Widget Function(Widget w)? xl,
  }) {
    return _applyResponsive(FxResponsiveStyle(
      xs: FxStyle.none,
      sm: sm != null ? _extractStyle(sm(this)) : null,
      md: md != null ? _extractStyle(md(this)) : null,
      lg: lg != null ? _extractStyle(lg(this)) : null,
      xl: xl != null ? _extractStyle(xl(this)) : null,
    ));
  }

  FxStyle _extractStyle(Widget w) {
    if (w is Box) return w.style;
    if (w is TextBox) return w.style;
    if (w is FlexBox) return w.style;
    if (w is GridBox) return w.style;
    if (w is StackBox) return w.style;
    if (w is FxButton) return w.style;
    return FxStyle.none;
  }

  Widget onTap(VoidCallback callback) {
    final self = this;
    if (self is Box) return self.copyWith(onTap: callback);
    if (self is FlexBox) return self.copyWith(onTap: callback);
    if (self is GridBox) return self.copyWith(onTap: callback);
    if (self is StackBox) return self.copyWith(onTap: callback);
    if (self is FxButton) return self.copyWith(onTap: callback);
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

/// Extensions on FxStyle to allow fluent composition in callbacks.
extension FluxyStyleFluentExtension on FxStyle {
  FxStyle padding(double value) => copyWith(padding: EdgeInsets.all(value));
  FxStyle paddingX(double value) => copyWith(padding: EdgeInsets.symmetric(horizontal: value));
  FxStyle paddingY(double value) => copyWith(padding: EdgeInsets.symmetric(vertical: value));
  
  FxStyle margin(double value) => copyWith(margin: EdgeInsets.all(value));
  FxStyle marginX(double value) => copyWith(margin: EdgeInsets.symmetric(horizontal: value));
  FxStyle marginY(double value) => copyWith(margin: EdgeInsets.symmetric(vertical: value));

  FxStyle radius(double value) => copyWith(borderRadius: BorderRadius.circular(value));
  
  FxStyle bg(Color color) => copyWith(backgroundColor: color);
  FxStyle color(Color color) => copyWith(color: color);
  
  FxStyle size(double value) => copyWith(fontSize: value);
  FxStyle weight(FontWeight weight) => copyWith(fontWeight: weight);
  
  FxStyle width(double value) => copyWith(width: value);
  FxStyle height(double value) => copyWith(height: value);
  FxStyle wFull() => copyWith(width: double.infinity);
  FxStyle hFull() => copyWith(height: double.infinity);
  FxStyle op(double value) => copyWith(opacity: value);
}
