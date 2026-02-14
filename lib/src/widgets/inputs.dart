import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../reactive/signal.dart';
import '../dsl/fx.dart';
import '../reactive/forms.dart';

import '../widgets/fx_widget.dart';

/// Reactive TextField that binds directly to a Signal<String>.
class FxTextField extends FxWidget {
  final Signal<String> signal;
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
    Signal<String>? signal,
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
  Effect? _subscription;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.signal.value);

    // Efficiently bind signal updates to controller
    _subscription = effect(() {
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
      String? errorText;

      // Auto-validation integration
      if (widget.signal is FluxField<String>) {
        final field = widget.signal as FluxField<String>;
        // Show error only if field is touched or dirty
        if (field.isTouched || field.isDirty) {
          errorText = field.error;
        }
      }

      final defaultDecoration = InputDecoration(
        labelText: widget.label,
        hintText: widget.placeholder,
        prefixIcon: widget.icon != null ? Icon(widget.icon) : null,
        border: const OutlineInputBorder(),
        errorText: errorText,
      );

      return TextField(
        controller: _controller,
        obscureText: widget.obscureText,
        style: widget.textStyle,
        keyboardType: widget.keyboardType,
        maxLines: widget.maxLines,
        inputFormatters: widget.inputFormatters,
        focusNode: widget.focusNode,
        decoration:
            widget.decoration?.copyWith(
              labelText: widget.label,
              prefixIcon: widget.icon != null ? Icon(widget.icon) : null,
              errorText: errorText,
            ) ??
            defaultDecoration,
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
      );
    });
  }
}
// ... FxCheckbox and FxSlider omitted for brevity if unchanged, but file overwrite means I must include them.
// I will include them to keep the file valid.

/// Reactive Checkbox that binds directly to a Signal<bool>.
class FxCheckbox extends StatelessWidget {
  final Signal<bool> signal;
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

/// Reactive Slider that binds directly to a Signal<double>.
class FxSlider extends StatelessWidget {
  final Signal<double> signal;
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
