/// Global configuration for Fluxy developer tools.
class FluxyDebugConfig {
  /// Whether to show layout borders for all Fluxy widgets.
  static bool showLayoutBorders = false;

  /// Whether to show the performance overlay.
  static bool showPerformanceOverlay = false;

  /// Whether the inspector is active.
  static bool isInspectorActive = false;

  /// Toggle layout borders.
  static void toggleLayoutBorders() {
    showLayoutBorders = !showLayoutBorders;
  }

  /// Toggle inspector.
  static void toggleInspector() {
    isInspectorActive = !isInspectorActive;
  }
}
