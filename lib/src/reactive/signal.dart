import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import '../di/fluxy_di.dart';

part 'persistence.dart';

/// A tracking context to keep track of which signals are being accessed during a build.
abstract class FluxySubscriber {
  void notify();
  void registerDependency(Signal signal);
}

/// A mixin that provides automatic dependency management for reactive subscribers.
mixin ReactiveSubscriberMixin implements FluxySubscriber {
  final Set<Signal> _dependencies = {};

  @override
  void registerDependency(Signal signal) {
    _dependencies.add(signal);
  }

  /// Clears all current dependencies. Should be called before re-evaluating or rebuilding.
  void clearDependencies() {
    for (final dep in List<Signal>.from(_dependencies)) {
      dep.removeSubscriber(this);
    }
    _dependencies.clear();
  }
}

class FluxyReactiveContext {
  static final List<FluxySubscriber> _stack = [];
  static final Set<FluxySubscriber> _pendingUpdates = {};
  static bool _isBatching = false;
  static bool _isFlushScheduled = false;
  static void Function(Signal signal)? onSignalRead;
  static void Function(Signal signal, dynamic value)? onSignalUpdate;

  static void push(FluxySubscriber subscriber) {
    if (_stack.contains(subscriber)) {
      throw FluxyCircularDependencyException(subscriber);
    }
    if (subscriber is ReactiveSubscriberMixin) {
      subscriber.clearDependencies();
    }
    _stack.add(subscriber);
  }

  static void pop() {
    _stack.removeLast();
  }

  static FluxySubscriber? get current => _stack.isEmpty ? null : _stack.last;

  /// Starts a batch of updates. Changes won't trigger rebuilds until the batch completes.
  static void batch(VoidCallback fn) {
    final wasBatching = _isBatching;
    _isBatching = true;
    try {
      fn();
    } finally {
      _isBatching = wasBatching;
      if (!_isBatching) {
        _flush();
      }
    }
  }

  /// Schedules an update for a subscriber.
  static void schedule(FluxySubscriber subscriber) {
    _pendingUpdates.add(subscriber);
    if (!_isBatching && !_isFlushScheduled) {
      _isFlushScheduled = true;
      // Using microtask for immediate but batched execution
      Future.microtask(_flush);
    }
  }

  static void _flush() {
    _isFlushScheduled = false;
    if (_pendingUpdates.isEmpty) return;

    final updates = List<FluxySubscriber>.from(_pendingUpdates);
    _pendingUpdates.clear();

    for (final subscriber in updates) {
      subscriber.notify();
    }
  }
}

/// The atomic unit of reactivity in Fluxy.
class Signal<T> {
  T? _value; // Internal nullable value to support lazy Computed initialization
  final Set<FluxySubscriber> _subscribers = {};
  final String id;
  final String? label;

  Signal(T initialValue, {this.label})
    : _value = initialValue,
      id =
          'sig_${DateTime.now().microsecondsSinceEpoch}_${initialValue.hashCode}' {
    SignalRegistry.register(this);
  }

  /// Internal constructor for Computed that allows lazy initialization
  Signal._internal({this.label})
    : id = 'comp_${DateTime.now().microsecondsSinceEpoch}' {
    SignalRegistry.register(this);
  }

  T get value {
    final current = FluxyReactiveContext.current;
    if (current != null) {
      _subscribers.add(current);
      current.registerDependency(this);
    }
    FluxyReactiveContext.onSignalRead?.call(this);
    return _value as T;
  }

  set value(T newValue) {
    if (_deepEquals(_value, newValue)) return;
    _value = newValue;
    FluxyReactiveContext.onSignalUpdate?.call(this, newValue);
    notifySubscribers();
  }

  Set<FluxySubscriber> get subscribers => Set.from(_subscribers);

  void notifySubscribers() {
    for (final sub in List<FluxySubscriber>.from(_subscribers)) {
      FluxyReactiveContext.schedule(sub);
    }
  }

  void removeSubscriber(FluxySubscriber sub) {
    _subscribers.remove(sub);
  }

  // Shorthand for value access/mutation
  T call([T? newValue]) {
    if (newValue != null) value = newValue;
    return value;
  }

  /// Manually listen to signal changes.
  void listen(void Function(T value) fn) {
    effect(() => fn(value));
  }

  @override
  String toString() => value.toString();
}

/// A derived signal that automatically updates when its dependencies change.
class Computed<T> extends Signal<T> with ReactiveSubscriberMixin {
  final T Function() _compute;
  final void Function(Object error, StackTrace stack)? _onError;

  bool _isDirty = true;
  bool _isComputing = false;
  Object? _lastError;

  Computed(
    this._compute, {
    super.label,
    void Function(Object error, StackTrace stack)? onError,
    bool validate = false,
  }) : _onError = onError,
       super._internal();

  @override
  T get value {
    // Register this computed as a dependency of whatever is calling it
    final current = FluxyReactiveContext.current;
    if (current != null) {
      _subscribers.add(current);
      current.registerDependency(this);
    }

    if (_isDirty) {
      _reevaluate();
    }

    // If there was an error and no fallback value, rethrow
    if (_lastError != null && _value == null) {
      throw _lastError!;
    }

    return _value as T;
  }

  void _reevaluate() {
    if (_isComputing) {
      debugPrint(
        'Fluxy [Computed] Warning: Reentrant computation detected for ${label ?? id}',
      );
      return;
    }

    _isComputing = true;
    final startTime = DateTime.now();

    clearDependencies();

    FluxyReactiveContext.push(this);
    try {
      final newValue = _compute();

      // Memoization - only notify if value actually changed
      final hasChanged = !_deepEquals(_value, newValue);

      _value = newValue;
      _isDirty = false;
      _lastError = null;

      if (hasChanged) {
        notifySubscribers();
      }

      // Record performance metrics
      final duration = DateTime.now().difference(startTime);
      if (duration.inMicroseconds > 1000) {
        // Only log if > 1ms
        debugPrint(
          'Fluxy [Computed] ${label ?? id} took ${duration.inMilliseconds}ms',
        );
      }
    } catch (e, stack) {
      _lastError = e;
      _isDirty = false; // Don't keep retrying on every access

      debugPrint('Fluxy [Computed] Error in ${label ?? id}: $e');

      // Call error handler if provided
      _onError?.call(e, stack);

      // If we have a previous value, keep it; otherwise rethrow
      if (_value == null) {
        rethrow;
      }
    } finally {
      FluxyReactiveContext.pop();
      _isComputing = false;
    }
  }

  @override
  void notify() {
    if (!_isDirty) {
      _isDirty = true;
      notifySubscribers();
    }
  }

  /// Forces recomputation on next access.
  void invalidate() {
    _isDirty = true;
  }

  /// Returns true if this computed has an error.
  bool get hasError => _lastError != null;

  /// Returns the last error, if any.
  Object? get error => _lastError;

  void dispose() {
    clearDependencies();
    _subscribers.clear();
  }
}

/// A persistent side-effect that runs whenever its dependencies change.
class Effect with ReactiveSubscriberMixin {
  final VoidCallback _effect;
  bool _isDisposed = false;

  Effect(this._effect) {
    _run();
  }

  void _run() {
    if (_isDisposed) return;

    clearDependencies();

    FluxyReactiveContext.push(this);
    try {
      _effect();
    } finally {
      FluxyReactiveContext.pop();
    }
  }

  @override
  void notify() {
    _run();
  }

  void dispose() {
    _isDisposed = true;
    clearDependencies();
  }
}

// --- Global Functions ---

/// Creates a new reactive signal.
Signal<T> flux<T>(
  T initialValue, {
  String? persistKey,
  bool secure = false,
  String? label,
}) {
  if (persistKey != null) {
    return PersistentSignal<T>(
      initialValue,
      PersistenceConfig(key: persistKey, secure: secure),
      label: label,
    );
  }
  return Signal<T>(initialValue, label: label);
}

/// Creates a derived signal computed from other signals.
Computed<T> computed<T>(
  T Function() fn, {
  String? label,
  void Function(Object error, StackTrace stack)? onError,
  bool validate = false,
}) => Computed<T>(fn, label: label, onError: onError, validate: validate);

/// Registers a side-effect that tracks its dependencies.
Effect effect(VoidCallback fn) => Effect(fn);

/// Batches multiple signal updates to prevent redundant rebuilds.
void batch(VoidCallback fn) => FluxyReactiveContext.batch(fn);

/// Operator overloading for numeric signals to create Computed values automatically.
extension SignalNumeric<T extends num> on Signal<T> {
  Computed<num> operator +(dynamic other) => _numericOp((a, b) => a + b, other);
  Computed<num> operator -(dynamic other) => _numericOp((a, b) => a - b, other);
  Computed<num> operator *(dynamic other) => _numericOp((a, b) => a * b, other);
  Computed<num> operator /(dynamic other) => _numericOp((a, b) => a / b, other);

  Computed<num> _numericOp(num Function(num a, num b) op, dynamic other) {
    return computed(() {
      final a = value;
      final b = other is Signal ? other.value : other;
      return op(a as num, b as num);
    });
  }
}

/// Exception thrown when a circular dependency is detected in the reactive graph.
class FluxyCircularDependencyException implements Exception {
  final FluxySubscriber subscriber;
  FluxyCircularDependencyException(this.subscriber);
  @override
  String toString() =>
      'FluxyCircularDependencyException: Circular dependency detected in reactive graph involving $subscriber';
}

/// Helper for deep equality comparison of primitives and collections.
bool deepEquals(dynamic a, dynamic b) {
  return _deepEquals(a, b);
}

bool _deepEquals(dynamic a, dynamic b) {
  if (identical(a, b)) return true;
  if (a == b) return true; // Fast path for primitives
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (!_deepEquals(a[i], b[i])) return false;
    }
    return true;
  }
  if (a is Map && b is Map) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || !_deepEquals(a[key], b[key])) return false;
    }
    return true;
  }
  if (a is Set && b is Set) {
    if (a.length != b.length) return false;
    for (final element in a) {
      if (!b.contains(element)) return false;
    }
    return true;
  }
  return a == b;
}

/// Fluent extensions for creating signals.
extension FluxyPrimitiveExtension<T> on T {
  Signal<T> get obs => flux(this);
}

/// DI Shorthands
T use<T>({String? tag}) => FluxyDI.find<T>(tag: tag);
void inject<T>(T instance, {String? tag}) => FluxyDI.put<T>(instance, tag: tag);

/// Tracks all active signals for debugging and devtools integration.
class SignalRegistry {
  static final List<WeakReference<Signal>> _signals = [];

  static void register(Signal signal) {
    if (_signals.length % 50 == 0) _prune();
    _signals.add(WeakReference(signal));
  }

  static void _prune() {
    _signals.removeWhere((ref) => ref.target == null);
  }

  static List<Signal> get all {
    _prune();
    return _signals.map((ref) => ref.target).whereType<Signal>().toList();
  }

  static Signal? find(String id) {
    _prune();
    try {
      return _signals
          .map((ref) => ref.target)
          .whereType<Signal>()
          .firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
