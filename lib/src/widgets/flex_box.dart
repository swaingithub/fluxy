import 'package:flutter/widgets.dart';
import '../styles/style.dart';
import '../engine/style_resolver.dart';
import '../engine/decoration_builder.dart';

class FlexBox extends StatelessWidget {
  final Axis direction;
  final Style? style;
  final String? className;
  final ResponsiveStyle? responsive;
  final List<Widget> children;

  const FlexBox({
    super.key,
    required this.direction,
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

    Widget current = Flex(
      direction: direction,
      mainAxisAlignment: s.justifyContent ?? MainAxisAlignment.start,
      crossAxisAlignment: s.alignItems ?? CrossAxisAlignment.center,
      mainAxisSize: s.mainAxisSize ?? MainAxisSize.max,
      children: s.gap != null ? _addGaps(children, s.gap!) : children,
    );

    // Apply container styles if any
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

    if (s.flex != null || s.flexGrow != null) {
      current = Flexible(
        flex: s.flexGrow ?? s.flex ?? 1,
        fit: s.flexFit ?? FlexFit.tight,
        child: current,
      );
    }

    return current;
  }

  List<Widget> _addGaps(List<Widget> items, double gap) {
    if (items.isEmpty) return [];
    final List<Widget> spaced = [];
    for (var i = 0; i < items.length; i++) {
      spaced.add(items[i]);
      if (i < items.length - 1) {
        spaced.add(SizedBox(
          width: direction == Axis.horizontal ? gap : 0,
          height: direction == Axis.vertical ? gap : 0,
        ));
      }
    }
    return spaced;
  }
}
