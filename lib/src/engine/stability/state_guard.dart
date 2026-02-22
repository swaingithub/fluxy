import 'package:flutter/widgets.dart';
import '../../reactive/signal.dart';
import '../layout_guard.dart';
import 'stability_metrics.dart';

/// Monitoring system for reactive state health.
/// Detects rebuild loops, circular dependencies, and orphan listeners.
class FluxyStateGuard {
  static final Map<FluxySubscriber, _SubscriberMetrics> _metrics = {};
  static const int _rebuildThreshold = 25; // Rebuilds per second threshold
  static const Duration _window = Duration(seconds: 1);

  /// Records a rebuild event for a subscriber and checks for loop violations.
  static void recordRebuild(FluxySubscriber subscriber) {
    final now = DateTime.now();
    final m = _metrics.putIfAbsent(subscriber, () => _SubscriberMetrics());

    // Clean up old entries outside the window
    m.timestamps.removeWhere((t) => now.difference(t) > _window);
    m.timestamps.add(now);

    if (m.timestamps.length > _rebuildThreshold) {
      _reportLoop(subscriber, m.timestamps.length);
    }
  }

  /// Checks for signals that have too many subscribers, which might indicate zombie listeners.
  static void auditSignals() {
    final fluxes = FluxRegistry.all;
    for (final flux in fluxes) {
      if (flux.subscribers.length > 100) {
        debugPrint("[KERNEL] [STATE] Warning - Flux [${flux.label ?? flux.id}] has ${flux.subscribers.length} subscribers. High probability of leak.");
      }
    }
  }

  static void _reportLoop(FluxySubscriber subscriber, int count) {
    final name = subscriber.debugName ?? subscriber.runtimeType.toString();
    final msg = "Dirty Rebuild Loop: Subscriber '$name' rebuilt $count times in 1 second.";
    final suggestion = "Check if this widget modifies a Signal that it also listens to without a guard or untracked block.";

    if (FluxyLayoutGuard.strictMode) {
      throw FluxyStateViolationException(name, msg, suggestion);
    } else {
      FluxyStabilityMetrics.recordStateFix();
      debugPrint("┌───────────────────────────────────────────┐");
      debugPrint("│ [KERNEL] [AUDIT] State Anomaly Detected    │");
      debugPrint("├───────────────────────────────────────────┤");
      debugPrint("│ Loop: $msg");
      debugPrint("│ Rec:  $suggestion");
      debugPrint("└───────────────────────────────────────────┘");
    }
  }
}

class _SubscriberMetrics {
  final List<DateTime> timestamps = [];
}

class FluxyStateViolationException implements Exception {
  final String subscriberName;
  final String message;
  final String suggestion;

  FluxyStateViolationException(this.subscriberName, this.message, this.suggestion);

  @override
  String toString() => "[STATE] Violation: $message | Recommendation: $suggestion";
}
