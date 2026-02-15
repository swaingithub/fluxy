import 'package:flutter/widgets.dart';
import '../styles/style.dart';
import '../engine/style_resolver.dart';
import '../engine/decoration_builder.dart';

import 'fx_widget.dart';

class FlexBox extends FxWidget {
  final Axis direction;
  final FxStyle style;
  final FxResponsiveStyle? responsive;
  final List<Widget> children;
  final VoidCallback? onTap;

  const FlexBox({
    super.key,
    super.id,
    super.className,
    required this.direction,
    this.style = FxStyle.none,
    this.responsive,
    required this.children,
    this.onTap,
  });

  @override
  FlexBox copyWithStyle(FxStyle additionalStyle) {
    return copyWith(style: style.merge(additionalStyle));
  }

  @override
  FlexBox copyWithResponsive(FxResponsiveStyle additionalResponsive) {
    return copyWith(
      responsive: responsive?.merge(additionalResponsive) ?? additionalResponsive,
    );
  }

  FlexBox copyWith({
    FxStyle? style,
    Axis? direction,
    String? className,
    FxResponsiveStyle? responsive,
    List<Widget>? children,
    VoidCallback? onTap,
  }) {
    return FlexBox(
      key: key,
      id: id ?? this.id,
      className: className ?? this.className,
      direction: direction ?? this.direction,
      style: style ?? this.style,
      responsive: responsive ?? this.responsive,
      children: children ?? this.children,
      onTap: onTap ?? this.onTap,
    );
  }

  @override
  State<FlexBox> createState() => _FlexBoxState();
}

class _FlexBoxState extends State<FlexBox> {
  @override
  Widget build(BuildContext context) {
    final s = FxStyleResolver.resolve(
      context,
      style: widget.style,
      className: widget.className,
      responsive: widget.responsive,
    );

    final actualDirection = s.direction ?? widget.direction;

    Widget current = Flex(
      direction: actualDirection,
      mainAxisAlignment: s.justifyContent ?? MainAxisAlignment.start,
      crossAxisAlignment: s.alignItems ?? CrossAxisAlignment.center,
      mainAxisSize: s.mainAxisSize ?? MainAxisSize.max,
      children: s.gap != null
          ? _addGaps(widget.children, s.gap!, actualDirection)
          : widget.children,
    );

    // Apply container styles if any (Width, Height, Padding, Decoration)
    if (FxDecorationBuilder.hasVisuals(s) ||
        s.width != null ||
        s.height != null ||
        s.padding != EdgeInsets.zero ||
        s.margin != EdgeInsets.zero) {
      current = Container(
        width: s.width,
        height: s.height,
        padding: s.padding,
        margin: s.margin,
        decoration: FxDecorationBuilder.build(s),
        child: current,
      );
    }

    return widget.onTap != null
        ? GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            child: current,
          )
        : current;
  }

  List<Widget> _addGaps(List<Widget> items, double gap, Axis dir) {
    if (items.isEmpty) return [];
    final List<Widget> spaced = [];
    for (var i = 0; i < items.length; i++) {
      spaced.add(items[i]);
      if (i < items.length - 1) {
        spaced.add(
          SizedBox(
            width: dir == Axis.horizontal ? gap : 0,
            height: dir == Axis.vertical ? gap : 0,
          ),
        );
      }
    }
    return spaced;
  }
}
