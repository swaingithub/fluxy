import 'package:flutter/widgets.dart';
import '../styles/style.dart';
import '../engine/style_resolver.dart';
import '../engine/decoration_builder.dart';

import '../widgets/fx_widget.dart';

class StackBox extends FxWidget {
  final FxStyle style;
  final FxResponsiveStyle? responsive;
  final List<Widget> children;
  final VoidCallback? onTap;

  const StackBox({
    super.key,
    super.id,
    super.className,
    this.style = FxStyle.none,
    this.responsive,
    required this.children,
    this.onTap,
  });

  @override
  StackBox copyWithStyle(FxStyle additionalStyle) {
    return copyWith(style: style.merge(additionalStyle));
  }

  @override
  StackBox copyWithResponsive(FxResponsiveStyle additionalResponsive) {
    return copyWith(
      responsive: responsive?.merge(additionalResponsive) ?? additionalResponsive,
    );
  }

  StackBox copyWith({
    FxStyle? style,
    String? className,
    FxResponsiveStyle? responsive,
    List<Widget>? children,
    VoidCallback? onTap,
  }) {
    return StackBox(
      key: key,
      id: id,
      className: className ?? this.className,
      style: style ?? this.style,
      responsive: responsive ?? this.responsive,
      children: children ?? this.children,
      onTap: onTap ?? this.onTap,
    );
  }

  @override
  State<StackBox> createState() => _StackBoxState();
}

class _StackBoxState extends State<StackBox> {
  @override
  Widget build(BuildContext context) {
    final s = FxStyleResolver.resolve(
      context,
      style: widget.style,
      className: widget.className,
      responsive: widget.responsive,
    );

    Widget current = Stack(
      alignment: s.alignment ?? AlignmentDirectional.topStart,
      clipBehavior: s.clipBehavior ?? Clip.hardEdge,
      children: widget.children,
    );

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

    final flexVal = s.flex;
    if (flexVal != null) {
      current = Expanded(flex: flexVal, child: current);
    }

    return widget.onTap != null
        ? GestureDetector(onTap: widget.onTap, child: current)
        : current;
  }
}
