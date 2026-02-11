import 'package:flutter/widgets.dart';
import '../styles/style.dart';
import '../widgets/box.dart';

/// A functional approach to building Fluxy layouts.
class Fluxy {
  static Widget div({
    FxStyle style = FxStyle.none,
    Widget child = const SizedBox.shrink(),
    List<Widget> children = const [],
  }) {
    return Box(
      style: style,
      child: child,
      children: children,
    );
  }

  static Widget row({
    FxStyle style = FxStyle.none,
    required List<Widget> children,
  }) {
    return Box(
      style: style.merge(const FxStyle(justifyContent: MainAxisAlignment.start)),
      children: children,
    );
  }
}
