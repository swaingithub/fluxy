import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';
import '../di/fluxy_di.dart';

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

  static void push(FluxySubscriber subscriber) {
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
  T _value;
  final Set<FluxySubscriber> _subscribers = {};

  Signal(this._value);

  T get value {
    final current = FluxyReactiveContext.current;
    if (current != null) {
      _subscribers.add(current);
      current.registerDependency(this);
    }
    return _value;
  }

  set value(T newValue) {
    if (_value == newValue) return;
    _value = newValue;
    notifySubscribers();
  }

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

  @override
  String toString() => value.toString();

  // Operator overloading for numeric types to create Computed values automatically
  operator +(dynamic other) => _numericOp((a, b) => a + b, other);
  operator -(dynamic other) => _numericOp((a, b) => a - b, other);
  operator *(dynamic other) => _numericOp((a, b) => a * b, other);
  operator /(dynamic other) => _numericOp((a, b) => a / b, other);

  Computed _numericOp(dynamic Function(dynamic a, dynamic b) op, dynamic other) {
    return computed(() {
      final a = value;
      final b = other is Signal ? other.value : other;
      return op(a, b);
    });
  }
}

/// A derived signal that automatically updates when its dependencies change.
class Computed<T> extends Signal<T> with ReactiveSubscriberMixin {
  final T Function() _compute;
  bool _isDirty = true;

  Computed(this._compute) : super(null as T);

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
    return _value;
  }

  void _reevaluate() {
    clearDependencies();

    FluxyReactiveContext.push(this);
    try {
      _value = _compute();
    } finally {
      FluxyReactiveContext.pop();
    }
    _isDirty = false;
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
Signal<T> flux<T>(T value) => Signal<T>(value);

/// Creates a derived signal computed from other signals.
Computed<T> computed<T>(T Function() fn) => Computed<T>(fn);

/// Registers a side-effect that tracks its dependencies.
Effect effect(VoidCallback fn) => Effect(fn);

/// Batches multiple signal updates to prevent redundant rebuilds.
void batch(VoidCallback fn) => FluxyReactiveContext.batch(fn);

/// DI Shorthands
T use<T>({String? tag}) => FluxyDI.find<T>(tag: tag);
void inject<T>(T instance, {String? tag}) => FluxyDI.put<T>(instance, tag: tag);
