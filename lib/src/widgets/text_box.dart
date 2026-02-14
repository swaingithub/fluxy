import 'package:flutter/widgets.dart';
import '../styles/style.dart';
import '../engine/style_resolver.dart';
import '../engine/decoration_builder.dart';
import '../reactive/signal.dart';

import 'fx_widget.dart';

class TextBox extends FxWidget {
  final dynamic data;
  final FxStyle style;
  final FxResponsiveStyle? responsive;

  const TextBox({
    super.key,
    super.id,
    super.className,
    required this.data,
    this.style = FxStyle.none,
    this.responsive,
  });

  @override
  TextBox copyWithStyle(FxStyle additionalStyle) {
    return copyWith(style: style.merge(additionalStyle));
  }

  @override
  TextBox copyWithResponsive(FxResponsiveStyle additionalResponsive) {
    return copyWith(
      responsive: responsive?.merge(additionalResponsive) ?? additionalResponsive,
    );
  }

  TextBox copyWith({
    FxStyle? style,
    dynamic data,
    String? className,
    FxResponsiveStyle? responsive,
  }) {
    return TextBox(
      key: key,
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
