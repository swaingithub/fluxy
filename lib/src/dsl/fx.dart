import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show Color, SizedBox, Colors;
import '../styles/style.dart';
import '../widgets/box.dart';
import '../widgets/text_box.dart';
import '../widgets/flex_box.dart';
import '../reactive/signal.dart';
import '../reactive/async_signal.dart';
import '../routing/fluxy_router.dart';

/// The hyper-minimal Fx API for Fluxy.
/// Designed for maximum builder velocity and zero boilerplate reactivity.
class Fx extends StatefulWidget {
  final Widget Function() builder;

  const Fx(this.builder, {super.key});

  @override
  State<Fx> createState() => _FxState();

  /// A reactive text element. 
  static Widget text(dynamic data, {Style? style, String? className, ResponsiveStyle? responsive}) {
    return TextBox(
      data: data is Function ? data().toString() : data.toString(),
      style: style,
      className: className,
      responsive: responsive,
    );
  }

  /// A reactive container.
  static Widget box({
    Style? style,
    String? className,
    ResponsiveStyle? responsive,
    Widget? child,
    List<Widget>? children,
    VoidCallback? onTap,
  }) {
    return Box(
      style: style,
      className: className,
      responsive: responsive,
      child: child,
      children: children,
      onTap: onTap,
    );
  }

  /// Alias for box.
  static Widget container({
    Style? style,
    String? className,
    ResponsiveStyle? responsive,
    Widget? child,
    List<Widget>? children,
    VoidCallback? onTap,
  }) => box(style: style, className: className, responsive: responsive, child: child, children: children, onTap: onTap);

  /// A physical button with default semantics and styles.
  static Widget button({
    required dynamic child,
    required VoidCallback onTap,
    Style? style,
    String? className,
  }) {
    return Box(
      onTap: onTap,
      className: "px-6 py-3 bg-blue-600 rounded-xl items-center justify-center $className",
      style: const Style(
        transition: Duration(milliseconds: 150),
        hover: Style(backgroundColor: Color(0xFF2563EB)), 
        pressed: Style(glass: 0.1),
      ).copyWith(style),
      child: child is String ? text(child, className: "text-white font-bold") : child,
    );
  }

  /// Async UI Builder
  static Widget async<T>(
    AsyncSignal<T> signal, {
    required Widget Function() loading,
    required Widget Function(Object error) error,
    required Widget Function(T data) data,
  }) {
    return Fx(() {
      if (signal.isLoading) return loading();
      if (signal.hasError) return error(signal.error!);
      if (signal.hasData) return data(signal.value as T);
      return const SizedBox.shrink();
    });
  }

  // Navigation
  static void go(String route) => FluxyRouter.to(route);
  static void back() => FluxyRouter.back();
  static void offAll(String route) => FluxyRouter.off(route);

  /// A horizontal flex container.
  static Widget row({
    required List<Widget> children,
    Style? style,
    String? className,
    ResponsiveStyle? responsive,
    double? gap,
  }) {
    return FlexBox(
      direction: Axis.horizontal,
      children: children,
      style: (style ?? const Style()).copyWith(Style(gap: gap)),
      className: className,
      responsive: responsive,
    );
  }

  /// A vertical flex container.
  static Widget column({
    required List<Widget> children,
    Style? style,
    String? className,
    ResponsiveStyle? responsive,
    double? gap,
  }) {
    return FlexBox(
      direction: Axis.vertical,
      children: children,
      style: (style ?? const Style()).copyWith(Style(gap: gap)),
      className: className,
      responsive: responsive,
    );
  }
}

class _FxState extends State<Fx> implements FluxySubscriber {
  @override
  void notify() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    FluxyReactiveContext.push(this);
    try {
      return widget.builder();
    } finally {
      FluxyReactiveContext.pop();
    }
  }
}
