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
    debugPrint("-------------------------------------------");
    debugPrint("🔴 Fluxy Error Captured:");
    debugPrint(error.toString());
    if (stack != null) debugPrint(stack.toString());
    debugPrint("-------------------------------------------");

    for (var handler in _handlers) {
      try {
        handler(error, stack);
      } catch (e) {
        debugPrint("❌ Error in FluxyErrorHandler: $e");
      }
    }
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
