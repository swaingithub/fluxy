import 'dart:async';
import 'package:flutter/widgets.dart';
import 'stability_metrics.dart';

/// Prevents async crashes by tracking widget lifecycle.
class FluxyAsyncGuard {
  /// Wraps a callback to only execute if the widget [context] is still mounted.
  static void runSafe(BuildContext context, VoidCallback callback) {
    if (context.mounted) {
      callback();
    }
  }

  /// Ensures a [Future] callback only executes if the widget is mounted.
  static Future<T?> guardFuture<T>(BuildContext context, Future<T> future) async {
    try {
      final T result = await future;
      if (context.mounted) {
        return result;
      } else {
        FluxyStabilityMetrics.recordAsyncFix();
      }
    } catch (e) {
      if (context.mounted) {
        rethrow;
      }
    }
    return null;
  }
}

extension FxAsyncExtension<T> on Future<T> {
  /// Makes this future safe to use with a [BuildContext].
  /// If the widget is unmounted when the future completes, it returns null.
  Future<T?> safe(BuildContext context) => FluxyAsyncGuard.guardFuture(context, this);
}

extension FxStreamExtension<T> on Stream<T> {
  /// Listens to a stream but automatically cancels or stops execution if the [context] is unmounted.
  StreamSubscription<T> safeListen(
    BuildContext context,
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return listen(
      (data) {
        if (context.mounted) {
          onData?.call(data);
        }
      },
      onError: (err, stack) {
        if (context.mounted) {
          onError?.call(err, stack);
        }
      },
      onDone: () {
        if (context.mounted) {
          onDone?.call();
        }
      },
      cancelOnError: cancelOnError,
    );
  }
}
