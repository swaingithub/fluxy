import 'dart:ui';
import 'package:flutter/widgets.dart';
import '../styles/style.dart';
import '../engine/style_resolver.dart';
import '../engine/decoration_builder.dart';
import '../engine/diff_engine.dart';
import '../reactive/signal.dart';

/// The foundational building block of Fluxy.
/// Similar to a <div> in web development.
class Box extends StatefulWidget {
  final String? id;
  final FxStyle style;
  final String? className;
  final FxResponsiveStyle? responsive;
  final dynamic child;
  final dynamic children;
  final VoidCallback? onTap;

  const Box({
    super.key,
    this.id,
    this.style = FxStyle.none,
    this.className,
    this.responsive,
    this.child = const SizedBox.shrink(),
    this.children = const [],
    this.onTap,
  });

  Box copyWith({
    FxStyle? style,
    String? className,
    FxResponsiveStyle? responsive,
    dynamic child,
    dynamic children,
    VoidCallback? onTap,
  }) {
    return Box(
      id: id,
      style: style ?? this.style,
      className: className ?? this.className,
      responsive: responsive ?? this.responsive,
      child: child ?? this.child,
      children: children ?? this.children,
      onTap: onTap ?? this.onTap,
    );
  }

  @override
  State<Box> createState() => _BoxState();
}

class _BoxState extends State<Box> with ReactiveSubscriberMixin {
  bool _isHovered = false;
  bool _isPressed = false;

  // Cache the resolved style and built widget
  FxStyle? _lastResolvedBase;
  Widget? _cachedWidget;

  @override
  void notify() {
    if (mounted) {
      setState(() {});
    }
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
      final base = FxStyleResolver.resolve(
        context,
        style: widget.style,
        className: widget.className,
        responsive: widget.responsive,
      );

      final shouldRebuild =
          _cachedWidget == null ||
          DiffEngine.shouldRebuild(
            oldStyle: _lastResolvedBase,
            newStyle: base,
            structuralChange: false,
          );

      _lastResolvedBase = base;

      final s = FxStyleResolver.resolveInteractive(
        base,
        isHovered: _isHovered,
        isPressed: _isPressed,
      );

      if (shouldRebuild || _isHovered || _isPressed) {
        _cachedWidget = _buildContent(s);
      }

      return _cachedWidget ?? const SizedBox.shrink();
    } finally {
      FluxyReactiveContext.pop();
    }
  }

  Widget _buildContent(FxStyle s) {
    final List<Widget> resolvedChildren = widget.children is Function
        ? (widget.children as Function)()
        : (widget.children is List<Widget> ? widget.children : []);
    final Widget resolvedChild = widget.child is Function
        ? (widget.child as Function)()
        : (widget.child is Widget ? widget.child : const SizedBox.shrink());

    Widget current = resolvedChildren.isNotEmpty
        ? _buildChildren(s, resolvedChildren)
        : resolvedChild;

    // Apply Opacity
    final opacityVal = s.opacity;
    if (opacityVal != null) {
      current = Opacity(opacity: opacityVal, child: current);
    }

    // Apply Glassmorphism
    final glassVal = s.glass;
    if (glassVal != null && glassVal > 0) {
      current = ClipRRect(
        borderRadius: s.borderRadius ?? BorderRadius.zero,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: glassVal, sigmaY: glassVal),
          child: current,
        ),
      );
    }

    // Apply Aspect Ratio
    final aspectVal = s.aspectRatio;
    if (aspectVal != null) {
      current = AspectRatio(aspectRatio: aspectVal, child: current);
    }

    // Apply Visuals using FxDecorationBuilder
    final transitionVal = s.transition;
    if (transitionVal != null) {
      current = AnimatedContainer(
        duration: transitionVal,
        width: s.width,
        height: s.height,
        padding: s.padding,
        margin: s.margin,
        alignment: s.alignment,
        clipBehavior: s.clipBehavior ?? Clip.none,
        decoration: FxDecorationBuilder.build(s),
        child: current,
      );
    } else {
      current = Container(
        width: s.width,
        height: s.height,
        padding: s.padding,
        margin: s.margin,
        alignment: s.alignment,
        clipBehavior: s.clipBehavior ?? Clip.none,
        decoration: FxDecorationBuilder.build(s),
        child: current,
      );
    }

    // Interaction Detection
    final isInteractive =
        widget.onTap != null ||
        s.hover != null ||
        s.pressed != null ||
        s.cursor != null;

    if (isInteractive) {
      current = MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: s.cursor ?? SystemMouseCursors.click,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          child: current,
        ),
      );
    }

    // Apply Flex/Stack wrappers LAST (They must be direct children of Flex/Stack)
    final flexVal = s.flex;
    if (flexVal != null) {
      current = Flexible(
        flex: flexVal,
        fit: s.flexFit ?? FlexFit.tight,
        child: current,
      );
    }

    if (s.top != null ||
        s.right != null ||
        s.bottom != null ||
        s.left != null) {
      current = Positioned(
        top: s.top,
        right: s.right,
        bottom: s.bottom,
        left: s.left,
        child: current,
      );
    }

    return current;
  }

  Widget _buildChildren(FxStyle style, List<Widget> resolvedChildren) {
    return Flex(
      direction: style.direction ?? Axis.vertical,
      mainAxisAlignment: style.justifyContent ?? MainAxisAlignment.start,
      crossAxisAlignment: style.alignItems ?? CrossAxisAlignment.center,
      mainAxisSize: style.mainAxisSize ?? MainAxisSize.max,
      children: [
        if (style.gap != null)
          ..._addGaps(
            resolvedChildren,
            style.gap!,
            style.direction ?? Axis.vertical,
          )
        else
          ...resolvedChildren,
      ],
    );
  }

  List<Widget> _addGaps(List<Widget> items, double gap, Axis direction) {
    if (items.isEmpty) return [];
    final List<Widget> spaced = [];
    for (var i = 0; i < items.length; i++) {
      spaced.add(items[i]);
      if (i < items.length - 1) {
        spaced.add(
          SizedBox(
            height: direction == Axis.vertical ? gap : 0,
            width: direction == Axis.horizontal ? gap : 0,
          ),
        );
      }
    }
    return spaced;
  }
}
