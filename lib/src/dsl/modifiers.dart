
import 'package:flutter/widgets.dart';
import '../styles/style.dart';
import '../styles/tokens.dart';
import '../widgets/box.dart';
import '../widgets/text_box.dart';
import '../widgets/flex_box.dart';
import '../widgets/grid_box.dart';
import '../widgets/stack_box.dart';

/// Extension to provide a fluent DSL experience for any Widget.
extension FluxyWidgetExtension on Widget {
  
  /// Internal helper to apply style to any supported widget or wrap in Box.
  Widget _applyGenericStyle(FxStyle style) {
    if (this is Box) return (this as Box).copyWith(style: (this as Box).style.merge(style));
    if (this is TextBox) return (this as TextBox).copyWith(style: (this as TextBox).style.merge(style));
    if (this is FlexBox) return (this as FlexBox).copyWith(style: (this as FlexBox).style.merge(style));
    if (this is GridBox) return (this as GridBox).copyWith(style: (this as GridBox).style.merge(style));
    if (this is StackBox) return (this as StackBox).copyWith(style: (this as StackBox).style.merge(style));
    
    // Wrap generic widget
    return Box(
      style: style,
      child: this,
    );
  }

  /// Internal helper to apply responsive style.
  Widget _applyResponsive(FxResponsiveStyle responsive) {
    if (this is Box) return (this as Box).copyWith(responsive: responsive);
    if (this is TextBox) return (this as TextBox).copyWith(responsive: responsive);
    if (this is FlexBox) return (this as FlexBox).copyWith(responsive: responsive);
    if (this is GridBox) return (this as GridBox).copyWith(responsive: responsive);
    if (this is StackBox) return (this as StackBox).copyWith(responsive: responsive);
    
    // Wrap generic widget
    return Box(
      responsive: responsive,
      child: this,
    );
  }

  // --- Utility Modifiers ---

  /// Conditionally show/hide the widget.
  /// Usage: .show(someBoolean) or .hide(someBoolean)
  Widget show(bool condition) => condition ? this : const SizedBox.shrink();
  
  /// Conditionally hide the widget.
  Widget hide(bool condition) => condition ? const SizedBox.shrink() : this;

  /// Implicitly animates changes to the widget's style.
  /// Usage: .animate(duration: 300.ms, curve: Curves.easeOut)
  Widget animate({Duration duration = const Duration(milliseconds: 300), Curve curve = Curves.easeInOut}) => 
      _applyGenericStyle(FxStyle(transition: duration)); // Box checks transition property

  // --- Interaction Modifiers ---

  /// Applies styles on hover state.
  /// Usage: .onHover((s) => s.scale(1.05).shadowMd())
  Widget onHover(FxStyle Function(FxStyle s) builder) {
    final s = builder(FxStyle.none);
    return _applyGenericStyle(FxStyle(hover: s));
  }

  /// Applies styles on pressed state.
  Widget onPressed(FxStyle Function(FxStyle s) builder) {
    final s = builder(FxStyle.none);
    return _applyGenericStyle(FxStyle(pressed: s));
  }

  // --- Spacing Modifiers (Phase 2 & 3) ---

  /// Applies padding to all sides.
  /// Usage: .padding(16) or .padding(FxTokens.space.md)
  Widget padding(double value) => _applyGenericStyle(FxStyle(padding: EdgeInsets.all(value)));
  
  /// Applies horizontal padding.
  Widget paddingX(double value) => _applyGenericStyle(FxStyle(padding: EdgeInsets.symmetric(horizontal: value)));
  
  /// Applies vertical padding.
  Widget paddingY(double value) => _applyGenericStyle(FxStyle(padding: EdgeInsets.symmetric(vertical: value)));
  
  Widget paddingTop(double value) => _applyGenericStyle(FxStyle(padding: EdgeInsets.only(top: value)));
  Widget paddingBottom(double value) => _applyGenericStyle(FxStyle(padding: EdgeInsets.only(bottom: value)));
  Widget paddingLeft(double value) => _applyGenericStyle(FxStyle(padding: EdgeInsets.only(left: value)));
  Widget paddingRight(double value) => _applyGenericStyle(FxStyle(padding: EdgeInsets.only(right: value)));
  Widget paddingOnly({double left = 0, double top = 0, double right = 0, double bottom = 0}) => 
      _applyGenericStyle(FxStyle(padding: EdgeInsets.only(left: left, top: top, right: right, bottom: bottom)));
  
  // -- Aliases for Padding --
  Widget pad(double value) => padding(value);
  Widget p(double value) => padding(value);
  Widget px(double value) => paddingX(value);
  Widget py(double value) => paddingY(value);
  Widget pt(double value) => paddingTop(value);
  Widget pb(double value) => paddingBottom(value);
  Widget pl(double value) => paddingLeft(value);
  Widget pr(double value) => paddingRight(value);

  /// Applies margin to all sides.
  Widget margin(double value) => _applyGenericStyle(FxStyle(margin: EdgeInsets.all(value)));
  
  Widget marginX(double value) => _applyGenericStyle(FxStyle(margin: EdgeInsets.symmetric(horizontal: value)));
  Widget marginY(double value) => _applyGenericStyle(FxStyle(margin: EdgeInsets.symmetric(vertical: value)));
  
  Widget marginTop(double value) => _applyGenericStyle(FxStyle(margin: EdgeInsets.only(top: value)));
  Widget marginBottom(double value) => _applyGenericStyle(FxStyle(margin: EdgeInsets.only(bottom: value)));
  Widget marginLeft(double value) => _applyGenericStyle(FxStyle(margin: EdgeInsets.only(left: value)));
  Widget marginRight(double value) => _applyGenericStyle(FxStyle(margin: EdgeInsets.only(right: value)));

  // -- Aliases for Margin --
  Widget m(double value) => margin(value);
  Widget mx(double value) => marginX(value);
  Widget my(double value) => marginY(value);
  Widget mt(double value) => marginTop(value);
  Widget mb(double value) => marginBottom(value);
  Widget ml(double value) => marginLeft(value);
  Widget mr(double value) => marginRight(value);

  /// Applies gap (for Flex/Grid layouts).
  Widget gap(double value) => _applyGenericStyle(FxStyle(gap: value));

  // --- Dimension Modifiers ---
  
  Widget width(double value) => _applyGenericStyle(FxStyle(width: value));
  Widget height(double value) => _applyGenericStyle(FxStyle(height: value));
  Widget size(double w, double h) => _applyGenericStyle(FxStyle(width: w, height: h));
  Widget square(double value) => _applyGenericStyle(FxStyle(width: value, height: value));
  
  // -- Aliases for Dimensions --
  Widget w(double value) => width(value);
  Widget h(double value) => height(value);
  Widget wFull() => fullWidth();
  Widget hFull() => fullHeight();
  
  /// Expands width to max available.
  Widget fullWidth() => _applyGenericStyle(const FxStyle(width: double.infinity));
  
  /// Expands height to max available.
  Widget fullHeight() => _applyGenericStyle(const FxStyle(height: double.infinity));

  // --- Content Modifiers ---

  /// Adds a child to the widget (if supported, e.g. Box).
  Widget child(Widget child) {
    if (this is Box) return (this as Box).copyWith(child: child);
    if (this is StackBox) return (this as StackBox).copyWith(children: [...(this as StackBox).children, child]);
    // Potentially support others or warn
    return this;
  }

  
  /// Expands to fill available space in flex container.
  Widget expand({int flex = 1}) => _applyGenericStyle(FxStyle(flex: flex, flexFit: FlexFit.tight));

  // --- Styling Modifiers ---

  /// Sets the background color.
  /// Usage: .background(Colors.red)
  Widget background(Color color) => _applyGenericStyle(FxStyle(backgroundColor: color));
  
  /// Shortcut for white background.
  Widget backgroundWhite() => background(const Color(0xFFFFFFFF));
  
  /// Shortcut for black background.
  Widget backgroundBlack() => background(const Color(0xFF000000));

  // -- Aliases for Background --
  Widget bg(Color color) => background(color);

  /// Helper for linear gradient.
  /// Usage: .linearGradient([Colors.red, Colors.blue])
  Widget linearGradient(List<Color> colors, {Alignment begin = Alignment.topLeft, Alignment end = Alignment.bottomRight}) =>
      _applyGenericStyle(FxStyle(gradient: LinearGradient(colors: colors, begin: begin, end: end)));

  Widget radialGradient(List<Color> colors) => 
      _applyGenericStyle(FxStyle(gradient: RadialGradient(colors: colors)));

  /// Sets border radius.
  Widget borderRadius(double value) => _applyGenericStyle(FxStyle(borderRadius: BorderRadius.circular(value)));
  
  /// Semantic radius shortcuts (Phase 3).
  Widget radiusSmall() => borderRadius(FxTokens.radius.sm);
  Widget radiusMedium() => borderRadius(FxTokens.radius.md);
  Widget radiusLarge() => borderRadius(FxTokens.radius.lg);
  Widget radiusXLarge() => borderRadius(FxTokens.radius.xl);
  Widget radiusFull() => borderRadius(FxTokens.radius.full);

  // -- Aliases for Border Radius --
  Widget radius(double value) => borderRadius(value);
  Widget rounded(double value) => borderRadius(value);
  Widget roundedFull() => radiusFull();

  /// Sets border.
  Widget border({Color color = const Color(0xFF000000), double width = 1}) => 
      _applyGenericStyle(FxStyle(border: Border.all(color: color, width: width)));
  
  /// Sets shadow.
  Widget shadow({Color color = const Color(0x1F000000), double blur = 4, Offset offset = const Offset(0, 2)}) => 
      _applyGenericStyle(FxStyle(shadows: [BoxShadow(color: color, blurRadius: blur, offset: offset)]));
  
  /// Semantic shadow shortcuts (Phase 3).
  Widget shadowSmall() => _applyGenericStyle(FxStyle(shadows: FxTokens.shadow.sm));
  Widget shadowMedium() => _applyGenericStyle(FxStyle(shadows: FxTokens.shadow.md));
  Widget shadowLarge() => _applyGenericStyle(FxStyle(shadows: FxTokens.shadow.lg));
  Widget shadowXL() => _applyGenericStyle(FxStyle(shadows: FxTokens.shadow.xl));

  /// Opacity
  Widget opacity(double value) => _applyGenericStyle(FxStyle(opacity: value));

  // --- Text Modifiers ---
  
  Widget textColor(Color color) => _applyGenericStyle(FxStyle(color: color));
  /// Alias for textColor
  Widget color(Color color) => textColor(color);

  Widget fontSize(double size) => _applyGenericStyle(FxStyle(fontSize: size));
  Widget fontWeight(FontWeight weight) => _applyGenericStyle(FxStyle(fontWeight: weight));
  Widget fontFamily(String font) => _applyGenericStyle(FxStyle(fontFamily: font));
  Widget textAlign(TextAlign align) => _applyGenericStyle(FxStyle(textAlign: align));
  Widget textCenter() => textAlign(TextAlign.center);

  // -- Aliases for Typography --
  Widget font(double size) => fontSize(size);
  Widget fs(double size) => fontSize(size);
  Widget fw(FontWeight w) => fontWeight(w);
  Widget tc(Color c) => textColor(c);

  // Semantic Font Sizes
  Widget textXs() => fontSize(FxTokens.font.xs);
  Widget textSm() => fontSize(FxTokens.font.sm);
  Widget textBase() => fontSize(FxTokens.font.md);
  Widget textLg() => fontSize(FxTokens.font.lg);
  Widget textXl() => fontSize(FxTokens.font.xl);
  Widget text2Xl() => fontSize(FxTokens.font.xxl);
  Widget text3Xl() => fontSize(FxTokens.font.xxxl);

  Widget bold() => fontWeight(FontWeight.bold);
  Widget semiBold() => fontWeight(FontWeight.w600);
  Widget fontLight() => fontWeight(FontWeight.w300);
  /// Alias for fontWeight
  Widget weight(FontWeight w) => fontWeight(w);

  // --- Alignment ---
  
  Widget align(AlignmentGeometry alignment) => _applyGenericStyle(FxStyle(alignment: alignment));
  Widget center() => align(Alignment.center);
  Widget alignTopLeft() => align(Alignment.topLeft);
  Widget alignTopRight() => align(Alignment.topRight);
  Widget alignBottomLeft() => align(Alignment.bottomLeft);
  Widget alignBottomRight() => align(Alignment.bottomRight);

  // --- Layout Behavior Modifiers ---
  
  /// Sets MainAxisSize to min (shrinks to fit children).
  Widget pack() => _applyGenericStyle(const FxStyle(mainAxisSize: MainAxisSize.min));
  
  /// Sets MainAxisSize to max (expands to fill space).
  Widget stretch() => _applyGenericStyle(const FxStyle(mainAxisSize: MainAxisSize.max));

  // --- Start Interaction Modifiers ---
  Widget pointer() => _applyGenericStyle(const FxStyle(cursor: SystemMouseCursors.click));
  
  /// Tap gesture handler.
  Widget onTap(VoidCallback callback) {
    if (this is Box) return (this as Box).copyWith(onTap: callback);
    if (this is FlexBox) return (this as FlexBox).copyWith(onTap: callback);
    if (this is GridBox) return (this as GridBox).copyWith(onTap: callback);
    if (this is StackBox) return (this as StackBox).copyWith(onTap: callback);
    return GestureDetector(onTap: callback, child: this);
  }

  // --- Responsive Breakpoints (Phase 4) ---

  /// Applies styles only on XS screens and up.
  Widget onXs(FxStyle Function(FxStyle s) builder) {
    final s = builder(FxStyle.none);
    return _applyResponsive(FxResponsiveStyle(xs: s));
  }

  /// Applies styles only on SM screens and up (Tablet Portrait).
  Widget onSm(FxStyle Function(FxStyle s) builder) {
    final s = builder(FxStyle.none);
    return _applyResponsive(FxResponsiveStyle(xs: FxStyle.none, sm: s)); // Base is none, override at sm
  }

  /// Applies styles only on MD screens and up (Tablet Landscape / Small Laptop).
  Widget onMd(FxStyle Function(FxStyle s) builder) {
    final s = builder(FxStyle.none);
    return _applyResponsive(FxResponsiveStyle(xs: FxStyle.none, md: s));
  }

  /// Applies styles only on LG screens and up (Desktop).
  Widget onLg(FxStyle Function(FxStyle s) builder) {
    final s = builder(FxStyle.none);
    return _applyResponsive(FxResponsiveStyle(xs: FxStyle.none, lg: s));
  }

  /// Applies styles only on XL screens and up (Large Desktop).
  Widget onXl(FxStyle Function(FxStyle s) builder) {
    final s = builder(FxStyle.none);
    return _applyResponsive(FxResponsiveStyle(xs: FxStyle.none, xl: s));
  }

  // --- Deprecated / Legacy Support (Phase 8 - partial) ---
  // To keep "Pad(12)" working for now if strictly required, but Prompt says "Replace".
  // I will optionally add them if I want max compat, but User asked primarily for New Syntax.
  // I'll stick to the clean API for optimal "Expo" feel as requested.
  
  // Actually, to chain builders inside the responsive callback .onMd((s) => s.padding(10)),
  // FxStyle itself needs methods... OR we use a builder helper.
  // The current FxStyle is immutable data. modifying it is tricky via chaining unless we wrap it.
  // 
  // Wait, `builder(FxStyle.none)`:
  // If I do `s.padding(10)`, `s` is FxStyle. FxStyle doesn't have methods "padding". 
  // I need a StyleBuilder class or extension on FxStyle to support this syntax `s.padding(10)`.
  //
  // Let's add an extension on FxStyle to support fluent building returning FxStyle!
}

/// Extensions on FxStyle to allow fluent composition in callbacks.
/// e.g. (s) => s.padding(12).background(Colors.red)
extension FluxyStyleFluentExtension on FxStyle {
  FxStyle padding(double value) => copyWith(padding: EdgeInsets.all(value));
  FxStyle paddingX(double value) => copyWith(padding: EdgeInsets.symmetric(horizontal: value));
  FxStyle paddingY(double value) => copyWith(padding: EdgeInsets.symmetric(vertical: value));
  FxStyle paddingTop(double value) => copyWith(padding: EdgeInsets.only(top: value));
  FxStyle paddingBottom(double value) => copyWith(padding: EdgeInsets.only(bottom: value));
  FxStyle paddingLeft(double value) => copyWith(padding: EdgeInsets.only(left: value));
  FxStyle paddingRight(double value) => copyWith(padding: EdgeInsets.only(right: value));

  // -- Aliases for Padding --
  FxStyle pad(double value) => padding(value);
  FxStyle p(double value) => padding(value);
  FxStyle px(double value) => paddingX(value);
  FxStyle py(double value) => paddingY(value);
  FxStyle pt(double value) => paddingTop(value);
  FxStyle pb(double value) => paddingBottom(value);
  FxStyle pl(double value) => paddingLeft(value);
  FxStyle pr(double value) => paddingRight(value);

  FxStyle margin(double value) => copyWith(margin: EdgeInsets.all(value));
  FxStyle marginX(double value) => copyWith(margin: EdgeInsets.symmetric(horizontal: value));
  FxStyle marginY(double value) => copyWith(margin: EdgeInsets.symmetric(vertical: value));
  FxStyle marginTop(double value) => copyWith(margin: EdgeInsets.only(top: value));
  FxStyle marginBottom(double value) => copyWith(margin: EdgeInsets.only(bottom: value));
  FxStyle marginLeft(double value) => copyWith(margin: EdgeInsets.only(left: value));
  FxStyle marginRight(double value) => copyWith(margin: EdgeInsets.only(right: value));

  // -- Aliases for Margin --
  FxStyle m(double value) => margin(value);
  FxStyle mx(double value) => marginX(value);
  FxStyle my(double value) => marginY(value);
  FxStyle mt(double value) => marginTop(value);
  FxStyle mb(double value) => marginBottom(value);
  FxStyle ml(double value) => marginLeft(value);
  FxStyle mr(double value) => marginRight(value);

  FxStyle setWidth(double value) => copyWith(width: value);
  FxStyle setHeight(double value) => copyWith(height: value);
  FxStyle widthFull() => copyWith(width: double.infinity);
  FxStyle heightFull() => copyWith(height: double.infinity);
  FxStyle size(double w, double h) => copyWith(width: w, height: h);
  FxStyle square(double value) => copyWith(width: value, height: value);
  
  // -- Aliases for Dimensions --
  FxStyle w(double value) => setWidth(value);
  FxStyle h(double value) => setHeight(value);
  FxStyle wFull() => widthFull();
  FxStyle hFull() => heightFull();
  
  FxStyle background(Color color) => copyWith(backgroundColor: color);
  FxStyle backgroundWhite() => copyWith(backgroundColor: Color(0xFFFFFFFF));
  FxStyle backgroundBlack() => copyWith(backgroundColor: Color(0xFF000000));
  
  // -- Aliases for Background --
  FxStyle bg(Color color) => background(color);

  FxStyle linearGradient(List<Color> colors, {Alignment begin = Alignment.topLeft, Alignment end = Alignment.bottomRight}) =>
      copyWith(gradient: LinearGradient(colors: colors, begin: begin, end: end));
  
  FxStyle radialGradient(List<Color> colors) => copyWith(gradient: RadialGradient(colors: colors));
  
  FxStyle setBorderRadius(double value) => copyWith(borderRadius: BorderRadius.circular(value));
  FxStyle radiusSmall() => setBorderRadius(FxTokens.radius.sm);
  FxStyle radiusMedium() => setBorderRadius(FxTokens.radius.md);
  FxStyle radiusLarge() => setBorderRadius(FxTokens.radius.lg);
  FxStyle radiusFull() => setBorderRadius(FxTokens.radius.full);

  // -- Aliases for Radius --
  FxStyle radius(double value) => setBorderRadius(value);
  FxStyle rounded(double value) => setBorderRadius(value);
  FxStyle roundedFull() => radiusFull();

  FxStyle shadow({Color color = const Color(0x1F000000), double blur = 4, Offset offset = const Offset(0, 2)}) => 
      copyWith(shadows: [BoxShadow(color: color, blurRadius: blur, offset: offset)]);
  
  FxStyle shadowSmall() => copyWith(shadows: FxTokens.shadow.sm);
  FxStyle shadowMedium() => copyWith(shadows: FxTokens.shadow.md);
  FxStyle shadowLarge() => copyWith(shadows: FxTokens.shadow.lg);

  FxStyle withBorder({Color color = const Color(0xFF000000), double width = 1}) => 
      copyWith(border: Border.all(color: color, width: width));
      
  FxStyle withGap(double value) => copyWith(gap: value);

  FxStyle setFontSize(double size) => copyWith(fontSize: size);
  FxStyle setFontWeight(FontWeight weight) => copyWith(fontWeight: weight);
  FxStyle textColor(Color color) => copyWith(color: color);
  FxStyle setTextAlign(TextAlign align) => copyWith(textAlign: align);
  
  FxStyle textBase() => setFontSize(FxTokens.font.md);
  FxStyle textLg() => setFontSize(FxTokens.font.lg);
  FxStyle textXl() => setFontSize(FxTokens.font.xl);
  FxStyle bold() => setFontWeight(FontWeight.bold);

  // -- Aliases for Typography --
  FxStyle font(double size) => setFontSize(size);
  FxStyle fs(double size) => setFontSize(size);
  FxStyle fw(FontWeight weight) => setFontWeight(weight);
  FxStyle tc(Color color) => textColor(color);
  
  FxStyle align(AlignmentGeometry alignment) => copyWith(alignment: alignment);
  FxStyle center() => copyWith(alignment: Alignment.center);
  
  /// Sets opacity (renamed to avoid collision with opacity getter).
  FxStyle withOpacity(double value) => copyWith(opacity: value);
  FxStyle op(double value) => copyWith(opacity: value);
  
  // -- Layout Behavior --
  FxStyle pack() => copyWith(mainAxisSize: MainAxisSize.min);
  FxStyle stretch() => copyWith(mainAxisSize: MainAxisSize.max);
}
