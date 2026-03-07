import 'package:flutter/material.dart';
import '../reactive/signal.dart';

/// Controller for the global Fluxy theme state.
class FxTheme {
  static final Flux<ThemeMode> _mode = flux(
    ThemeMode.system,
    key: 'fx_theme_mode',
    fromJson: (json) {
      if (json == 'dark') return ThemeMode.dark;
      if (json == 'light') return ThemeMode.light;
      return ThemeMode.system;
    },
  );

  /// Returns the current theme mode.
  static ThemeMode get mode => _mode.value;

  /// Returns true if the current mode is dark.
  /// Note: If system, this requires context to be accurate, but this signal tracks the *setting*.
  static bool get isDarkMode => _mode.value == ThemeMode.dark;

  /// Toggles between light and dark mode.
  static void toggle() {
    _mode.value = _mode.value == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
  }

  /// Sets the theme mode explicitly.
  static void setMode(ThemeMode mode) {
    _mode.value = mode;
  }

  /// Internal signal for the app to listen to.
  static Flux<ThemeMode> get signal => _mode;
}
