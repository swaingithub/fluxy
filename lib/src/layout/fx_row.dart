import 'package:flutter/widgets.dart';
import '../styles/style.dart';
import '../engine/style_resolver.dart';
import '../engine/decoration_builder.dart';

class FxRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment justify;
  final CrossAxisAlignment items;
  final double gap;
  final FxStyle style;
  final MainAxisSize size;

  const FxRow({
    super.key,
    required this.children,
    this.justify = MainAxisAlignment.start,
    this.items = CrossAxisAlignment.center,
    this.gap = 0,
    this.style = FxStyle.none,
    this.size = MainAxisSize.max,
  });

  @override
  Widget build(BuildContext context) {
    final s = FxStyleResolver.resolve(context, style: style);
    
    Widget content;
    if (gap > 0) {
      final List<Widget> spacedChildren = [];
      for (var i = 0; i < children.length; i++) {
        spacedChildren.add(children[i]);
        if (i < children.length - 1) {
          spacedChildren.add(SizedBox(width: gap));
        }
      }
      content = Row(
        mainAxisAlignment: justify,
        crossAxisAlignment: items,
        mainAxisSize: size,
        children: spacedChildren,
      );
    } else {
      content = Row(
        mainAxisAlignment: justify,
        crossAxisAlignment: items,
        mainAxisSize: size,
        children: children,
      );
    }

    if (FxDecorationBuilder.hasVisuals(s) || s.width != null || s.height != null || s.margin != EdgeInsets.zero || s.padding != EdgeInsets.zero) {
      content = Container(
        width: s.width,
        height: s.height,
        margin: s.margin,
        padding: s.padding,
        decoration: FxDecorationBuilder.build(s),
        child: content,
      );
    }

    if (s.flex != null) {
      content = Expanded(flex: s.flex!, child: content);
    }

    return content;
  }
}
