import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../reactive/signal.dart';
import '../dsl/fx.dart';
import '../reactive/forms.dart';

/// Reactive TextField that binds directly to a Signal<String>.
class FxTextField extends StatefulWidget {
  final Signal<String> signal;
  final String? placeholder;
  final InputDecoration? decoration;
  final TextStyle? style;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final VoidCallback? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final List<Validator<String>>? validators;

  const FxTextField({
    super.key,
    required this.signal,
    this.placeholder,
    this.decoration,
    this.style,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.onSubmitted,
    this.inputFormatters,
    this.focusNode,
    this.validators,
  });

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
        hintText: widget.placeholder,
        border: const OutlineInputBorder(),
        errorText: errorText,
      );

      return TextField(
        controller: _controller,
        obscureText: widget.obscureText,
        style: widget.style,
        keyboardType: widget.keyboardType,
        maxLines: widget.maxLines,
        inputFormatters: widget.inputFormatters,
        focusNode: widget.focusNode,
        decoration:
            widget.decoration?.copyWith(errorText: errorText) ??
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
