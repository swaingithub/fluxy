import 'package:flutter/widgets.dart';
import '../styles/style.dart';
import '../engine/style_resolver.dart';
import '../engine/decoration_builder.dart';
import '../reactive/signal.dart';

class TextBox extends StatefulWidget {
  final dynamic data;
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

  TextBox copyWith({
    FxStyle? style,
    dynamic data,
    String? className,
    FxResponsiveStyle? responsive,
  }) {
    return TextBox(
      data: data ?? this.data,
      style: style ?? this.style,
      className: className ?? this.className,
      responsive: responsive ?? this.responsive,
    );
  }

  @override
  State<TextBox> createState() => _TextBoxState();
}

class _TextBoxState extends State<TextBox> with ReactiveSubscriberMixin {
  @override
  void notify() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    clearDependencies();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FluxyReactiveContext.push(this);

    try {
      final s = FxStyleResolver.resolve(
        context,
        style: widget.style,
        className: widget.className,
        responsive: widget.responsive,
      );

      final String displayData = widget.data is Function
          ? widget.data().toString()
          : widget.data.toString();

      Widget current = Text(
        displayData,
        textAlign: s.textAlign,
        overflow: s.overflow,
        maxLines: s.maxLines,
        style: FxDecorationBuilder.textStyle(s),
      );

      if (FxDecorationBuilder.hasVisuals(s) ||
          s.width != null ||
          s.height != null ||
          s.padding != s.padding /* always false now but keeping structure */ ||
          s.margin != s.margin) {
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

      final flexVal = s.flex;
      if (flexVal != null) {
        current = Flexible(
          flex: flexVal,
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
