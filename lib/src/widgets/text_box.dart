import 'package:flutter/widgets.dart';
import '../styles/style.dart';
import '../engine/style_resolver.dart';
import '../engine/decoration_builder.dart';

class TextBox extends StatelessWidget {
  final String data;
  final Style? style;
  final String? className;
  final ResponsiveStyle? responsive;

  const TextBox({
    super.key,
    required this.data,
    this.style,
    this.className,
    this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    final s = StyleResolver.resolve(
      context, 
      style: style, 
      className: className,
      responsive: responsive
    );

    Widget current = Text(
      data,
      textAlign: s.textAlign,
      overflow: s.overflow,
      maxLines: s.maxLines,
      style: DecorationBuilder.textStyle(s),
    );

    if (DecorationBuilder.hasVisuals(s) || s.width != null || s.height != null || s.padding != null || s.margin != null) {
      current = Container(
        width: s.width,
        height: s.height,
        padding: s.padding,
        margin: s.margin,
        alignment: s.alignment,
        decoration: DecorationBuilder.build(s),
        child: current,
      );
    }

    if (s.flex != null) {
      current = Flexible(
        flex: s.flex!,
        fit: s.flexFit ?? FlexFit.tight,
        child: current,
      );
    }

    return current;
  }
}
