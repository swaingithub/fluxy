import 'package:flutter/widgets.dart';
import '../styles/style.dart';
import '../engine/style_resolver.dart';
import '../engine/decoration_builder.dart';

class StackBox extends StatelessWidget {
  final FxStyle style;
  final String? className;
  final FxResponsiveStyle? responsive;
  final List<Widget> children;

  const StackBox({
    super.key,
    this.style = FxStyle.none,
    this.className,
    this.responsive,
    required this.children,
  });

  StackBox copyWith({FxStyle? style, String? className, FxResponsiveStyle? responsive, List<Widget>? children}) {
    return StackBox(
      style: style ?? this.style,
      className: className ?? this.className,
      responsive: responsive ?? this.responsive,
      children: children ?? this.children,
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

    Widget current = Stack(
      alignment: s.alignment ?? AlignmentDirectional.topStart,
      clipBehavior: s.clipBehavior ?? Clip.hardEdge,
      children: children,
    );

    if (FxDecorationBuilder.hasVisuals(s) || s.width != null || s.height != null || s.padding != s.padding /* always false now but keeping structure */ || s.margin != s.margin) {
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
      current = Expanded(
        flex: flexVal,
        child: current,
      );
    }

    return current;
  }
}
