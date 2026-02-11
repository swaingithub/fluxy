import 'package:flutter/widgets.dart';
import '../styles/style.dart';
import '../engine/style_resolver.dart';
import '../engine/decoration_builder.dart';

class StackBox extends StatelessWidget {
  final Style? style;
  final String? className;
  final ResponsiveStyle? responsive;
  final List<Widget> children;

  const StackBox({
    super.key,
    this.style,
    this.className,
    this.responsive,
    required this.children,
  });

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
