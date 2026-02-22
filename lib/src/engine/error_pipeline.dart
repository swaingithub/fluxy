import 'package:flutter/foundation.dart';

typedef FluxyErrorHandler = void Function(Object error, StackTrace? stack);

/// A unified error handling pipeline for Fluxy.
class FluxyError {
  static final List<FluxyErrorHandler> _handlers = [];

  /// Registers a global error handler.
  /// Use this to pipe errors to crash reporting services (Sentry, Firebase, etc.).
  static void onError(FluxyErrorHandler handler) {
    if (!_handlers.contains(handler)) {
      _handlers.add(handler);
    }
  }

  /// Reports an error to the pipeline.
  static void report(Object error, [StackTrace? stack]) {
    final translated = _translateError(error);
    
    debugPrint("┌───────────────────────────────────────────┐");
    debugPrint(translated != null ? "│ [KERNEL] [REPAIR] $translated" : "│ [KERNEL] [ERROR] Unhandled Exception      │");
    if (translated == null) {
      debugPrint("├───────────────────────────────────────────┤");
      debugPrint("│ Error: $error");
    }
    debugPrint("└───────────────────────────────────────────┘");

    for (var handler in _handlers) {
      try {
        handler(translated ?? error, stack);
      } catch (e) {
        debugPrint("[KERNEL] [FATAL] Error in FluxyErrorHandler: $e");
      }
    }
  }

  static String? _translateError(Object error) {
    final msg = error.toString();
    if (msg.contains("RenderBox was not laid out") || msg.contains("has infinite height") || msg.contains("vertical viewport was given unbounded height")) {
      return "[LAYOUT] Alert: .hFull() / .wFull() used inside FxScroll. Recommendation: Use .h(minHeight) or Fx.scrollCenter().";
    }
    if (msg.contains("ParentDataWidget") && msg.contains("Positioned")) {
      return "[LAYOUT] Alert: .positioned() used outside of Stack. Flutter hierarchy violation detected.";
    }
    if (msg.contains("ParentDataWidget") && (msg.contains("Expanded") || msg.contains("Flexible"))) {
      return "[LAYOUT] Alert: .expanded() / .flex() used outside of Flex container (Row/Column).";
    }
    return null;
  }

  /// Hooks into Flutter's global error reporting.
  static void hookIntoFlutter() {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      report(details.exception, details.stack);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      report(error, stack);
      return true;
    };
  }
}
