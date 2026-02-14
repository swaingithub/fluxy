import 'package:flutter/widgets.dart';
import '../styles/style.dart';
import '../engine/style_resolver.dart';
import '../engine/decoration_builder.dart';

class FxStack extends StatelessWidget {
  final List<Widget> children;
  final AlignmentGeometry alignment;
  final FxStyle style;
  final StackFit fit;

  const FxStack({
    super.key,
    required this.children,
    this.alignment = AlignmentDirectional.topStart,
    this.style = FxStyle.none,
    this.fit = StackFit.loose,
  });

  @override
  Widget build(BuildContext context) {
    final s = FxStyleResolver.resolve(context, style: style);
    
    Widget content = Stack(
      alignment: alignment,
      fit: fit,
      children: children,
    );

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
