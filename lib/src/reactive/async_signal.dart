import 'dart:async';
import 'package:flutter/widgets.dart';
import 'signal.dart';
import '../dsl/fx.dart';

/// Represents the state of an asynchronous operation.
enum AsyncStatus { idling, loading, success, error }

/// A signal that manages asynchronous data fetching and state.
class AsyncSignal<T> extends Signal<T?> {
  final Signal<AsyncStatus> _status = flux(AsyncStatus.idling);
  final Signal<Object?> _error = flux(null);
  
  StreamSubscription<T>? _subscription;
  Future<T>? _currentFuture;

  AsyncSignal([super.initialValue, String? label]) : super(label: label);

  AsyncStatus get status => _status.value;
  Object? get error => _error.value;
  
  bool get isLoading => _status.value == AsyncStatus.loading;
  bool get hasError => _status.value == AsyncStatus.error;
  bool get hasData => (_status.value == AsyncStatus.success || _status.value == AsyncStatus.idling) && value != null;
  T? get data => value;

  /// Executes an async task and updates the signal state.
  /// Automatically cancels previous pending tasks.
  Future<void> fetch(Future<T> Function() task) async {
    _cancelInternal();
    
    _status.value = AsyncStatus.loading;
    _error.value = null;

    final future = task();
    _currentFuture = future;

    try {
      final result = await future;
      if (_currentFuture == future) {
        value = result;
        _status.value = AsyncStatus.success;
      }
    } catch (e) {
      if (_currentFuture == future) {
        _error.value = e;
        _status.value = AsyncStatus.error;
      }
    }
  }

  /// Binds to a stream and updates the signal state on each event.
  void bindStream(Stream<T> stream) {
    _cancelInternal();
    
    _status.value = AsyncStatus.loading;
    _subscription = stream.listen(
      (event) {
        value = event;
        _status.value = AsyncStatus.success;
        _error.value = null;
      },
      onError: (e) {
        _error.value = e;
        _status.value = AsyncStatus.error;
      },
      onDone: () {
        // Keep last state
      },
      cancelOnError: false,
    );
  }

  void _cancelInternal() {
    _subscription?.cancel();
    _subscription = null;
    _currentFuture = null;
  }

  /// UI Binding shorthand for mapping states to widgets.
  Widget on({
    required Widget Function() loading,
    required Widget Function(T data) data,
    required Widget Function(Object error) error,
    Widget Function()? idling,
  }) {
    return Fx(() {
      if (isLoading) return loading();
      if (hasError) return error(this.error!);
      if (hasData) return data(value as T);
      return idling?.call() ?? loading();
    });
  }

  void dispose() {
    _cancelInternal();
  }
}

/// Creates a new reactive async signal from a future task.
AsyncSignal<T> asyncFlux<T>(Future<T> Function() task, {T? initialValue, String? label}) {
  final signal = AsyncSignal<T>(initialValue, label);
  signal.fetch(task);
  return signal;
}

/// Creates a new reactive async signal from a stream.
AsyncSignal<T> streamFlux<T>(Stream<T> stream, {T? initialValue, String? label}) {
  final signal = AsyncSignal<T>(initialValue, label);
  signal.bindStream(stream);
  return signal;
}
