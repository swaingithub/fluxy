import 'dart:collection';
import 'signal.dart';

/// A reactive list that automatically triggers updates when its contents change.
class FluxList<T> extends Signal<List<T>> with ListMixin<T> {
  FluxList(super.initialValue);

  @override
  int get length {
    return value.length; // value getter tracks dependency
  }

  @override
  set length(int newLength) {
    value.length = newLength;
    notifySubscribers();
  }

  @override
  T operator [](int index) {
    return value[index]; // value getter tracks dependency
  }

  @override
  void operator []=(int index, T newValue) {
    value[index] = newValue;
    notifySubscribers();
  }

  @override
  void add(T element) {
    value.add(element);
    notifySubscribers();
  }

  @override
  void addAll(Iterable<T> iterable) {
    value.addAll(iterable);
    notifySubscribers();
  }

  @override
  bool remove(Object? element) {
    final result = value.remove(element);
    if (result) notifySubscribers();
    return result;
  }

  @override
  void clear() {
    if (value.isNotEmpty) {
      value.clear();
      notifySubscribers();
    }
  }

  @override
  void insert(int index, T element) {
    value.insert(index, element);
    notifySubscribers();
  }

  @override
  T removeAt(int index) {
    final result = value.removeAt(index);
    notifySubscribers();
    return result;
  }

  @override
  List<T> operator +(List<T> other) {
    return value + other;
  }
}

/// A reactive map that automatically triggers updates when its contents change.
class FluxMap<K, V> extends Signal<Map<K, V>> with MapMixin<K, V> {
  FluxMap(super.initialValue);

  @override
  V? operator [](Object? key) {
    return value[key]; // value getter tracks dependency
  }

  @override
  void operator []=(K key, V newValue) {
    value[key] = newValue;
    notifySubscribers();
  }

  @override
  void clear() {
    if (value.isNotEmpty) {
      value.clear();
      notifySubscribers();
    }
  }

  @override
  Iterable<K> get keys {
    return value.keys; // value getter tracks dependency
  }

  @override
  V? remove(Object? key) {
    if (value.containsKey(key)) {
      final res = value.remove(key);
      notifySubscribers();
      return res;
    }
    return null;
  }
}

/// Creates a new reactive list.
FluxList<T> fluxList<T>([List<T>? initialValue]) => FluxList<T>(initialValue ?? []);

/// Creates a new reactive map.
FluxMap<K, V> fluxMap<K, V>([Map<K, V>? initialValue]) => FluxMap<K, V>(initialValue ?? {});

/// Fluent extensions for creating reactive collections.
extension FluxyListExtension<T> on List<T> {
  FluxList<T> get obs => FluxList<T>(this);
}

extension FluxyMapExtension<K, V> on Map<K, V> {
  FluxMap<K, V> get obs => FluxMap<K, V>(this);
}
