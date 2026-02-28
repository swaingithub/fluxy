import 'dart:convert';
import 'dart:collection';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import '../di/fluxy_di.dart';
import '../engine/metrics/observability.dart';
import 'collections.dart';

part 'persistence.dart';
part 'history.dart';

/// A tracking context to keep track of which flux/signals are being accessed during a build.
abstract class FluxySubscriber {
  void notify();
  void registerDependency(Flux flux);
  String? get debugName => null;
}

/// Global middleware interface for intercepting flux updates.
abstract class FluxyMiddleware {
  /// Called before the flux value is updated.
  void onUpdate(Flux flux, dynamic oldValue, dynamic newValue);
}

/// A mixin that provides automatic dependency management for reactive subscribers.
mixin ReactiveSubscriberMixin implements FluxySubscriber {
  final Set<Flux> _dependencies = {};
  Set<Flux> get debugDependencies => Set.unmodifiable(_dependencies);
  int rebuildCount = 0;
  DateTime? lastRebuildTime;

  @override
  String? get debugName => null;

  @override
  void registerDependency(Flux flux) {
    _dependencies.add(flux);
  }

  /// Clears all current dependencies. Should be called before re-evaluating or rebuilding.
  void clearDependencies() {
    for (final dep in List<Flux>.from(_dependencies)) {
      dep.removeSubscriber(this);
    }
    _dependencies.clear();
  }
}

class FluxyReactiveContext {
  static final List<FluxySubscriber> _stack = [];
  static final Set<FluxySubscriber> _pendingUpdates = {};
  static final List<FluxyMiddleware> _middlewares = [];
  static bool _isBatching = false;
  static bool _isFlushScheduled = false;
  
  static void Function(dynamic flux)? onFluxRead;
  static void Function(dynamic flux, dynamic value)? onFluxUpdate;
  static BuildContext? currentContext;

  /// Registers a global middleware to intercept all state changes.
  static void addMiddleware(FluxyMiddleware middleware) => _middlewares.add(middleware);
  
  /// Removes a registered middleware.
  static void removeMiddleware(FluxyMiddleware middleware) => _middlewares.remove(middleware);

  /// Returns the list of active middlewares.
  static List<FluxyMiddleware> get middlewares => List.unmodifiable(_middlewares);

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

  /// Runs the given function without tracking any flux dependencies.
  static R untracked<R>(R Function() fn) {
    // We push a "dummy" null-like state by just suspending the current subscriber
    final current = _stack.isEmpty ? null : _stack.last;
    if (current == null) return fn();
    
    // Temporarily hide the stack to prevent tracking
    final oldStack = List<FluxySubscriber>.from(_stack);
    _stack.clear();
    try {
      return fn();
    } finally {
      _stack.addAll(oldStack);
    }
  }

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
      
      // Use SchedulerBinding to ensure flushes happen at the end of the frame cycle
      // This prevents interrupting the layout/paint phase.
      WidgetsBinding.instance.addPostFrameCallback((_) => _flush());
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
/// Previously known as Signal.
class Flux<T> {
  T? _value; // Internal nullable value to support lazy FluxComputed initialization
  final Set<FluxySubscriber> _subscribers = {};
  final String id;
  final String? label;
  String? key;

  Flux(T initialValue, {this.label, this.key})
    : _value = initialValue,
      id =
          'flux_${DateTime.now().microsecondsSinceEpoch}_${initialValue.hashCode}' {
    FluxRegistry.register(this);
  }

  /// Internal constructor for FluxComputed
  Flux._internal({this.label}) : id = 'comp_${DateTime.now().microsecondsSinceEpoch}' {
    FluxRegistry.register(this);
  }

  /// Manually registers the current reactive context as a dependency of this flux.
  void reportRead() {
    final current = FluxyReactiveContext.current;
    if (current != null) {
      _subscribers.add(current);
      current.registerDependency(this);
    }
  }

  T get value {
    reportRead();
    FluxyReactiveContext.onFluxRead?.call(this);
    return _value as T;
  }

  /// Returns the current value without registering a dependency in the reactive context.
  T peek() => _value as T;

  set value(T newValue) {
    if (_deepEquals(_value, newValue)) return;
    
    final oldValue = _value;
    
    // Global Middlewares (Intercept everything for Analytics/Logging)
    for (final m in FluxyReactiveContext.middlewares) {
      m.onUpdate(this, oldValue, newValue);
    }

    _value = newValue;
    FluxyObservability.recordSignalUpdate(label ?? key ?? id);
    FluxyReactiveContext.onFluxUpdate?.call(this, newValue);
    notifySubscribers();
  }

  Set<FluxySubscriber> get subscribers => Set.from(_subscribers);

  /// Returns the debug names of all current subscribers.
  List<String> get consumerNames =>
      _subscribers.map((s) => s.debugName ?? 'Anonymous').toList();

  void notifySubscribers() {
    for (final sub in List<FluxySubscriber>.from(_subscribers)) {
      FluxyReactiveContext.schedule(sub);
    }
  }

  void removeSubscriber(FluxySubscriber sub) {
    _subscribers.remove(sub);
  }

  /// Disposes the flux and removes it from the registry.
  void dispose() {
    _subscribers.clear();
    FluxRegistry.remove(this);
  }

  // Shorthand for value access/mutation
  T call([T? newValue]) {
    if (newValue != null) value = newValue;
    return value;
  }

  /// Manually listen to flux changes.
  void listen(void Function(T value) fn) {
    fluxEffect(() => fn(value));
  }

  @override
  String toString() => value.toString();
}

/// A derived flux that automatically updates when its dependencies change.
/// Previously known as Computed.
class FluxComputed<T> extends Flux<T> with ReactiveSubscriberMixin {
  final T Function() _compute;
  final void Function(Object error, StackTrace stack)? _onError;

  bool _isDirty = true;
  bool _isComputing = false;
  Object? _lastError;

  FluxComputed(
    this._compute, {
    super.label,
    void Function(Object error, StackTrace stack)? onError,
    bool validate = false,
  }) : _onError = onError,
       super._internal();

  @override
  String? get debugName => label ?? 'FluxComputed';

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
        'Fluxy [FluxComputed] Warning: Reentrant computation detected for ${label ?? id}',
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
          'Fluxy [FluxComputed] ${label ?? id} took ${duration.inMilliseconds}ms',
        );
      }
    } catch (e, stack) {
      _lastError = e;
      _isDirty = false; // Don't keep retrying on every access

      debugPrint('Fluxy [FluxComputed] Error in ${label ?? id}: $e');

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

  @override
  void dispose() {
    clearDependencies();
    _subscribers.clear();
  }
}

/// A persistent side-effect that runs whenever its dependencies change.
/// Previously known as Effect.
class FluxEffect with ReactiveSubscriberMixin {
  final VoidCallback _effect;
  bool _isDisposed = false;

  @override
  String? get debugName => 'FluxEffect';

  FluxEffect(this._effect) {
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

// --- Backward Compatibility Aliases ---
@Deprecated('Use Flux instead')
typedef Signal<T> = Flux<T>;

@Deprecated('Use FluxComputed instead')
typedef Computed<T> = FluxComputed<T>;

@Deprecated('Use FluxEffect instead')
typedef Effect = FluxEffect;

// --- Global Functions ---

/// Creates a new reactive flux/signal.
///
/// Use [label] to give this flux a readable name in [FluxyDevTools] (Inspector).
///
/// [persist] - Whether to automatically persist this value to local storage.
/// [key] - The storage key to use for persistence. If not provided, [label] or a hash of the initial value is used.
/// [secure] - Whether to use secure storage (keychain/keystore).
///
/// Example:
/// ```dart
/// final balance = flux(100.0, key: "user_balance", persist: true);
/// ```
Flux<T> flux<T>(
  T initialValue, {
  String? key,
  bool persist = false,
  bool secure = false,
  String? label,
  T Function(dynamic json)? fromJson,
  @Deprecated('Use key instead') String? persistKey,
}) {
  // ignore: deprecated_member_use_from_same_package
  final effectiveKey = key ?? persistKey;
  if (persist || effectiveKey != null) {
    return PersistentFlux<T>(
      initialValue,
      PersistenceConfig(
        key: effectiveKey ?? label ?? 'flux_${initialValue.hashCode}',
        secure: secure,
      ),
      label: label,
      fromJson: fromJson,
    );
  }
  return Flux<T>(initialValue, label: label);
}

FluxComputed<T> fluxComputed<T>(
  T Function() fn, {
  String? label,
  void Function(Object error, StackTrace stack)? onError,
  bool validate = false,
}) => FluxComputed<T>(fn, label: label, onError: onError, validate: validate);

/// A selector allows you to derive a sub-value from a flux and only trigger updates
/// when that specific sub-value changes.
/// This prevents unnecessary rebuilds when other parts of the source flux change.
FluxComputed<S> fluxSelector<T, S>(
  Flux<T> source,
  S Function(T value) selector, {
  String? label,
}) => fluxComputed(() => selector(source.value), label: label);

/// Legacy alias for fluxComputed
@Deprecated('Use fluxComputed instead')
Computed<T> computed<T>(
  T Function() fn, {
  String? label,
  void Function(Object error, StackTrace stack)? onError,
  bool validate = false,
}) => fluxComputed<T>(fn, label: label, onError: onError, validate: validate);

/// Registers a side-effect that tracks its dependencies.
FluxEffect fluxEffect(VoidCallback fn) => FluxEffect(fn);

/// Legacy alias for fluxEffect
@Deprecated('Use fluxEffect instead')
Effect effect(VoidCallback fn) => fluxEffect(fn);

/// Batches multiple flux updates to prevent redundant rebuilds.
void batch(VoidCallback fn) => FluxyReactiveContext.batch(fn);

/// Runs the given function without tracking any dependencies.
R untracked<R>(R Function() fn) => FluxyReactiveContext.untracked(fn);

/// Operator overloading for numeric fluxes to create FluxComputed values automatically.
extension FluxNumeric<T extends num> on Flux<T> {
  FluxComputed<num> operator +(dynamic other) => _numericOp((a, b) => a + b, other);
  FluxComputed<num> operator -(dynamic other) => _numericOp((a, b) => a - b, other);
  FluxComputed<num> operator *(dynamic other) => _numericOp((a, b) => a * b, other);
  FluxComputed<num> operator /(dynamic other) => _numericOp((a, b) => a / b, other);

  FluxComputed<num> _numericOp(num Function(num a, num b) op, dynamic other) {
    return fluxComputed(() {
      final a = value;
      final b = other is Flux ? other.value : other;
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

/// Fluent extensions for creating fluxes.
extension FluxyPrimitiveExtension<T> on T {
  Flux<T> get obs => flux(this);
}

/// DI Shorthands
T use<T>({String? tag}) => FluxyDI.find<T>(tag: tag);
void inject<T>(T instance, {String? tag}) => FluxyDI.put<T>(instance, tag: tag);

/// Tracks all active fluxes for debugging and devtools integration.
class FluxRegistry {
  static final List<WeakReference<Flux>> _fluxes = [];

  static void register(Flux flux) {
    if (_fluxes.length % 50 == 0) _prune();
    _fluxes.add(WeakReference(flux));
  }

  static void _prune() {
    _fluxes.removeWhere((ref) => ref.target == null);
  }

  static void remove(Flux flux) {
    _fluxes.removeWhere((ref) => ref.target == flux);
  }

  static List<Flux> get all {
    _prune();
    return _fluxes.map((ref) => ref.target).whereType<Flux>().toList();
  }

  /// Captures the current value of all registered fluxes.
  static Map<String, dynamic> captureSnapshot() {
    final snapshot = <String, dynamic>{};
    for (final flux in all) {
      if (flux.label != null) {
        snapshot[flux.id] = flux.peek();
      }
    }
    return snapshot;
  }

  /// Restores state from a snapshot.
  static void restoreSnapshot(Map<String, dynamic> snapshot) {
    FluxyReactiveContext.batch(() {
      for (final entry in snapshot.entries) {
        final flux = find(entry.key);
        if (flux != null) {
          try {
            final val = entry.value;
            
            // Industrial Recovery: Handle Type-Specific restorations
            if (flux is FluxList && val is List) {
              flux.clear();
              flux.addAll(List.from(val));
            } else if (flux is FluxMap && val is Map) {
              flux.clear();
              flux.addAll(Map.from(val));
            } else if (flux is FluxHistory) {
              flux.clearHistory();
              flux.value = val;
            } else {
              flux.value = val;
            }
          } catch (e) {
            debugPrint('[KERNEL] [SIGNAL] Failed to restore flux ${flux.id}: $e');
          }
        }
      }
    });
  }

  static Flux? find(String id) {
    _prune();
    try {
      return _fluxes
          .map((ref) => ref.target)
          .whereType<Flux>()
          .firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
