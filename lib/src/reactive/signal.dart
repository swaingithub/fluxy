import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
      id = 'sig_${DateTime.now().microsecondsSinceEpoch}_${initialValue.hashCode}';

  /// Internal constructor for Computed that allows lazy initialization
  Signal._internal({this.label}) 
    : id = 'comp_${DateTime.now().microsecondsSinceEpoch}';

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
  bool _isDirty = true;
  bool _isComputing = false;

  Computed(this._compute, {super.label}) : super._internal();

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
    return _value as T;
  }

  void _reevaluate() {
    if (_isComputing) return;
    _isComputing = true;
    
    clearDependencies();

    FluxyReactiveContext.push(this);
    try {
      final newValue = _compute();
      
      // Memoization
      final hasChanged = !_deepEquals(_value, newValue);
      
      _value = newValue;
      _isDirty = false;

      if (hasChanged) {
        notifySubscribers();
      }
    } catch (e, stack) {
      debugPrint('Fluxy [Computed] Error during evaluation: $e\n$stack');
      // We don't want to crash the whole app, but we also can't return a "default" T safely.
      // So we rethrow to let the UI builder handle it (e.g. error boundary).
      rethrow;
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
Signal<T> flux<T>(T initialValue, {String? persistKey, bool secure = false, String? label}) {
  if (persistKey != null) {
    return PersistentSignal<T>(initialValue, PersistenceConfig(key: persistKey, secure: secure), label: label);
  }
  return Signal<T>(initialValue, label: label);
}

/// Creates a derived signal computed from other signals.
Computed<T> computed<T>(T Function() fn, {String? label}) => Computed<T>(fn, label: label);

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
  String toString() => 'FluxyCircularDependencyException: Circular dependency detected in reactive graph involving $subscriber';
}

/// Helper for deep equality comparison of primitives and collections.
bool deepEquals(dynamic a, dynamic b) {
  return _deepEquals(a, b);
}

bool _deepEquals(dynamic a, dynamic b) {
  if (identical(a, b)) return true;
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
