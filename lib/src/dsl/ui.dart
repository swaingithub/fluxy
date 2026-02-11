import 'package:flutter/widgets.dart';
import '../styles/style.dart';
import '../widgets/box.dart';
import '../widgets/flex_box.dart';
import '../widgets/grid_box.dart';
import '../widgets/stack_box.dart';
import '../widgets/text_box.dart';

/// The primary UI DSL for Fluxy.
/// Provides a web-like layout experience with native performance.
class UI {
  /// Basic box container (like a div).
  static Widget box({
    FxStyle? style,
    String? className,
    FxResponsiveStyle? responsive,
    Widget? child,
    List<Widget>? children,
    VoidCallback? onTap,
  }) => Box(
    style: style ?? FxStyle.none,
    className: className,
    responsive: responsive,
    child: child,
    children: children,
    onTap: onTap,
  );

  /// Horizontal layout (flex-direction: row).
  static Widget row({
    FxStyle? style,
    String? className,
    FxResponsiveStyle? responsive,
    required List<Widget> children,
  }) => FlexBox(
    direction: Axis.horizontal,
    style: style ?? FxStyle.none,
    className: className,
    responsive: responsive,
    children: children,
  );

  /// Vertical layout (flex-direction: column).
  static Widget column({
    FxStyle? style,
    String? className,
    FxResponsiveStyle? responsive,
    required List<Widget> children,
  }) => FlexBox(
    direction: Axis.vertical,
    style: style ?? FxStyle.none,
    className: className,
    responsive: responsive,
    children: children,
  );

  /// Flexible layout with custom direction.
  static Widget flex({
    required Axis direction,
    FxStyle? style,
    String? className,
    FxResponsiveStyle? responsive,
    required List<Widget> children,
  }) => FlexBox(
    direction: direction,
    style: style ?? FxStyle.none,
    className: className,
    responsive: responsive,
    children: children,
  );

  /// Grid layout (display: grid).
  static Widget grid({
    FxStyle? style,
    String? className,
    FxResponsiveStyle? responsive,
    required List<Widget> children,
  }) => GridBox(
    style: style ?? FxStyle.none,
    className: className,
    responsive: responsive,
    children: children,
  );

  /// Overlay layout (position: absolute/relative).
  static Widget stack({
    FxStyle? style,
    String? className,
    FxResponsiveStyle? responsive,
    required List<Widget> children,
  }) => StackBox(
    style: style ?? FxStyle.none,
    className: className,
    responsive: responsive,
    children: children,
  );

  /// Styled text component.
  static Widget text(
    String data, {
    FxStyle? style,
    String? className,
    FxResponsiveStyle? responsive,
  }) => TextBox(
    data: data,
    style: style ?? FxStyle.none,
    className: className,
    responsive: responsive,
  );
}
