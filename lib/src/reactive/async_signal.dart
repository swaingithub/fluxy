import 'signal.dart';

/// Represents the state of an asynchronous operation.
enum AsyncStatus { idling, loading, success, error }

/// A signal that manages asynchronous data fetching and state.
class AsyncSignal<T> extends Signal<T?> {
  AsyncStatus _status = AsyncStatus.idling;
  Object? _error;

  AsyncSignal(super.initialValue);

  AsyncStatus get status {
    // Register dependency
    final current = FluxyReactiveContext.current;
    if (current != null) {
      // In a real implementation, status would need to be its own signal 
      // or we'd need a more robust way to track multiple properties.
    }
    return _status;
  }

  Object? get error => _error;
  bool get isLoading => _status == AsyncStatus.loading;
  bool get hasError => _status == AsyncStatus.error;
  bool get hasData => _status == AsyncStatus.success && value != null;

  /// Executes an async task and updates the signal state.
  Future<void> fetch(Future<T> Function() task) async {
    _status = AsyncStatus.loading;
    notifySubscribers(); // Notify subscribers of loading state

    try {
      value = await task();
      _status = AsyncStatus.success;
    } catch (e) {
      _error = e;
      _status = AsyncStatus.error;
    } finally {
      notifySubscribers(); // Final notification
    }
  }
}

/// Shorthand for creating an AsyncSignal.
AsyncSignal<T> asyncFlux<T>(T? initialValue) => AsyncSignal<T>(initialValue);
