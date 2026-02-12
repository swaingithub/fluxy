import 'package:flutter/material.dart';
import '../styles/style.dart';
import '../widgets/box.dart';
import '../widgets/text_box.dart';
import '../widgets/flex_box.dart';
import '../widgets/grid_box.dart';
import '../widgets/stack_box.dart';
import '../reactive/signal.dart';
import '../reactive/async_signal.dart';
import '../widgets/inputs.dart';
import '../motion/fx_motion.dart';
import '../routing/fluxy_router.dart';

/// The hyper-minimal Fx API for Fluxy.
/// Designed for maximum builder velocity and zero boilerplate reactivity.
class Fx extends StatefulWidget {
  final Widget Function() builder;

  const Fx(this.builder, {super.key});

  @override
  State<Fx> createState() => _FxState();

  /// A reactive text element. 
  static Widget text(dynamic data, {FxStyle style = FxStyle.none, String? className, FxResponsiveStyle? responsive}) {
    return TextBox(
      data: data ?? '',
      style: style,
      className: className,
      responsive: responsive,
    );
  }

  /// A reactive container.
  static Widget box({
    FxStyle style = FxStyle.none,
    String? className,
    FxResponsiveStyle? responsive,
    Widget child = const SizedBox.shrink(),
    List<Widget> children = const [],
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
    FxStyle style = FxStyle.none,
    String? className,
    FxResponsiveStyle? responsive,
    Widget child = const SizedBox.shrink(),
    List<Widget> children = const [],
    VoidCallback? onTap,
  }) => box(style: style, className: className, responsive: responsive, child: child, children: children, onTap: onTap);

  /// A physical button with default semantics and styles.
  static Widget button({
    required dynamic child,
    required VoidCallback onTap,
    FxStyle style = FxStyle.none,
    String? className,
  }) {
    final decorationStyle = const FxStyle(
        transition: Duration(milliseconds: 150),
        hover: FxStyle(backgroundColor: Color(0xFF2563EB)), 
        pressed: FxStyle(opacity: 0.7),
      ).merge(style);

    return Box(
      onTap: onTap,
      className: "px-6 py-3 bg-blue-600 rounded-xl items-center justify-center $className",
      style: decorationStyle,
      child: child is String ? text(child, className: "text-white font-bold") : (child as Widget),
    );
  }

  /// Horizontal layout.
  static Widget row({
    required List<Widget> children,
    FxStyle style = FxStyle.none,
    String? className,
    FxResponsiveStyle? responsive,
    double? gap,
  }) {
    return FlexBox(
      direction: Axis.horizontal,
      style: style.merge(FxStyle(gap: gap)),
      className: className,
      responsive: responsive,
      children: children,
    );
  }

  /// Vertical layout.
  static Widget column({
    required List<Widget> children,
    FxStyle style = FxStyle.none,
    String? className,
    FxResponsiveStyle? responsive,
    double? gap,
  }) {
    return FlexBox(
      direction: Axis.vertical,
      style: style.merge(FxStyle(gap: gap)),
      className: className,
      responsive: responsive,
      children: children,
    );
  }

  /// Grid layout.
  static Widget grid({
    required List<Widget> children,
    FxStyle style = FxStyle.none,
    String? className,
    FxResponsiveStyle? responsive,
  }) {
    return GridBox(
      style: style,
      className: className,
      responsive: responsive,
      children: children,
    );
  }

  /// Stack layout.
  static Widget stack({
    required List<Widget> children,
    FxStyle style = FxStyle.none,
    String? className,
    FxResponsiveStyle? responsive,
  }) {
    return StackBox(
      style: style,
      className: className,
      responsive: responsive,
      children: children,
    );
  }

  /// Staggers a list of widgets with a delay.
  static List<Widget> stagger(List<Widget> children, {double interval = 0.05, double initialDelay = 0}) {
    return children.asMap().entries.map((entry) {
      final child = entry.value;
      final index = entry.key;
      
      if (child is FxMotion) {
        final m = child;
        return FxMotion(
          duration: m.duration,
          curve: m.curve,
          spring: m.spring,
          delay: (m.delay ?? 0) + initialDelay + (index * interval),
          autoStart: m.autoStart,
          fade: m.fade,
          slide: m.slide,
          scale: m.scale,
          rotate: m.rotate,
          child: m.child,
        );
      }
      return child;
    }).toList();
  }

  /// Spacer for layouts.
  static Widget gap(double value) => SizedBox(width: value, height: value);

  /// A flexible spacer that expands to fill available space.
  static Widget spacer() => const Spacer();

  /// A modern horizontal divider.
  static Widget divider({Color? color, double thickness = 1, double indent = 0}) {
    return Divider(color: color, thickness: thickness, indent: indent, endIndent: indent);
  }

  /// A reactive image loader.
  static Widget image(String url, {double? width, double? height, BoxFit fit = BoxFit.cover, double radius = 0}) {
    final imageWidget = Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => box(
        style: FxStyle(backgroundColor: const Color(0xFFF3F4F6), width: width, height: height, borderRadius: BorderRadius.circular(radius)),
        child: const Icon(Icons.broken_image, color: Colors.grey),
      ),
    );

    if (radius > 0) {
      return ClipRRect(borderRadius: BorderRadius.circular(radius), child: imageWidget);
    }
    return imageWidget;
  }

  /// A centered loading indicator.
  static Widget loader({Color? color, double size = 24}) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(color ?? const Color(0xFF2563EB))),
      ),
    );
  }

  /// Async UI Builder
  static Widget async<T>(
    AsyncSignal<T> signal, {
    required Widget Function() loading,
    required Widget Function(Object error) error,
    required Widget Function(T data) data,
  }) {
    return signal.on(loading: loading, data: data, error: error);
  }

  // --- Input Widgets ---

  /// A reactive text field.
  static Widget textField({
    required Signal<String> signal,
    String? placeholder,
    InputDecoration? decoration,
    TextStyle? style,
    bool obscureText = false,
  }) {
    return FxTextField(
      signal: signal,
      placeholder: placeholder,
      decoration: decoration,
      style: style,
      obscureText: obscureText,
    );
  }

  /// A reactive checkbox.
  static Widget checkbox({
    required Signal<bool> signal,
    Color? activeColor,
  }) {
    return FxCheckbox(
      signal: signal,
      activeColor: activeColor,
    );
  }

  /// A reactive slider.
  static Widget slider({
    required Signal<double> signal,
    double min = 0,
    double max = 100,
    int? divisions,
    Color? activeColor,
  }) {
    return FxSlider(
      signal: signal,
      min: min,
      max: max,
      divisions: divisions,
      activeColor: activeColor,
    );
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
  static Widget card({required Widget child, FxStyle style = FxStyle.none, String? className}) {
    return box(
      style: const FxStyle(
        backgroundColor: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.all(Radius.circular(12)),
        padding: EdgeInsets.all(16),
        shadows: [BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 4))],
      ).merge(style),
      className: className,
      child: child,
    );
  }

  /// A section with a title and children.
  static Widget section({required String title, required List<Widget> children, double gap = 8}) {
    return column(
      gap: 16,
      children: [
        text(title, style: const FxStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        column(gap: gap, children: children),
      ],
    );
  }

  // Navigation
  static Future<T?> go<T>(String route, {Map<String, dynamic>? arguments}) => FluxyRouter.to<T>(route, arguments: arguments);
  static Future<T?> off<T, TO>(String route, {TO? result, Map<String, dynamic>? arguments}) => FluxyRouter.off<T, TO>(route, result: result, arguments: arguments);
  static Future<T?> offAll<T>(String route, {Map<String, dynamic>? arguments}) => FluxyRouter.offAll<T>(route, arguments: arguments);
  static void back<T>([T? result]) => FluxyRouter.back<T>(result);
}

class _FxState extends State<Fx> with ReactiveSubscriberMixin {
  @override
  void notify() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    clearDependencies();
    super.dispose();
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
