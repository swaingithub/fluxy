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
    
    debugPrint("-------------------------------------------");
    debugPrint(translated != null ? translated : "🔴 Fluxy Error Captured:");
    if (translated == null) debugPrint(error.toString());
    if (stack != null && translated == null) debugPrint(stack.toString());
    debugPrint("-------------------------------------------");

    for (var handler in _handlers) {
      try {
        handler(translated ?? error, stack);
      } catch (e) {
        debugPrint("❌ Error in FluxyErrorHandler: $e");
      }
    }
  }

  static String? _translateError(Object error) {
    final msg = error.toString();
    if (msg.contains("RenderBox was not laid out") || msg.contains("has infinite height") || msg.contains("vertical viewport was given unbounded height")) {
      return "🔴 Fluxy Layout Alert: You are using .hFull() or .wFull() inside an FxScroll or similar scrollable. This causes infinite constraints. Use .h(minHeight) or Fx.scrollCenter() instead.";
    }
    if (msg.contains("ParentDataWidget") && msg.contains("Positioned")) {
      return "🔴 Fluxy Layout Alert: You are using .positioned() on a widget that is not a direct child of a Stack. Flutter requires Positioned to be a direct child of Stack. Fluxy tries to lift this automatically, but check your hierarchy.";
    }
    if (msg.contains("ParentDataWidget") && (msg.contains("Expanded") || msg.contains("Flexible"))) {
      return "🔴 Fluxy Layout Alert: You are using .expanded() or .flex() outside of a Row, Column, or Flex. These widgets only work in flex containers.";
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
