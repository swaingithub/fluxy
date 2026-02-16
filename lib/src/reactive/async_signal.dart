import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'signal.dart';
import '../dsl/fx.dart';

/// Represents the state of an asynchronous operation.
enum AsyncStatus { idling, loading, success, error }

/// Configuration for async flux behavior.
class AsyncConfig {
  /// Number of retry attempts on failure (default: 0)
  final int retries;

  /// Initial delay between retries (default: 1 second)
  final Duration retryDelay;

  /// Whether to use exponential backoff for retries (default: true)
  final bool exponentialBackoff;

  /// Debounce duration to prevent rapid successive calls (default: none)
  final Duration? debounce;

  /// Timeout duration for the async operation (default: none)
  final Duration? timeout;

  /// Callback when an error occurs
  final void Function(Object error, StackTrace? stack)? onError;

  /// Callback when operation succeeds
  final void Function(dynamic data)? onSuccess;

  const AsyncConfig({
    this.retries = 0,
    this.retryDelay = const Duration(seconds: 1),
    this.exponentialBackoff = true,
    this.debounce,
    this.timeout,
    this.onError,
    this.onSuccess,
  });
}

/// A production-ready flux that manages asynchronous data fetching and state.
/// Previously known as AsyncSignal.
class AsyncFlux<T> extends Flux<T?> {
  final Flux<AsyncStatus> _status = flux(AsyncStatus.idling);
  final Flux<Object?> _error = flux(null);
  final AsyncConfig config;

  StreamSubscription<T>? _subscription;
  Future<T>? _currentFuture;
  Timer? _debounceTimer;
  Future<T> Function()? _lastTask;
  bool _isDisposed = false;
  int _retryCount = 0;

  AsyncFlux([
    super.initialValue,
    this.config = const AsyncConfig(),
    String? label,
  ]) : super(label: label);

  AsyncStatus get status => _status.value;
  Object? get error => _error.value;

  bool get isLoading => _status.value == AsyncStatus.loading;
  bool get hasError => _status.value == AsyncStatus.error;
  bool get hasData =>
      (_status.value == AsyncStatus.success ||
          _status.value == AsyncStatus.idling) &&
      value != null;
  bool get isIdling => _status.value == AsyncStatus.idling;
  T? get data => value;

  /// Executes an async task with retry, debounce, and timeout support.
  /// Automatically cancels previous pending tasks.
  Future<void> fetch(Future<T> Function() task) async {
    if (_isDisposed) return;

    _lastTask = task;

    // Handle debouncing
    if (config.debounce != null) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(config.debounce!, () {
        _executeFetch(task);
      });
      return;
    }

    return _executeFetch(task);
  }

  Future<void> _executeFetch(Future<T> Function() task) async {
    if (_isDisposed) return;

    _cancelInternal();
    _retryCount = 0;

    _status.value = AsyncStatus.loading;
    _error.value = null;

    await _attemptFetch(task);
  }

  Future<void> _attemptFetch(Future<T> Function() task) async {
    if (_isDisposed) return;

    try {
      Future<T> future = task();

      // Apply timeout if configured
      if (config.timeout != null) {
        future = future.timeout(
          config.timeout!,
          onTimeout: () => throw TimeoutException(
            'Async operation timed out after ${config.timeout!.inSeconds}s',
          ),
        );
      }

      _currentFuture = future;
      final result = await future;

      if (_isDisposed) return;
      if (_currentFuture == future) {
        value = result;
        _status.value = AsyncStatus.success;
        _retryCount = 0;
        config.onSuccess?.call(result);
      }
    } catch (e, stack) {
      if (_isDisposed) return;

      // Retry logic
      if (_retryCount < config.retries) {
        _retryCount++;

        // Calculate delay with exponential backoff
        final delay = config.exponentialBackoff
            ? config.retryDelay *
                  (1 << (_retryCount - 1)) // 2^(n-1)
            : config.retryDelay;

        debugPrint(
          'Fluxy [AsyncFlux] Retry $_retryCount/${config.retries} after ${delay.inSeconds}s',
        );

        await Future.delayed(delay);

        if (!_isDisposed) {
          return _attemptFetch(task);
        }
      } else {
        // All retries exhausted
        _error.value = e;
        _status.value = AsyncStatus.error;
        config.onError?.call(e, stack);
        debugPrint('Fluxy [AsyncFlux] Error: $e');
      }
    }
  }

  /// Reloads the last executed task.
  Future<void> reload() async {
    if (_lastTask != null) {
      return fetch(_lastTask!);
    } else {
      debugPrint('Fluxy [AsyncFlux] No task to reload');
    }
  }

  /// Cancels the current operation.
  void cancel() {
    _cancelInternal();
    _status.value = AsyncStatus.idling;
  }

  /// Binds to a stream and updates the flux state on each event.
  void bindStream(Stream<T> stream) {
    if (_isDisposed) return;

    _cancelInternal();

    _status.value = AsyncStatus.loading;
    _subscription = stream.listen(
      (event) {
        if (_isDisposed) return;
        value = event;
        _status.value = AsyncStatus.success;
        _error.value = null;
        config.onSuccess?.call(event);
      },
      onError: (e, stack) {
        if (_isDisposed) return;
        _error.value = e;
        _status.value = AsyncStatus.error;
        config.onError?.call(e, stack);
      },
      onDone: () {
        // Keep last state
      },
      cancelOnError: false,
    );
  }

  void _cancelInternal() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
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
    return Fx(() => when(
          loading: loading,
          data: data,
          error: error,
          idling: idling,
        ));
  }

  /// Functional switcher for handling different states.
  R when<R>({
    required R Function() loading,
    required R Function(T data) data,
    required R Function(Object error) error,
    R Function()? idling,
  }) {
    if (isLoading) return loading();
    if (hasError) return error(this.error!);
    if (hasData) return data(value as T);
    return idling?.call() ?? loading();
  }

  /// Disposes the flux and cancels all pending operations.
  void dispose() {
    _isDisposed = true;
    _cancelInternal();
  }
}

@Deprecated('Use AsyncFlux instead')
typedef AsyncSignal<T> = AsyncFlux<T>;

/// Creates a new reactive async flux from a future task.
AsyncFlux<T> asyncFlux<T>(
  Future<T> Function() task, {
  T? initialValue,
  AsyncConfig config = const AsyncConfig(),
  String? label,
}) {
  final flux = AsyncFlux<T>(initialValue, config, label);
  flux.fetch(task);
  return flux;
}

/// Creates a new reactive async flux from a stream.
AsyncFlux<T> streamFlux<T>(
  Stream<T> stream, {
  T? initialValue,
  AsyncConfig config = const AsyncConfig(),
  String? label,
}) {
  final flux = AsyncFlux<T>(initialValue, config, label);
  flux.bindStream(stream);
  return flux;
}

/// A worker runs a heavy computation in a separate isolate and returns the result as an AsyncFlux.
/// This prevents UI jank for CPU-intensive tasks like data processing or image manipulation.
AsyncFlux<T> fluxWorker<P, T>(
  ComputeCallback<P, T> task,
  P message, {
  T? initialValue,
  AsyncConfig config = const AsyncConfig(),
  String? label,
}) {
  return asyncFlux<T>(
    () => compute(task, message),
    initialValue: initialValue,
    config: config,
    label: label,
  );
}

/// A mixin for StatefulWidget States to easily manage local fluxes that 
/// are automatically disposed when the widget is removed.
mixin FluxyLocalMixin<T extends StatefulWidget> on State<T> {
  final List<Flux> _localFluxes = [];

  /// Creates a local flux that will be disposed when this widget is disposed.
  Flux<S> fluxLocal<S>(S initialValue, {String? label}) {
    final f = flux(initialValue, label: label);
    _localFluxes.add(f);
    return f;
  }

  /// Creates a local async flux that will be disposed when this widget is disposed.
  AsyncFlux<S> fluxLocalAsync<S>(
    Future<S> Function() task, {
    S? initialValue,
    AsyncConfig config = const AsyncConfig(),
    String? label,
  }) {
    final f = asyncFlux(task, initialValue: initialValue, config: config, label: label);
    _localFluxes.add(f);
    return f;
  }

  /// Creates a local background worker that will be disposed when this widget is disposed.
  AsyncFlux<T> fluxLocalWorker<P, T>(
    ComputeCallback<P, T> task,
    P message, {
    T? initialValue,
    AsyncConfig config = const AsyncConfig(),
    String? label,
  }) {
    final f = fluxWorker(task, message,
        initialValue: initialValue, config: config, label: label);
    _localFluxes.add(f);
    return f;
  }

  /// Creates a local computed flux that will be disposed when this widget is disposed.
  FluxComputed<S> fluxLocalComputed<S>(
    S Function() fn, {
    String? label,
    void Function(Object error, StackTrace stack)? onError,
    bool validate = false,
  }) {
    final f = fluxComputed(fn, label: label, onError: onError, validate: validate);
    _localFluxes.add(f);
    return f;
  }

  /// Creates a local selector that will be disposed when this widget is disposed.
  FluxComputed<S> fluxLocalSelector<T, S>(
    Flux<T> source,
    S Function(T value) selector, {
    String? label,
  }) {
    final f = fluxSelector(source, selector, label: label);
    _localFluxes.add(f);
    return f;
  }

  /// Creates a local history flux that will be disposed when this widget is disposed.
  FluxHistory<S> fluxLocalHistory<S>(S initialValue,
      {int maxHistory = 100, String? label}) {
    final f = fluxHistory(initialValue, maxHistory: maxHistory, label: label);
    _localFluxes.add(f);
    return f;
  }

  @override
  void dispose() {
    for (final f in _localFluxes) {
      f.dispose();
    }
    _localFluxes.clear();
    super.dispose();
  }
}
