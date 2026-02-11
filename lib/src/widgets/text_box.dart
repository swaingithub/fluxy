import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show Container, Text, Flexible, FlexFit;
import '../styles/style.dart';
import '../engine/style_resolver.dart';
import '../engine/decoration_builder.dart';
import '../reactive/signal.dart';
import '../dsl/modifiers.dart';

class TextBox extends StatefulWidget with FxModifier<TextBox> {
  final String data;
  @override
  final FxStyle style;
  final String? className;
  final FxResponsiveStyle? responsive;

  const TextBox({
    super.key,
    required this.data,
    this.style = FxStyle.none,
    this.className,
    this.responsive,
  });

  @override
  TextBox copyWith({FxStyle? style, String? data, String? className, FxResponsiveStyle? responsive}) {
    return TextBox(
      data: data ?? this.data,
      style: this.style.copyWith(style),
      className: className ?? this.className,
      responsive: responsive ?? this.responsive,
    );
  }

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
      final s = FxStyleResolver.resolve(
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
        style: FxDecorationBuilder.textStyle(s),
      );

      if (FxDecorationBuilder.hasVisuals(s) || s.width != null || s.height != null || s.padding != null || s.margin != null) {
        current = Container(
          width: s.width,
          height: s.height,
          padding: s.padding,
          margin: s.margin,
          alignment: s.alignment,
          decoration: FxDecorationBuilder.build(s),
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
