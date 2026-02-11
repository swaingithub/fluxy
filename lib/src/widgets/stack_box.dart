import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show Container, Expanded, Stack;
import '../styles/style.dart';
import '../engine/style_resolver.dart';
import '../engine/decoration_builder.dart';
import '../dsl/modifiers.dart';

class StackBox extends StatelessWidget with FxModifier<StackBox> {
  @override
  final Style style;
  final String? className;
  final ResponsiveStyle? responsive;
  final List<Widget> children;

  const StackBox({
    super.key,
    this.style = const Style(),
    this.className,
    this.responsive,
    required this.children,
  });

  @override
  StackBox copyWith({Style? style, String? className, ResponsiveStyle? responsive, List<Widget>? children}) {
    return StackBox(
      style: this.style.copyWith(style),
      className: className ?? this.className,
      responsive: responsive ?? this.responsive,
      children: children ?? this.children,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = StyleResolver.resolve(
      context, 
      style: style, 
      className: className,
      responsive: responsive
    );

    Widget current = Stack(
      alignment: s.alignment ?? AlignmentDirectional.topStart,
      clipBehavior: s.clipBehavior ?? Clip.hardEdge,
      children: children,
    );

    if (DecorationBuilder.hasVisuals(s) || s.width != null || s.height != null || s.padding != null || s.margin != null) {
      current = Container(
        width: s.width,
        height: s.height,
        padding: s.padding,
        margin: s.margin,
        decoration: DecorationBuilder.build(s),
        child: current,
      );
    }

    if (s.flex != null) {
      current = Expanded(
        flex: s.flex!,
        child: current,
      );
    }

    return current;
  }
}
