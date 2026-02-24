import 'package:flutter/foundation.dart';

/// Represents a single auto-repair event in the Fluxy Safety Kernel.
class StabilityEvent {
  final String type;
  final String description;
  final DateTime timestamp;

  StabilityEvent({
    required this.type,
    required this.description,
    required this.timestamp,
  });
}

/// Tracks stability events and auto-repairs throughout the app lifecycle.
class FluxyStabilityMetrics {
  static int _layoutFixes = 0;
  static int _viewportFixes = 0;
  static int _stateFixes = 0;
  static int _asyncFixes = 0;

  static final List<StabilityEvent> _recentEvents = [];

  static int get layoutFixes => _layoutFixes;
  static int get viewportFixes => _viewportFixes;
  static int get stateFixes => _stateFixes;
  static int get asyncFixes => _asyncFixes;
  static List<StabilityEvent> get recentEvents => List.unmodifiable(_recentEvents);

  static void recordLayoutFix([String? detail]) {
    _layoutFixes++;
    _logRepair('LAYOUT_OPTIMIZATION', detail);
  }

  static void recordViewportFix([String? detail]) {
    _viewportFixes++;
    _logRepair('VIEWPORT_STABILIZATION', detail);
  }

  static void recordStateFix([String? detail]) {
    _stateFixes++;
    _logRepair('STATE_CONSISTENCY_CHECK', detail);
  }

  static void recordAsyncFix([String? detail]) {
    _asyncFixes++;
    _logRepair('ASYNC_RACE_PROTECTION', detail);
  }

  static void _logRepair(String type, [String? detail]) {
    final event = StabilityEvent(
      type: type,
      description: detail ?? 'The Safety Kernel auto-corrected a potential crash.',
      timestamp: DateTime.now(),
    );
    
    _recentEvents.insert(0, event);
    if (_recentEvents.length > 50) _recentEvents.removeLast();

    debugPrint('[KERNEL] [STABILITY] Intercept applied: $type. ${detail ?? ""}');
  }

  static Map<String, int> getSummary() {
    return {
      'layout_fixes': _layoutFixes,
      'viewport_fixes': _viewportFixes,
      'state_fixes': _stateFixes,
      'async_fixes': _asyncFixes,
      'total_saves': _layoutFixes + _viewportFixes + _stateFixes + _asyncFixes,
    };
  }

  static void reset() {
    _layoutFixes = 0;
    _viewportFixes = 0;
    _stateFixes = 0;
    _asyncFixes = 0;
    _recentEvents.clear();
  }

  /// Enable or disable strict mode for stability checks
  static void setStrictMode(bool enabled) {
    debugPrint(
      "[KERNEL] [STABILITY] Strict mode ${enabled ? 'ENABLED' : 'DISABLED'}",
    );
  }
}
