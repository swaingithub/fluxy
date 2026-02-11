import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show MouseRegion, GestureDetector, Flexible, Positioned, SystemMouseCursors, ClipRRect, BackdropFilter, AnimatedContainer, Container, Flex, SizedBox;
import '../styles/style.dart';
import '../engine/style_resolver.dart';
import '../engine/decoration_builder.dart';
import '../engine/diff_engine.dart';
import '../reactive/signal.dart';
import '../dsl/modifiers.dart';

/// The foundational building block of Fluxy.
/// Similar to a <div> in web development.
class Box extends StatefulWidget with FxModifier<Box> {
  final String? id; 
  @override
  final FxStyle style;
  final String? className;
  final FxResponsiveStyle? responsive;
  final Widget? child;
  final List<Widget>? children;
  final VoidCallback? onTap;

  const Box({
    super.key,
    this.id,
    this.style = FxStyle.none,
    this.className,
    this.responsive,
    this.child,
    this.children,
    this.onTap,
  });

  @override
  Box copyWith({FxStyle? style, String? className, FxResponsiveStyle? responsive, Widget? child, List<Widget>? children, VoidCallback? onTap}) {
    return Box(
      id: id,
      style: this.style.copyWith(style),
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

class _BoxState extends State<Box> implements FluxySubscriber {
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
        responsive: widget.responsive
      );

      final shouldRebuild = _cachedWidget == null || 
                           DiffEngine.shouldRebuild(
                             oldStyle: _lastResolvedBase, 
                             newStyle: base,
                             structuralChange: false,
                           );

      _lastResolvedBase = base;

      final s = FxStyleResolver.resolveInteractive(base, isHovered: _isHovered, isPressed: _isPressed);

      if (shouldRebuild || _isHovered || _isPressed) {
        _cachedWidget = _buildContent(s);
      }

      return _cachedWidget!;
    } finally {
      FluxyReactiveContext.pop();
    }
  }

  Widget _buildContent(FxStyle s) {
    Widget current = widget.child ?? (widget.children != null ? _buildChildren(s) : const SizedBox.shrink());

    // Apply Opacity
    if (s.opacity != null) {
      current = Opacity(opacity: s.opacity!, child: current);
    }

    // Apply Glassmorphism
    if (s.glass != null && s.glass! > 0) {
      current = ClipRRect(
        borderRadius: s.borderRadius ?? BorderRadius.zero,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: s.glass!, sigmaY: s.glass!),
          child: current,
        ),
      );
    }

    // Apply Aspect Ratio
    if (s.aspectRatio != null) {
      current = AspectRatio(aspectRatio: s.aspectRatio!, child: current);
    }

    // Apply Visuals using FxDecorationBuilder
    if (s.transition != null) {
      current = AnimatedContainer(
        duration: s.transition!,
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

    // Wrap with Interaction Handlers
    current = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: s.cursor ?? ((widget.onTap != null || s.hover != null) ? SystemMouseCursors.click : SystemMouseCursors.basic),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: current,
      ),
    );

    // Apply Flex/Stack wrappers LAST (They must be direct children of Flex/Stack)
    if (s.flex != null) {
      current = Flexible(
        flex: s.flex!,
        fit: s.flexFit ?? FlexFit.tight,
        child: current,
      );
    }

    if (s.top != null || s.right != null || s.bottom != null || s.left != null) {
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

  Widget _buildChildren(FxStyle style) {
    return Flex(
      direction: style.direction ?? Axis.vertical,
      mainAxisAlignment: style.justifyContent ?? MainAxisAlignment.start,
      crossAxisAlignment: style.alignItems ?? CrossAxisAlignment.center,
      mainAxisSize: style.mainAxisSize ?? MainAxisSize.max,
      children: [
        if (style.gap != null)
          ..._addGaps(widget.children!, style.gap!, style.direction ?? Axis.vertical)
        else
          ...widget.children!,
      ],
    );
  }

  List<Widget> _addGaps(List<Widget> items, double gap, Axis direction) {
    if (items.isEmpty) return [];
    final List<Widget> spaced = [];
    for (var i = 0; i < items.length; i++) {
      spaced.add(items[i]);
      if (i < items.length - 1) {
        spaced.add(SizedBox(
          height: direction == Axis.vertical ? gap : 0, 
          width: direction == Axis.horizontal ? gap : 0,
        ));
      }
    }
    return spaced;
  }
}
