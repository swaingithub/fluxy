import 'package:flutter/foundation.dart';

/// Tracks stability events and auto-repairs throughout the app lifecycle.
class FluxyStabilityMetrics {
  static int _layoutFixes = 0;
  static int _viewportFixes = 0;
  static int _stateFixes = 0;
  static int _asyncFixes = 0;

  static int get layoutFixes => _layoutFixes;
  static int get viewportFixes => _viewportFixes;
  static int get stateFixes => _stateFixes;
  static int get asyncFixes => _asyncFixes;

  static void recordLayoutFix() {
    _layoutFixes++;
    _logRepair("🎨 Layout Auto-Repair");
  }

  static void recordViewportFix() {
    _viewportFixes++;
    _logRepair("📏 Viewport Stabilization");
  }

  static void recordStateFix() {
    _stateFixes++;
    _logRepair("🔄 State Consistency Fix");
  }

  static void recordAsyncFix() {
    _asyncFixes++;
    _logRepair("⏳ Async Race Protected");
  }

  static void _logRepair(String type) {
    debugPrint("🛡️ [Fluxy Stability Kernel]: $type applied successfully.");
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
  }
}
