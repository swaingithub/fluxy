import 'package:flutter/widgets.dart';

/// Prevents interaction-related instability like "Double Tap Ghosting".
class FluxyInteractionGuard {
  static final Map<String, DateTime> _lastTapTimes = {};
  static const Duration _debounceDuration = Duration(milliseconds: 400);

  /// Executes [callback] only if the interaction is not debounced.
  /// Use [id] to uniquely identify the interaction point (e.g. Button ID).
  static void debounce(String id, VoidCallback callback) {
    final now = DateTime.now();
    final lastTap = _lastTapTimes[id];

    if (lastTap == null || now.difference(lastTap) > _debounceDuration) {
      _lastTapTimes[id] = now;
      callback();
    } else {
      debugPrint("🛡️ [Fluxy Interaction Guard]: Preventing double-tap on interaction '$id'");
    }
  }

  /// Automatically clears old tap times to prevent memory leaks.
  static void cleanup() {
    final now = DateTime.now();
    _lastTapTimes.removeWhere((key, value) => now.difference(value) > const Duration(minutes: 1));
  }
}
