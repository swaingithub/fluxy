import 'package:flutter/widgets.dart';
import '../styles/style.dart';

/// A mixin that provides fluent modifier methods for Fluxy widgets.
mixin FxModifier<T extends Widget> {
  Style get style;
  
  T copyWith({Style? style});

  // Layout Modifiers
  T pad(double value) => copyWith(style: style.copyWith(Style(padding: EdgeInsets.all(value))));
  T padX(double value) => copyWith(style: style.copyWith(Style(padding: EdgeInsets.symmetric(horizontal: value))));
  T padY(double value) => copyWith(style: style.copyWith(Style(padding: EdgeInsets.symmetric(vertical: value))));
  T padOnly({double left = 0, double top = 0, double right = 0, double bottom = 0}) => 
      copyWith(style: style.copyWith(Style(padding: EdgeInsets.only(left: left, top: top, right: right, bottom: bottom))));

  T margin(double value) => copyWith(style: style.copyWith(Style(margin: EdgeInsets.all(value))));
  T marginX(double value) => copyWith(style: style.copyWith(Style(margin: EdgeInsets.symmetric(horizontal: value))));
  T marginY(double value) => copyWith(style: style.copyWith(Style(margin: EdgeInsets.symmetric(vertical: value))));

  T width(double value) => copyWith(style: style.copyWith(Style(width: value)));
  T height(double value) => copyWith(style: style.copyWith(Style(height: value)));
  T size(double w, double h) => copyWith(style: style.copyWith(Style(width: w, height: h)));

  T bg(Color color) => copyWith(style: style.copyWith(Style(backgroundColor: color)));
  T radius(double value) => copyWith(style: style.copyWith(Style(borderRadius: BorderRadius.circular(value))));
  T shadow({Color color = const Color(0x1F000000), double blur = 4}) => 
      copyWith(style: style.copyWith(Style(shadows: [BoxShadow(color: color, blurRadius: blur)])));
  
  T border({Color color = const Color(0xFF000000), double width = 1}) => 
      copyWith(style: style.copyWith(Style(border: Border.all(color: color, width: width))));

  T align(AlignmentGeometry alignment) => copyWith(style: style.copyWith(Style(alignment: alignment)));
  T center() => align(Alignment.center);

  T opacity(double value) => copyWith(style: style.copyWith(Style(glass: 1.0 - value))); // Simple mapping for now

  // Flex Modifiers
  T flex(int value) => copyWith(style: style.copyWith(Style(flex: value)));
  T fit(FlexFit value) => copyWith(style: style.copyWith(Style(flexFit: value)));
  T expanded() => copyWith(style: style.copyWith(const Style(flex: 1, flexFit: FlexFit.tight)));
  T space(double value) => copyWith(style: style.copyWith(Style(gap: value)));

  // Text Modifiers (Specific to Text but available on all for fluidity if used on Box)
  T font(double size) => copyWith(style: style.copyWith(Style(fontSize: size)));
  T bold() => copyWith(style: style.copyWith(Style(fontWeight: FontWeight.bold)));
  T weight(FontWeight weight) => copyWith(style: style.copyWith(Style(fontWeight: weight)));
  T color(Color color) => copyWith(style: style.copyWith(Style(color: color)));
}
