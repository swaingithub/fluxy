import 'signal.dart';

typedef Validator = String? Function(String value);

/// A signal specifically for form fields with validation support.
class FormFieldSignal<T> extends Signal<T> {
  final List<String? Function(T)> _validators = [];
  final Signal<String?> _error = flux(null);

  FormFieldSignal(super.initialValue);

  String? get error => _error.value;
  bool get hasError => _error.value != null;
  bool get isValid => validate() == null;

  String? validate() {
    for (final validator in _validators) {
      final res = validator(value);
      if (res != null) {
        _error.value = res;
        return res;
      }
    }
    _error.value = null;
    return null;
  }

  void addValidator(String? Function(T) validator) {
    _validators.add(validator);
  }

  void clearError() => _error.value = null;
}

/// A reactive form that aggregates multiple signals and manages validation.
class FluxForm {
  final Map<String, FormFieldSignal> fields;

  FluxForm(this.fields);

  bool get isValid => fields.values.every((f) => f.isValid);
  
  Map<String, String?> get errors => {
    for (final entry in fields.entries)
      if (entry.value.hasError) entry.key: entry.value.error
  };

  bool validate() {
    bool allValid = true;
    for (final field in fields.values) {
      if (field.validate() != null) {
        allValid = false;
      }
    }
    return allValid;
  }

  void reset() {
    for (final field in fields.values) {
      field.clearError();
    }
  }
}

/// Extension to add common validators to String signals.
extension StringValidators on Signal<String> {
  FormFieldSignal<String> _asField() {
    if (this is FormFieldSignal<String>) return this as FormFieldSignal<String>;
    return FormFieldSignal<String>(value);
  }

  FormFieldSignal<String> required([String message = "This field is required"]) {
    return _asField()..addValidator((v) => v.isEmpty ? message : null);
  }

  FormFieldSignal<String> email([String message = "Invalid email address"]) {
    return _asField()..addValidator((v) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      return !emailRegex.hasMatch(v) ? message : null;
    });
  }

  FormFieldSignal<String> min(int length, [String? message]) {
    return _asField()..addValidator((v) => v.length < length ? (message ?? "Minimum $length characters required") : null);
  }

  FormFieldSignal<String> max(int length, [String? message]) {
    return _asField()..addValidator((v) => v.length > length ? (message ?? "Maximum $length characters allowed") : null);
  }
}

/// Helper to create reactive form signals.
FormFieldSignal<T> fluxField<T>(T initialValue) => FormFieldSignal<T>(initialValue);

/// Creates a new reactive form.
FluxForm fluxForm(Map<String, FormFieldSignal> fields) => FluxForm(fields);
