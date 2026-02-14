import 'package:flutter/widgets.dart';
import '../reactive/forms.dart';
import 'fx.dart';

/// Extension to add UI capabilities to FluxForm controller.
extension FluxFormUIExtension on FluxForm {
  /// Binds a field to an Fx.input widget.
  Widget input(String key, {
    String? label,
    String? placeholder,
    bool isPassword = false,
    IconData? icon,
    TextInputType? keyboardType,
  }) {
    final field = this.field<String>(key);
    return Fx.input(
      signal: field,
      label: label,
      placeholder: placeholder,
      obscureText: isPassword,
      icon: icon,
      keyboardType: keyboardType,
    );
  }
}
