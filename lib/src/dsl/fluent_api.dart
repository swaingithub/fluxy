import 'package:flutter/widgets.dart';
import '../styles/style.dart';
import '../widgets/box.dart';

/// Extension to provide a fluent DSL experience.
extension FluxyWidgetExtension on Widget {
  Widget styled(Style style) {
    return Box(
      style: style,
      child: this,
    );
  }
}

/// A functional approach to building Fluxy layouts.
class Fluxy {
  static Widget div({
    Style? style,
    Widget? child,
    List<Widget>? children,
  }) {
    return Box(
      style: style ?? const Style(),
      child: child,
      children: children,
    );
  }

  static Widget row({
    Style? style,
    required List<Widget> children,
  }) {
    return Box(
      style: (style ?? const Style()).copyWith(const Style(justifyContent: MainAxisAlignment.start)),
      children: children,
    );
  }
}
