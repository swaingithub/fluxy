import 'package:flutter/widgets.dart';
import '../styles/style.dart';
import '../engine/style_resolver.dart';
import '../engine/decoration_builder.dart';
import '../reactive/signal.dart';

class TextBox extends StatefulWidget {
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
  State<TextBox> createState() => _TextBoxState();
}

class _TextBoxState extends State<TextBox> implements FluxySubscriber {
  @override
  void notify() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    FluxyReactiveContext.push(this);
    
    try {
      final s = StyleResolver.resolve(
        context, 
        style: widget.style, 
        className: widget.className,
        responsive: widget.responsive
      );

      Widget current = Text(
        widget.data,
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
    } finally {
      FluxyReactiveContext.pop();
    }
  }
}
