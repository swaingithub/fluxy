import 'dart:async';
import 'package:flutter/services.dart';
import 'package:fluxy/fluxy.dart';

/// Managed Haptic Engine for Fluxy.
/// Abstracts raw platform calls into semantic sensory confirmation.
class FluxyHapticsPlugin extends FluxyPlugin {
  @override
  String get name => 'fluxy_haptics';

  final enabled = flux(true);

  @override
  FutureOr<void> onRegister() {
    Fluxy.log('Haptics', 'INIT', 'Sensory engine ready.');
  }

  /// Light confirmation tap.
  void light() {
    if (!enabled.value) return;
    HapticFeedback.lightImpact();
  }

  /// Medium physical impact.
  void medium() {
    if (!enabled.value) return;
    HapticFeedback.mediumImpact();
  }

  /// Heavy destructive impact.
  void heavy() {
    if (!enabled.value) return;
    HapticFeedback.heavyImpact();
  }

  /// Standard selection click.
  void selection() {
    if (!enabled.value) return;
    HapticFeedback.selectionClick();
  }

  /// Triple-pulse error alarm.
  void error() {
    if (!enabled.value) return;
    HapticFeedback.vibrate(); // Fallback for error signal
  }

  /// Successful completion pulse.
  void success() {
    if (!enabled.value) return;
    HapticFeedback.mediumImpact();
  }
}
