import 'signal.dart';

typedef Validator<T> = String? Function(T value);

/// A reactive form field with validation capabilities.
class FluxField<T> extends Signal<T> {
  final List<Validator<T>> _validators = [];
  final Signal<String?> _error = flux(null);
  final Signal<bool> _isDirty = flux(false);
  final Signal<bool> _isTouched = flux(false);

  FluxField(super.initialValue);

  // Status Getters
  String? get error => _error.value;
  bool get hasError => _error.value != null;
  bool get isValid => validate() == null;
  bool get isDirty => _isDirty.value;
  bool get isTouched => _isTouched.value;

  /// Validates the field against all rules.
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

  /// Adds a validator rule.
  FluxField<T> addRule(Validator<T> validator) {
    _validators.add(validator);
    return this;
  }

  /// Resets the field state (error, dirty, touched).
  void reset([T? newValue]) {
    if (newValue != null) value = newValue;
    _error.value = null;
    _isDirty.value = false;
    _isTouched.value = false;
  }

  /// Marks field as touched.
  void touch() => _isTouched.value = true;

  /// Marks field as dirty.
  void markDirty() => _isDirty.value = true;

  @override
  set value(T newValue) {
    if (super.value != newValue) {
      super.value = newValue;
      _isDirty.value = true;
      if (_isTouched.value) validate();
    }
  }
}

/// A reactive form container.
class FluxForm {
  final Map<String, FluxField> fields;

  FluxForm(this.fields);

  /// Gets a field by key.
  FluxField<T> field<T>(String key) => fields[key] as FluxField<T>;

  /// Access field via bracket operator.
  FluxField operator [](String key) => fields[key]!;

  /// Checks if entire form is valid.
  bool get isValid => fields.values.every((f) => f.isValid);

  /// Checks if any field is dirty.
  bool get isDirty => fields.values.any((f) => f.isDirty);

  /// validates all fields.
  bool validate() {
    bool allValid = true;
    for (final field in fields.values) {
      field.touch();
      if (field.validate() != null) {
        allValid = false;
      }
    }
    return allValid;
  }

  /// Resets all fields.
  void reset() {
    for (final field in fields.values) {
      field.reset();
    }
  }

  /// Gets all current errors.
  Map<String, String> get errors {
    final Map<String, String> errs = {};
    for (final entry in fields.entries) {
      if (entry.value.hasError) {
        errs[entry.key] = entry.value.error!;
      }
    }
    return errs;
  }
}

/// Fluent validation rules for String fields.
extension StringFieldExtensions on FluxField<String> {
  FluxField<String> required([String message = "Required"]) {
    return addRule((v) => v.trim().isEmpty ? message : null);
  }

  FluxField<String> email([String message = "Invalid email"]) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return addRule(
      (v) => v.isNotEmpty && !emailRegex.hasMatch(v) ? message : null,
    );
  }

  FluxField<String> minLength(int length, [String? message]) {
    return addRule(
      (v) => v.length < length ? (message ?? "Min $length chars") : null,
    );
  }

  FluxField<String> maxLength(int length, [String? message]) {
    return addRule(
      (v) => v.length > length ? (message ?? "Max $length chars") : null,
    );
  }

  FluxField<String> match(String pattern, [String message = "Format invalid"]) {
    return addRule((v) => !RegExp(pattern).hasMatch(v) ? message : null);
  }
}

/// Helper to create a specialized field.
FluxField<T> fluxField<T>(T initialValue) => FluxField<T>(initialValue);

/// Helper to create a form.
FluxForm fluxForm(Map<String, FluxField> fields) => FluxForm(fields);
