import 'package:flutter/widgets.dart';
import '../styles/style.dart';
import '../engine/style_resolver.dart';
import '../engine/decoration_builder.dart';
import '../engine/layout_guard.dart';

class FxRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment justify;
  final CrossAxisAlignment items;
  final double gap;
  final FxStyle style;
  final MainAxisSize size;
  final bool responsive;

  const FxRow({
    super.key,
    required this.children,
    MainAxisAlignment justify = MainAxisAlignment.start,
    CrossAxisAlignment items = CrossAxisAlignment.center,
    MainAxisAlignment? mainAxisAlignment,
    CrossAxisAlignment? crossAxisAlignment,
    this.gap = 0,
    this.style = FxStyle.none,
    this.size = MainAxisSize.min,
    this.responsive = false,
  })  : justify = mainAxisAlignment ?? justify,
        items = crossAxisAlignment ?? items;

  @override
  Widget build(BuildContext context) {
    final s = FxStyleResolver.resolve(context, style: style);
    final resolvedItems = FluxyLayoutGuard.guardCrossAxis(context, Axis.horizontal, items);
    
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 600; // Standard fluxy mobile breakpoint
    final useColumn = responsive && isMobile;

    Widget content;
    final List<Widget> spacedChildren = [];
    if (gap > 0) {
      for (var i = 0; i < children.length; i++) {
        spacedChildren.add(children[i]);
        if (i < children.length - 1) {
          spacedChildren.add(
            useColumn ? SizedBox(height: gap) : SizedBox(width: gap),
          );
        }
      }
    }

    final resolvedSize = FluxyLayoutGuard.guardMainAxisSize(
      context, 
      useColumn ? Axis.vertical : Axis.horizontal, 
      justify, 
      size
    );

    if (useColumn) {
      content = FxFlexInfo(
        direction: Axis.vertical,
        child: Column(
          mainAxisAlignment: justify,
          crossAxisAlignment: resolvedItems,
          mainAxisSize: resolvedSize,
          children: gap > 0 ? spacedChildren : children,
        ),
      );
    } else {
      content = FxFlexInfo(
        direction: Axis.horizontal,
        child: Row(
          mainAxisAlignment: justify,
          crossAxisAlignment: resolvedItems,
          mainAxisSize: resolvedSize,
          children: gap > 0 ? spacedChildren : children,
        ),
      );
    }

    if (FxDecorationBuilder.hasVisuals(s) ||
        s.width != null ||
        s.height != null ||
        s.margin != EdgeInsets.zero ||
        s.padding != EdgeInsets.zero) {
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
      content = FxSafeExpansion(
        flex: s.flex!,
        direction: useColumn ? Axis.vertical : Axis.horizontal,
        fit: FlexFit.tight,
        child: content,
      );
    }

    return content;
  }
}
