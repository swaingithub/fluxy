import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show Color, SizedBox;
import '../styles/style.dart';
import '../widgets/box.dart';
import '../widgets/text_box.dart';
import '../widgets/flex_box.dart';
import '../widgets/grid_box.dart';
import '../widgets/stack_box.dart';
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
  static TextBox text(dynamic data, {Style? style, String? className, ResponsiveStyle? responsive}) {
    return TextBox(
      data: data is Function ? data().toString() : data.toString(),
      style: style ?? const Style(),
      className: className,
      responsive: responsive,
    );
  }

  /// A reactive container.
  static Box box({
    Style? style,
    String? className,
    ResponsiveStyle? responsive,
    Widget? child,
    List<Widget>? children,
    VoidCallback? onTap,
  }) {
    return Box(
      style: style ?? const Style(),
      className: className,
      responsive: responsive,
      child: child,
      children: children,
      onTap: onTap,
    );
  }

  /// Alias for box.
  static Box container({
    Style? style,
    String? className,
    ResponsiveStyle? responsive,
    Widget? child,
    List<Widget>? children,
    VoidCallback? onTap,
  }) => box(style: style, className: className, responsive: responsive, child: child, children: children, onTap: onTap);

  /// A physical button with default semantics and styles.
  static Box button({
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

  /// Horizontal layout.
  static FlexBox row({
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

  /// Vertical layout.
  static FlexBox column({
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

  /// Grid layout.
  static GridBox grid({
    required List<Widget> children,
    Style? style,
    String? className,
    ResponsiveStyle? responsive,
  }) {
    return GridBox(
      children: children,
      style: style ?? const Style(),
      className: className,
      responsive: responsive,
    );
  }

  /// Stack layout.
  static StackBox stack({
    required List<Widget> children,
    Style? style,
    String? className,
    ResponsiveStyle? responsive,
  }) {
    return StackBox(
      children: children,
      style: style ?? const Style(),
      className: className,
      responsive: responsive,
    );
  }

  /// Spacer for layouts.
  static Widget gap(double value) => SizedBox(width: value, height: value);

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

  // Conditional Rendering
  static Widget showIf(bool condition, Widget child) => condition ? child : const SizedBox.shrink();
  static Widget visible(bool condition, Widget child) => Visibility(visible: condition, child: child);

  static Widget responsive({
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    return Fx(() {
      final context = FluxyRouter.navigatorKey.currentState?.context;
      if (context == null) return mobile;
      final width = MediaQuery.of(context).size.width;
      if (width >= 1024) return desktop ?? tablet ?? mobile;
      if (width >= 600) return tablet ?? mobile;
      return mobile;
    });
  }

  // --- Smart UI Presets ---

  /// A modern card preset.
  static Box card({required Widget child, Style? style, String? className}) {
    return box(
      style: const Style(
        backgroundColor: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.all(Radius.circular(12)),
        padding: EdgeInsets.all(16),
        shadows: [BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 4))],
      ).copyWith(style),
      className: className,
      child: child,
    );
  }

  /// A section with a title and children.
  static FlexBox section({required String title, required List<Widget> children, double gap = 8}) {
    return column(
      gap: 16,
      children: [
        text(title, style: const Style(fontSize: 18, fontWeight: FontWeight.bold)),
        column(gap: gap, children: children),
      ],
    );
  }

  // Navigation
  static void go(String route) => FluxyRouter.to(route);
  static void back() => FluxyRouter.back();
  static void offAll(String route) => FluxyRouter.offAll(route);
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
