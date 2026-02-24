part of 'signal.dart';

/// A specialized flux that maintains a history of values, enabling undo/redo functionality.
/// Branded as FluxHistory to avoid name collisions with generic 'undo' packages.
class FluxHistory<T> extends Flux<T> {
  final int maxHistory;
  final ListQueue<T> _past = ListQueue<T>();
  final ListQueue<T> _future = ListQueue<T>();

  FluxHistory(super.initialValue, {this.maxHistory = 100, super.label, super.key});

  @override
  set value(T newValue) {
    if (_deepEquals(_value, newValue)) return;
    
    // Push current value to past
    if (_value != null) {
      _past.addLast(_value as T);
    }
    
    if (_past.length > maxHistory) {
      _past.removeFirst();
    }
    
    // Clear future on manual update
    _future.clear();
    
    super.value = newValue;
  }

  /// Returns true if there is a previous state to go back to.
  bool get canUndo {
    reportRead();
    return _past.isNotEmpty;
  }

  /// Returns true if there is a next state to go forward to.
  bool get canRedo {
    reportRead();
    return _future.isNotEmpty;
  }

  /// Moves the state back one step.
  void undo() {
    debugPrint('Fluxy [History] Undo requested. canUndo: $canUndo');
    if (!canUndo) return;

    final current = _value as T;
    final previous = _past.removeLast();
    
    _future.addFirst(current);
    
    // Update underlying value without triggering history push
    _value = previous;
    debugPrint('Fluxy [History] Undo done. New value: $_value');
    notifySubscribers();
  }

  /// Moves the state forward one step.
  void redo() {
    debugPrint('Fluxy [History] Redo requested. canRedo: $canRedo');
    if (!canRedo) return;

    final current = _value as T;
    final next = _future.removeFirst();
    
    _past.addLast(current);
    
    // Update underlying value without triggering history push
    _value = next;
    debugPrint('Fluxy [History] Redo done. New value: $_value');
    notifySubscribers();
  }

  /// Clears the history stacks.
  void clearHistory() {
    _past.clear();
    _future.clear();
  }
}

/// Creates a new flux with undo/redo capabilities.
/// Branded as fluxHistory for Fluxy's unique identity.
FluxHistory<T> fluxHistory<T>(T initialValue, {int maxHistory = 100, String? label, String? key}) {
  return FluxHistory<T>(initialValue, maxHistory: maxHistory, label: label, key: key);
}

/// Legacy alias for backward compatibility.
@Deprecated('Use FluxHistory instead')
typedef HistoryFlux<T> = FluxHistory<T>;
