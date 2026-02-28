import 'package:flutter/foundation.dart';
import '../../reactive/signal.dart';

/// Industrial-Grade Feature Toggle Engine for Fluxy.
/// Allows remote/dynamic "Kill-Switch" capabilities for specific modules.
class FluxyFeatureToggle {
  static final Map<String, Flux<bool>> _features = {};

  /// Checks if a feature is currently enabled.
  static bool isEnabled(String featureKey) {
    return _features[featureKey]?.value ?? true; // Default to true
  }

  /// Gets the reactive signal for a feature.
  static Flux<bool> getSignal(String featureKey) {
    return _features.putIfAbsent(featureKey, () => flux(true, label: 'FEAT_$featureKey'));
  }

  /// Disables a feature (Kill Switch).
  static void kill(String featureKey) {
    debugPrint('🚨 [FLUX_CONTROL] KILL SWITCH ACTIVATED: $featureKey');
    getSignal(featureKey).value = false;
  }

  /// Enables a feature.
  static void restore(String featureKey) {
    debugPrint('✅ [FLUX_CONTROL] FEATURE RESTORED: $featureKey');
    getSignal(featureKey).value = true;
  }

  /// Sets multiple toggles at once (e.g., from a Remote Config fetch).
  static void sync(Map<String, bool> config) {
    config.forEach((key, value) {
      getSignal(key).value = value;
    });
  }
}
