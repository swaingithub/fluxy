import 'dart:ui';
import 'package:flutter/widgets.dart';
import '../styles/style.dart';
import '../engine/style_resolver.dart';
import '../engine/decoration_builder.dart';

import '../engine/diff_engine.dart';

/// The foundational building block of Fluxy.
/// Similar to a <div> in web development.
class Box extends StatefulWidget {
  final String? id; // Optional ID for caching
  final Style? style;
  final String? className;
  final ResponsiveStyle? responsive;
  final Widget? child;
  final List<Widget>? children;
  final VoidCallback? onTap;

  const Box({
    super.key,
    this.id,
    this.style,
    this.className,
    this.responsive,
    this.child,
    this.children,
    this.onTap,
  });

  @override
  State<Box> createState() => _BoxState();
}

class _BoxState extends State<Box> {
  bool _isHovered = false;
  bool _isPressed = false;
  
  // Cache the resolved style and built widget
  Style? _lastResolvedBase;
  Widget? _cachedWidget;
  
  @override
  Widget build(BuildContext context) {
    // 1. Resolve base style
    final base = StyleResolver.resolve(
      context, 
      style: widget.style, 
      className: widget.className,
      responsive: widget.responsive
    );

    // 2. Diff detection: Skip building if nothing changed
    final shouldRebuild = _cachedWidget == null || 
                         DiffEngine.shouldRebuild(
                           oldStyle: _lastResolvedBase, 
                           newStyle: base,
                           oldClassName: null, // StyleResolver already incorporates className
                           newClassName: null,
                           structuralChange: DiffEngine.hasTreeChanged(
                             widget.children ?? [], 
                             [] // Comparison logic would go here
                           ),
                         );

    _lastResolvedBase = base;

    // 3. Resolve interactive states (always applied)
    final s = StyleResolver.resolveInteractive(base, isHovered: _isHovered, isPressed: _isPressed);

    if (shouldRebuild || _isHovered || _isPressed) {
      _cachedWidget = _buildContent(s);
    }

    return _cachedWidget!;
  }

  Widget _buildContent(Style s) {
    Widget current = widget.child ?? (widget.children != null ? _buildChildren(s) : const SizedBox.shrink());

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

    // Apply Visuals using DecorationBuilder
    if (s.transition != null) {
      current = AnimatedContainer(
        duration: s.transition!,
        width: s.width,
        height: s.height,
        padding: s.padding,
        margin: s.margin,
        alignment: s.alignment,
        clipBehavior: s.clipBehavior ?? Clip.none,
        decoration: DecorationBuilder.build(s),
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
        decoration: DecorationBuilder.build(s),
        child: current,
      );
    }

    // 5. Wrap with Interaction Handlers
    current = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: (widget.onTap != null || s.hover != null) ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: current,
      ),
    );

    // 6. Apply Flex/Stack wrappers LAST (They must be direct children of Flex/Stack)
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

  Widget _buildChildren(Style style) {
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
