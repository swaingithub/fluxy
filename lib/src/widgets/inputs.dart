import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../reactive/signal.dart';
import '../dsl/fx.dart';
import '../reactive/forms.dart';
import '../engine/style_resolver.dart';

import '../widgets/fx_widget.dart';
import 'box.dart';

/// Reactive TextField that binds directly to a Flux/Signal.
class FxTextField extends FxWidget {
  final Flux<String> signal;
  final String? placeholder;
  final String? label;
  final IconData? icon;
  final FxStyle style;
  final FxResponsiveStyle? responsive;
  final InputDecoration? decoration;
  final TextStyle? textStyle;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final VoidCallback? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final List<Validator<String>>? validators;

  const FxTextField({
    super.key,
    super.id,
    super.className,
    required this.signal,
    this.placeholder,
    this.label,
    this.icon,
    this.style = FxStyle.none,
    this.responsive,
    this.decoration,
    this.textStyle,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.onSubmitted,
    this.inputFormatters,
    this.focusNode,
    this.validators,
  });

  @override
  FxTextField copyWithStyle(FxStyle additionalStyle) {
    return copyWith(style: style.merge(additionalStyle));
  }

  @override
  FxTextField copyWithResponsive(FxResponsiveStyle additionalResponsive) {
    return copyWith(
      responsive: responsive?.merge(additionalResponsive) ?? additionalResponsive,
    );
  }

  FxTextField copyWith({
    Flux<String>? signal,
    String? placeholder,
    String? label,
    IconData? icon,
    FxStyle? style,
    FxResponsiveStyle? responsive,
    InputDecoration? decoration,
    TextStyle? textStyle,
    bool? obscureText,
    TextInputType? keyboardType,
    int? maxLines,
    VoidCallback? onSubmitted,
    List<TextInputFormatter>? inputFormatters,
    FocusNode? focusNode,
    List<Validator<String>>? validators,
    String? className,
  }) {
    return FxTextField(
      key: key,
      id: id,
      className: className ?? this.className,
      signal: signal ?? this.signal,
      placeholder: placeholder ?? this.placeholder,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      style: style ?? this.style,
      responsive: responsive ?? this.responsive,
      decoration: decoration ?? this.decoration,
      textStyle: textStyle ?? this.textStyle,
      obscureText: obscureText ?? this.obscureText,
      keyboardType: keyboardType ?? this.keyboardType,
      maxLines: maxLines ?? this.maxLines,
      onSubmitted: onSubmitted ?? this.onSubmitted,
      inputFormatters: inputFormatters ?? this.inputFormatters,
      focusNode: focusNode ?? this.focusNode,
      validators: validators ?? this.validators,
    );
  }

  @override
  State<FxTextField> createState() => _FxTextFieldState();
}

class _FxTextFieldState extends State<FxTextField> {
  late TextEditingController _controller;
  FluxEffect? _subscription;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.signal.value);

    // Efficiently bind flux updates to controller
    _subscription = fluxEffect(() {
      final newVal = widget.signal.value;
      if (_controller.text != newVal) {
        _controller.value = _controller.value.copyWith(
          text: newVal,
          selection: TextSelection.collapsed(offset: newVal.length),
          composing: TextRange.empty,
        );
      }
    });

    _controller.addListener(_onChanged);

    // Register validators (Run once on init)
    if (widget.validators != null && widget.signal is FluxField<String>) {
      final field = widget.signal as FluxField<String>;
      for (final v in widget.validators!) {
        field.addRule(v);
      }
    }
  }

  void _onChanged() {
    final val = _controller.text;
    if (widget.signal.value != val) {
      widget.signal.value = val;
    }
  }

  @override
  void dispose() {
    _subscription?.dispose();
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Reactive build wrapper to listen for validation state
    return Fx(() {
      final resolvedStyle = FxStyleResolver.resolve(context,
          style: widget.style, className: widget.className);

      String? errorText;

      // Auto-validation integration
      if (widget.signal is FluxField<String>) {
        final field = widget.signal as FluxField<String>;
        // Show error only if field is touched or dirty
        if (field.isTouched || field.isDirty) {
          errorText = field.error;
        }
      }

      // 1. Separate Structural Styles vs Text Styles
      // We interpret FxStyle on FxTextField as styling the CONTAINER (Box),
      // except for text-specific props like color/fontSize which go to the text.
      final structuralStyle = resolvedStyle; 
      
      // 2. Build Decoration
      // If the user provides a style with border/bg, we let Box handle it.
      // We set InputDecoration to minimal to avoid double borders,
      // UNLESS the user explicitly didn't style the box, then we might want default Flutter look?
      // But Fluxy philosophy is "Box is the shell".
      // So we default to InputBorder.none and let Box handle the look.
      
      final inputDecoration = (widget.decoration ?? const InputDecoration()).copyWith(
        labelText: widget.label,
        hintText: widget.placeholder,
        prefixIcon: widget.icon != null ? Icon(widget.icon) : null,
        errorText: errorText,
        // Allow user to override borders if they explicitly pass a decoration with borders
        border: widget.decoration?.border ?? InputBorder.none,
        enabledBorder: widget.decoration?.enabledBorder ?? InputBorder.none,
        focusedBorder: widget.decoration?.focusedBorder ?? InputBorder.none,
        errorBorder: widget.decoration?.errorBorder ?? InputBorder.none,
        focusedErrorBorder: widget.decoration?.focusedErrorBorder ?? InputBorder.none,
        filled: widget.decoration?.filled ?? false,
        contentPadding: resolvedStyle.padding == EdgeInsets.zero 
            ? const EdgeInsets.symmetric(horizontal: 12, vertical: 12)
            : resolvedStyle.padding,
      );

      return Box(
        style: structuralStyle.copyWith(
          // We moved padding to contentPadding for better alignment, 
          // so remove it from Box to avoid double padding.
          padding: EdgeInsets.zero, 
          width: structuralStyle.width ?? (structuralStyle.flex != null ? null : double.infinity), // Default to full width if not flex
        ),
        child: TextField(
          controller: _controller,
          obscureText: widget.obscureText,
          style: TextStyle(
            color: resolvedStyle.color,
            fontSize: resolvedStyle.fontSize,
            fontWeight: resolvedStyle.fontWeight,
            fontFamily: resolvedStyle.fontFamily,
          ),
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          inputFormatters: widget.inputFormatters,
          focusNode: widget.focusNode,
          decoration: inputDecoration,
          onSubmitted: (_) {
            if (widget.signal is FluxField) {
              (widget.signal as FluxField).touch();
            }
            widget.onSubmitted?.call();
          },
          onTapOutside: (_) {
            if (widget.signal is FluxField) {
              (widget.signal as FluxField).touch();
            }
            FocusScope.of(context).unfocus();
          },
        ),
      );
    });
  }
}

/// Reactive Checkbox that binds directly to a Flux/Signal.
class FxCheckbox extends StatelessWidget {
  final Flux<bool> signal;
  final Color? activeColor;

  const FxCheckbox({super.key, required this.signal, this.activeColor});

  @override
  Widget build(BuildContext context) {
    return Fx(
      () => Checkbox(
        value: signal.value,
        activeColor: activeColor,
        onChanged: (val) => signal.value = val ?? false,
      ),
    );
  }
}

/// Reactive Slider that binds directly to a Flux/Signal.
class FxSlider extends StatelessWidget {
  final Flux<double> signal;
  final double min;
  final double max;
  final int? divisions;
  final Color? activeColor;

  const FxSlider({
    super.key,
    required this.signal,
    this.min = 0,
    this.max = 100,
    this.divisions,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Fx(
      () => Slider(
        value: signal.value,
        min: min,
        max: max,
        divisions: divisions,
        activeColor: activeColor,
        onChanged: (val) => signal.value = val,
      ),
    );
  }
}
