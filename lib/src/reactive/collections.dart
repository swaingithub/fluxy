import 'dart:collection';
import 'signal.dart';

/// Internal mixin to handle shared batching logic for collections.
mixin _BatchableCollectionMixin<T> on Flux<T> {
  bool _isBatching = false;

  void batchUpdate(void Function() operations) {
    _isBatching = true;
    try {
      operations();
    } finally {
      _isBatching = false;
      notifySubscribers();
    }
  }

  void _notifyIfNotBatching() {
    if (!_isBatching) {
      notifySubscribers();
    }
  }
}

/// A reactive list that automatically triggers updates when its contents change.
class FluxList<T> extends Flux<List<T>> with ListMixin<T>, _BatchableCollectionMixin<List<T>> {
  FluxList(super.initialValue);

  @override
  int get length => value.length;

  @override
  set length(int newLength) {
    value.length = newLength;
    _notifyIfNotBatching();
  }

  @override
  T operator [](int index) => value[index];

  @override
  void operator []=(int index, T newValue) {
    value[index] = newValue;
    _notifyIfNotBatching();
  }

  @override
  void add(T element) {
    value.add(element);
    _notifyIfNotBatching();
  }

  @override
  void addAll(Iterable<T> iterable) {
    value.addAll(iterable);
    _notifyIfNotBatching();
  }

  @override
  bool remove(Object? element) {
    final result = value.remove(element);
    if (result) _notifyIfNotBatching();
    return result;
  }

  @override
  void clear() {
    if (value.isNotEmpty) {
      value.clear();
      _notifyIfNotBatching();
    }
  }

  @override
  void insert(int index, T element) {
    value.insert(index, element);
    _notifyIfNotBatching();
  }

  @override
  T removeAt(int index) {
    final result = value.removeAt(index);
    _notifyIfNotBatching();
    return result;
  }

  @override
  List<T> operator +(List<T> other) => value + other;

  /// Updates an item at the given index using a transformer function.
  void update(int index, T Function(T current) transformer) {
    if (index >= 0 && index < value.length) {
      value[index] = transformer(value[index]);
      _notifyIfNotBatching();
    }
  }

  /// Updates all items that match the predicate using a transformer function.
  void updateWhere(
    bool Function(T item) predicate,
    T Function(T current) transformer,
  ) {
    bool hasChanges = false;
    for (int i = 0; i < value.length; i++) {
      if (predicate(value[i])) {
        value[i] = transformer(value[i]);
        hasChanges = true;
      }
    }
    if (hasChanges) _notifyIfNotBatching();
  }

  /// Updates the first item that matches the predicate.
  void updateFirst(
    bool Function(T item) predicate,
    T Function(T current) transformer,
  ) {
    for (int i = 0; i < value.length; i++) {
      if (predicate(value[i])) {
        value[i] = transformer(value[i]);
        _notifyIfNotBatching();
        return;
      }
    }
  }
}

/// A reactive map that automatically triggers updates when its contents change.
class FluxMap<K, V> extends Flux<Map<K, V>> with MapMixin<K, V>, _BatchableCollectionMixin<Map<K, V>> {
  FluxMap(super.initialValue);

  @override
  V? operator [](Object? key) => value[key];

  @override
  void operator []=(K key, V newValue) {
    value[key] = newValue;
    _notifyIfNotBatching();
  }

  @override
  void clear() {
    if (value.isNotEmpty) {
      value.clear();
      _notifyIfNotBatching();
    }
  }

  @override
  Iterable<K> get keys => value.keys;

  @override
  V? remove(Object? key) {
    if (value.containsKey(key)) {
      final res = value.remove(key);
      _notifyIfNotBatching();
      return res;
    }
    return null;
  }

  /// Updates a value at the given key using a transformer function.
  void updateValue(K key, V Function(V current) transformer) {
    if (value.containsKey(key)) {
      value[key] = transformer(value[key] as V);
      _notifyIfNotBatching();
    }
  }

  /// Updates a value at the given key, or inserts it if it doesn't exist.
  void updateOrInsert(K key, V Function(V? current) transformer) {
    value[key] = transformer(value[key]);
    _notifyIfNotBatching();
  }

  /// Updates all values that match the predicate using a transformer function.
  void updateWhere(
    bool Function(K key, V value) predicate,
    V Function(V current) transformer,
  ) {
    bool hasChanges = false;
    final keysToUpdate = <K>[];

    for (final entry in value.entries) {
      if (predicate(entry.key, entry.value)) {
        keysToUpdate.add(entry.key);
      }
    }

    for (final key in keysToUpdate) {
      value[key] = transformer(value[key] as V);
      hasChanges = true;
    }

    if (hasChanges) _notifyIfNotBatching();
  }
}

/// Creates a new reactive list.
FluxList<T> fluxList<T>([List<T>? initialValue]) =>
    FluxList<T>(initialValue ?? []);

/// Creates a new reactive map.
FluxMap<K, V> fluxMap<K, V>([Map<K, V>? initialValue]) =>
    FluxMap<K, V>(initialValue ?? {});

/// Fluent extensions for creating reactive collections.
extension FluxyListExtension<T> on List<T> {
  FluxList<T> get obs => FluxList<T>(this);
}

extension FluxyMapExtension<K, V> on Map<K, V> {
  FluxMap<K, V> get obs => FluxMap<K, V>(this);
}
