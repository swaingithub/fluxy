import 'package:flutter/material.dart';
import '../reactive/forms.dart';
import '../dsl/fx.dart';

/// A wrapper for handling form state, validation, and submission.
class FxForm extends StatelessWidget {
  final FluxForm? form;
  final Widget child;
  final VoidCallback? onSubmit;
  final bool autoValidate;
  final bool closeKeyboardOnTap;

  const FxForm({
    super.key,
    required this.child,
    this.form,
    this.onSubmit,
    this.autoValidate = true,
    this.closeKeyboardOnTap = true,
  });

  void _handleSubmit(BuildContext context) {
    // Dismiss keyboard
    if (closeKeyboardOnTap) {
      FocusScope.of(context).unfocus();
    }

    if (form != null) {
      final isValid = form!.validate();
      if (isValid) {
        onSubmit?.call();
      } else {
        // Form will auto-update UI due to reactivity
      }
    } else {
      // Just call submit if no validation logic provided directly
      onSubmit?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: closeKeyboardOnTap ? () => FocusScope.of(context).unfocus() : null,
      behavior: HitTestBehavior.translucent, // Ensure touches are caught
      child: Fx(() {
        // Rebuild form container if needed, though usually children listen to signals themselves.
        // This Fx wrapper ensures if we add form-level loading/error states later, it works.
        return _FormScope(
          form: form,
          onSubmit: () => _handleSubmit(context),
          child: child,
        );
      }),
    );
  }
}

class _FormScope extends InheritedWidget {
  final FluxForm? form;
  final VoidCallback onSubmit;

  const _FormScope({
    required this.form,
    required this.onSubmit,
    required super.child,
  });

  @override
  bool updateShouldNotify(_FormScope oldWidget) => form != oldWidget.form;
}
