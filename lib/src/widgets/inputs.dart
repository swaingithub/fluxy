import 'package:flutter/material.dart';
import '../reactive/signal.dart';
import '../dsl/fx.dart';

/// Reactive TextField that binds directly to a Signal<String>.
class FxTextField extends StatefulWidget {
  final Signal<String> signal;
  final String? placeholder;
  final InputDecoration? decoration;
  final TextStyle? style;
  final bool obscureText;

  const FxTextField({
    super.key,
    required this.signal,
    this.placeholder,
    this.decoration,
    this.style,
    this.obscureText = false,
  });

  @override
  State<FxTextField> createState() => _FxTextFieldState();
}

class _FxTextFieldState extends State<FxTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.signal.value);
    
    // Listen to signal changes from outside (e.g. signal.value = "")
    widget.signal.listen((val) {
      if (_controller.text != val) {
        _controller.text = val;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: (text) => widget.signal.value = text,
      obscureText: widget.obscureText,
      style: widget.style,
      decoration: widget.decoration ?? InputDecoration(
        hintText: widget.placeholder,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

/// Reactive Checkbox that binds directly to a Signal<bool>.
class FxCheckbox extends StatelessWidget {
  final Signal<bool> signal;
  final Color? activeColor;

  const FxCheckbox({
    super.key,
    required this.signal,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Fx(() => Checkbox(
      value: signal.value,
      activeColor: activeColor,
      onChanged: (val) => signal.value = val ?? false,
    ));
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
    return Fx(() => Slider(
      value: signal.value,
      min: min,
      max: max,
      divisions: divisions,
      activeColor: activeColor,
      onChanged: (val) => signal.value = val,
    ));
  }
}
