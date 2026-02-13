import 'package:flutter/widgets.dart';
import '../styles/style.dart';
import '../engine/style_resolver.dart';
import '../engine/decoration_builder.dart';

class FlexBox extends StatelessWidget {
  final Axis direction;
  final FxStyle style;
  final String? className;
  final FxResponsiveStyle? responsive;
  final List<Widget> children;

  const FlexBox({
    super.key,
    required this.direction,
    this.style = FxStyle.none,
    this.className,
    this.responsive,
    required this.children,
    this.onTap,
  });

  final VoidCallback? onTap;

  FlexBox copyWith({FxStyle? style, Axis? direction, String? className, FxResponsiveStyle? responsive, List<Widget>? children, VoidCallback? onTap}) {
    return FlexBox(
      direction: direction ?? this.direction,
      style: style ?? this.style,
      className: className ?? this.className,
      responsive: responsive ?? this.responsive,
      children: children ?? this.children,
      onTap: onTap ?? this.onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = FxStyleResolver.resolve(
      context, 
      style: style, 
      className: className,
      responsive: responsive
    );

    final actualDirection = s.direction ?? direction;

    Widget current = Flex(
      direction: actualDirection,
      mainAxisAlignment: s.justifyContent ?? MainAxisAlignment.start,
      crossAxisAlignment: s.alignItems ?? CrossAxisAlignment.center,
      mainAxisSize: s.mainAxisSize ?? MainAxisSize.max,
      children: s.gap != null ? _addGaps(children, s.gap!, actualDirection) : children,
    );

    // Apply container styles if any (Width, Height, Padding, Decoration)
    if (FxDecorationBuilder.hasVisuals(s) || s.width != null || s.height != null || s.padding != EdgeInsets.zero || s.margin != EdgeInsets.zero) {
      current = Container(
        width: s.width,
        height: s.height,
        padding: s.padding,
        margin: s.margin,
        decoration: FxDecorationBuilder.build(s),
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

    return onTap != null ? GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap, 
      child: current
    ) : current;
  }

  List<Widget> _addGaps(List<Widget> items, double gap, Axis dir) {
    if (items.isEmpty) return [];
    final List<Widget> spaced = [];
    for (var i = 0; i < items.length; i++) {
      spaced.add(items[i]);
      if (i < items.length - 1) {
        spaced.add(SizedBox(
          width: dir == Axis.horizontal ? gap : 0,
          height: dir == Axis.vertical ? gap : 0,
        ));
      }
    }
    return spaced;
  }
}
