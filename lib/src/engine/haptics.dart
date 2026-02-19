import 'package:flutter/services.dart';

/// A premium wrapper for system haptic feedback.
class FxHaptic {
  static bool enabled = true;

  static void light() {
    if (!enabled) return;
    HapticFeedback.selectionClick();
  }

  static void medium() {
    if (!enabled) return;
    HapticFeedback.mediumImpact();
  }

  static void heavy() {
    if (!enabled) return;
    HapticFeedback.heavyImpact();
  }

  static void success() {
    if (!enabled) return;
    // Vibrations aren't natively supported directly in HapticFeedback for success 
    // without third party, but we can simulate or use heavy then light.
    HapticFeedback.mediumImpact();
  }

  static void error() {
    if (!enabled) return;
    HapticFeedback.vibrate();
  }
}
