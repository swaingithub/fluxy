import 'package:flutter/widgets.dart';
import '../styles/style.dart';

/// A mixin that provides fluent modifier methods for Fluxy widgets.
mixin FxModifier<T extends Widget> {
  FxStyle get style;
  
  T copyWith({FxStyle? style});

  // --- Layout Modifiers ---
  T pad(double value) => copyWith(style: style.copyWith(FxStyle(padding: EdgeInsets.all(value))));
  T padX(double value) => copyWith(style: style.copyWith(FxStyle(padding: EdgeInsets.symmetric(horizontal: value))));
  T padY(double value) => copyWith(style: style.copyWith(FxStyle(padding: EdgeInsets.symmetric(vertical: value))));
  T padOnly({double left = 0, double top = 0, double right = 0, double bottom = 0}) => 
      copyWith(style: style.copyWith(FxStyle(padding: EdgeInsets.only(left: left, top: top, right: right, bottom: bottom))));

  T margin(double value) => copyWith(style: style.copyWith(FxStyle(margin: EdgeInsets.all(value))));
  T marginX(double value) => copyWith(style: style.copyWith(FxStyle(margin: EdgeInsets.symmetric(horizontal: value))));
  T marginY(double value) => copyWith(style: style.copyWith(FxStyle(margin: EdgeInsets.symmetric(vertical: value))));

  T width(double value) => copyWith(style: style.copyWith(FxStyle(width: value)));
  T height(double value) => copyWith(style: style.copyWith(FxStyle(height: value)));
  T size(double w, double h) => copyWith(style: style.copyWith(FxStyle(width: w, height: h)));

  // --- Visual Modifiers ---
  T bg(Color color) => copyWith(style: style.copyWith(FxStyle(backgroundColor: color)));
  T radius(double value) => copyWith(style: style.copyWith(FxStyle(borderRadius: BorderRadius.circular(value))));
  T shadow({Color color = const Color(0x1F000000), double blur = 4}) => 
      copyWith(style: style.copyWith(FxStyle(shadows: [BoxShadow(color: color, blurRadius: blur)])));
  
  T border({Color color = const Color(0xFF000000), double width = 1}) => 
      copyWith(style: style.copyWith(FxStyle(border: Border.all(color: color, width: width))));

  T align(AlignmentGeometry alignment) => copyWith(style: style.copyWith(FxStyle(alignment: alignment)));
  T center() => align(Alignment.center);

  T opacity(double value) => copyWith(style: style.copyWith(FxStyle(opacity: value)));
  T glass(double value) => copyWith(style: style.copyWith(FxStyle(glass: value)));

  // --- Flex Modifiers ---
  T flex(int value) => copyWith(style: style.copyWith(FxStyle(flex: value)));
  T fit(FlexFit value) => copyWith(style: style.copyWith(FxStyle(flexFit: value)));
  T expanded() => copyWith(style: style.copyWith(const FxStyle(flex: 1, flexFit: FlexFit.tight)));
  T space(double value) => copyWith(style: style.copyWith(FxStyle(gap: value)));

  T font(double size) => copyWith(style: style.copyWith(FxStyle(fontSize: size)));
  T bold() => copyWith(style: style.copyWith(FxStyle(fontWeight: FontWeight.bold)));
  T weight(FontWeight weight) => copyWith(style: style.copyWith(FxStyle(fontWeight: weight)));
  T color(Color color) => copyWith(style: style.copyWith(FxStyle(color: color)));
  T lSpacing(double value) => copyWith(style: style.copyWith(FxStyle(letterSpacing: value)));
  T lHeight(double value) => copyWith(style: style.copyWith(FxStyle(height_multiplier: value)));
  T maxLines(int value) => copyWith(style: style.copyWith(FxStyle(maxLines: value)));
  T overflow(TextOverflow value) => copyWith(style: style.copyWith(FxStyle(overflow: value)));
  T centerText() => copyWith(style: style.copyWith(const FxStyle(textAlign: TextAlign.center)));

  // --- Utility ---
  T cursor(MouseCursor value) => copyWith(style: style.copyWith(FxStyle(cursor: value)));
  T pointer() => cursor(SystemMouseCursors.click);
}
