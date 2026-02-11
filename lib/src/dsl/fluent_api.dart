import 'package:flutter/widgets.dart';
import '../styles/style.dart';
import '../widgets/box.dart';

/// Extension to provide a fluent DSL experience.
extension FluxyWidgetExtension on Widget {
  Widget styled(FxStyle style) {
    return Box(
      style: style,
      child: this,
    );
  }
}

/// A functional approach to building Fluxy layouts.
class Fluxy {
  static Widget div({
    FxStyle? style,
    Widget? child,
    List<Widget>? children,
  }) {
    return Box(
      style: style ?? FxStyle.none,
      child: child,
      children: children,
    );
  }

  static Widget row({
    FxStyle? style,
    required List<Widget> children,
  }) {
    return Box(
      style: (style ?? FxStyle.none).copyWith(const FxStyle(justifyContent: MainAxisAlignment.start)),
      children: children,
    );
  }
}
