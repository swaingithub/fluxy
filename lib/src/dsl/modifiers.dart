import 'package:flutter/widgets.dart';
import '../styles/style.dart';
import '../widgets/box.dart';
import '../widgets/text_box.dart';
import '../widgets/flex_box.dart';
import '../widgets/grid_box.dart';
import '../widgets/stack_box.dart';

/// Extension to provide a fluent DSL experience for any Widget.
extension FluxyWidgetExtension on Widget {
  Widget _applyStyle(FxStyle style) {
    final current = this;
    if (current is Box) {
      return current.copyWith(style: current.style.merge(style));
    }
    if (current is TextBox) {
      return current.copyWith(style: current.style.merge(style));
    }
    if (current is FlexBox) {
      return current.copyWith(style: current.style.merge(style));
    }
    if (current is GridBox) {
      return current.copyWith(style: current.style.merge(style));
    }
    if (current is StackBox) {
      return current.copyWith(style: current.style.merge(style));
    }
    
    return Box(
      style: style,
      child: current,
    );
  }

  // --- Chaining Builders ---
  Widget child(Widget child) {
    final current = this;
    if (current is Box) return current.copyWith(child: child);
    return current;
  }

  Widget children(List<Widget> children) {
    final current = this;
    if (current is Box) return current.copyWith(children: children);
    if (current is FlexBox) return current.copyWith(children: children);
    if (current is GridBox) return current.copyWith(children: children);
    if (current is StackBox) return current.copyWith(children: children);
    return current;
  }

  /// Generic copyWith for backward compatibility and chaining.
  Widget copyWith({
    FxStyle? style,
    String? className,
    FxResponsiveStyle? responsive,
    Widget? child,
    List<Widget>? children,
    VoidCallback? onTap,
    String? data,
  }) {
    final current = this;
    if (current is Box) {
      return current.copyWith(
        style: style,
        className: className,
        responsive: responsive,
        child: child,
        children: children,
        onTap: onTap,
      );
    }
    if (current is TextBox) {
      return current.copyWith(
        style: style,
        className: className,
        responsive: responsive,
        data: data,
      );
    }
    if (current is FlexBox) {
      return current.copyWith(
        style: style,
        className: className,
        responsive: responsive,
        children: children,
      );
    }
    if (current is GridBox) {
      return current.copyWith(
        style: style,
        className: className,
        responsive: responsive,
        children: children,
      );
    }
    if (current is StackBox) {
      return current.copyWith(
        style: style,
        className: className,
        responsive: responsive,
        children: children,
      );
    }
    
    if (style != null) return _applyStyle(style);
    return this;
  }

  // --- Layout Modifiers ---
  Widget pad(double value) => _applyStyle(FxStyle(padding: EdgeInsets.all(value)));
  Widget padX(double value) => _applyStyle(FxStyle(padding: EdgeInsets.symmetric(horizontal: value)));
  Widget padY(double value) => _applyStyle(FxStyle(padding: EdgeInsets.symmetric(vertical: value)));
  Widget padOnly({double left = 0, double top = 0, double right = 0, double bottom = 0}) => 
      _applyStyle(FxStyle(padding: EdgeInsets.only(left: left, top: top, right: right, bottom: bottom)));

  Widget margin(double value) => _applyStyle(FxStyle(margin: EdgeInsets.all(value)));
  Widget marginX(double value) => _applyStyle(FxStyle(margin: EdgeInsets.symmetric(horizontal: value)));
  Widget marginY(double value) => _applyStyle(FxStyle(margin: EdgeInsets.symmetric(vertical: value)));

  Widget width(double value) => _applyStyle(FxStyle(width: value));
  Widget height(double value) => _applyStyle(FxStyle(height: value));
  Widget size(double w, double h) => _applyStyle(FxStyle(width: w, height: h));

  // --- Visual Modifiers ---
  Widget bg(Color color) => _applyStyle(FxStyle(backgroundColor: color));
  Widget radius(double value) => _applyStyle(FxStyle(borderRadius: BorderRadius.circular(value)));
  Widget shadow({Color color = const Color(0x1F000000), double blur = 4}) => 
      _applyStyle(FxStyle(shadows: [BoxShadow(color: color, blurRadius: blur)]));
  
  Widget border({Color color = const Color(0xFF000000), double width = 1}) => 
      _applyStyle(FxStyle(border: Border.all(color: color, width: width)));

  Widget align(AlignmentGeometry alignment) => _applyStyle(FxStyle(alignment: alignment));
  Widget center() => align(Alignment.center);

  Widget opacity(double value) => _applyStyle(FxStyle(opacity: value));
  Widget glass(double value) => _applyStyle(FxStyle(glass: value));

  // --- Flex Modifiers ---
  Widget flex(int value) => _applyStyle(FxStyle(flex: value));
  Widget fit(FlexFit value) => _applyStyle(FxStyle(flexFit: value));
  Widget expanded() => _applyStyle(const FxStyle(flex: 1, flexFit: FlexFit.tight));
  Widget space(double value) => _applyStyle(FxStyle(gap: value));

  Widget font(double size) => _applyStyle(FxStyle(fontSize: size));
  Widget bold() => _applyStyle(const FxStyle(fontWeight: FontWeight.bold));
  Widget weight(FontWeight weight) => _applyStyle(FxStyle(fontWeight: weight));
  Widget color(Color color) => _applyStyle(FxStyle(color: color));
  Widget lSpacing(double value) => _applyStyle(FxStyle(letterSpacing: value));
  Widget lHeight(double value) => _applyStyle(FxStyle(lineHeight: value));
  Widget maxLines(int value) => _applyStyle(FxStyle(maxLines: value));
  Widget overflow(TextOverflow value) => _applyStyle(FxStyle(overflow: value));
  Widget centerText() => _applyStyle(const FxStyle(textAlign: TextAlign.center));

  // --- Utility ---
  Widget cursor(MouseCursor value) => _applyStyle(FxStyle(cursor: value));
  Widget pointer() => cursor(SystemMouseCursors.click);
}
