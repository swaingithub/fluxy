import 'package:flutter/foundation.dart';
import 'dart:async';

/// Global Observability Engine for Fluxy.
/// Tracks real-time performance, signal churn, and frame budget.
class FluxyObservability {
  static bool enabled = kDebugMode;
  
  // Stats storage
  static final Map<String, int> _signalUpdates = {};
  static final Map<String, int> _rebuilds = {};
  static final _updateController = StreamController<ObservabilityEvent>.broadcast();

  static Stream<ObservabilityEvent> get events => _updateController.stream;

  /// Records a signal update event.
  static void recordSignalUpdate(String key) {
    if (!enabled) return;
    _signalUpdates[key] = (_signalUpdates[key] ?? 0) + 1;
    _updateController.add(ObservabilityEvent(type: EventType.signal, name: key, count: _signalUpdates[key]!));
    
    if (_signalUpdates[key]! > 100) {
       debugPrint('⚠️ [FLUX_STATS] High churn detected on signal: $key (${_signalUpdates[key]} updates)');
    }
  }

  /// Records a widget rebuild event.
  static void recordRebuild(String label) {
    if (!enabled) return;
    _rebuilds[label] = (_rebuilds[label] ?? 0) + 1;
    _updateController.add(ObservabilityEvent(type: EventType.rebuild, name: label, count: _rebuilds[label]!));
  }

  static Map<String, int> get signalStats => Map.unmodifiable(_signalUpdates);
  static Map<String, int> get rebuildStats => Map.unmodifiable(_rebuilds);

  static void clear() {
    _signalUpdates.clear();
    _rebuilds.clear();
  }
}

enum EventType { signal, rebuild }

class ObservabilityEvent {
  final EventType type;
  final String name;
  final int count;

  ObservabilityEvent({required this.type, required this.name, required this.count});
}
