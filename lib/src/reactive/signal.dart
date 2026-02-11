import 'package:flutter/widgets.dart';
import '../di/fluxy_di.dart';

/// A tracking context to keep track of which signals are being accessed during a build.
abstract class FluxySubscriber {
  void notify();
}

class FluxyReactiveContext {
  static final List<FluxySubscriber> _stack = [];

  static void push(FluxySubscriber subscriber) {
    _stack.add(subscriber);
  }

  static void pop() {
    _stack.removeLast();
  }

  static FluxySubscriber? get current => _stack.isEmpty ? null : _stack.last;
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
    }
    return _value;
  }

  set value(T newValue) {
    if (_value == newValue) return;
    _value = newValue;
    notifySubscribers();
  }

  @protected
  void notifySubscribers() {
    // Copy to avoid concurrent modification during notification
    final subs = List<FluxySubscriber>.from(_subscribers);
    for (final sub in subs) {
      sub.notify();
    }
  }

  /// Manually remove a subscriber (e.g. when a widget is disposed)
  void removeSubscriber(FluxySubscriber sub) {
    _subscribers.remove(sub);
  }

  // Allow shorthand mutation: count(5) instead of count.value = 5
  T call([T? newValue]) {
    if (newValue != null) value = newValue;
    return value;
  }

  /// Registers a callback that fires whenever the value changes.
  void listen(void Function(T value) callback) {
    _subscribers.add(_ListenerSubscriber(() => callback(_value)));
  }

  // Operator overloading for numeric types to create Computed values
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

class _ListenerSubscriber implements FluxySubscriber {
  final VoidCallback _callback;
  _ListenerSubscriber(this._callback);
  @override
  void notify() => _callback();
}

/// Shorthand for creating a Signal.
Signal<T> flux<T>(T value) => Signal<T>(value);

/// Shorthand for creating a Computed value.
Computed<T> computed<T>(T Function() selector) => Computed<T>(selector);
class Computed<T> implements FluxySubscriber {
  final T Function() _selector;
  T? _cachedValue;
  bool _dirty = true;
  final Set<FluxySubscriber> _subscribers = {};

  Computed(this._selector);

  T get value {
    final current = FluxyReactiveContext.current;
    if (current != null) {
      _subscribers.add(current);
    }

    if (_dirty) {
      FluxyReactiveContext.push(this);
      _cachedValue = _selector();
      FluxyReactiveContext.pop();
      _dirty = false;
    }
    return _cachedValue as T;
  }

  @override
  void notify() {
    if (!_dirty) {
      _dirty = true;
      for (final sub in _subscribers) {
        sub.notify();
      }
    }
  }
}

/// DI Shorthands
T use<T>({String? tag}) => FluxyDI.find<T>(tag: tag);
void inject<T>(T instance, {String? tag}) => FluxyDI.put<T>(instance, tag: tag);
