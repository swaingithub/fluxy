import 'package:flutter/widgets.dart';

typedef FactoryFunc<T> = T Function();

/// A production-grade Dependency Injection container for Fluxy.
class FluxyDI {
  static final Map<Type, _DependencyHolder<dynamic>> _registry = {};

  /// Registers a singleton instance.
  static void put<T>(T instance, {String? tag}) {
    final type = T;
    _registry[type] = _DependencyHolder<T>(instance: instance, tag: tag);
  }

  /// Registers a lazy singleton (created only when first accessed).
  static void lazyPut<T>(FactoryFunc<T> factory, {String? tag}) {
    final type = T;
    _registry[type] = _DependencyHolder<T>(factory: factory, tag: tag);
  }

  /// Finds and returns the registered dependency.
  static T find<T>({String? tag}) {
    final type = T;
    final holder = _registry[type];
    if (holder == null) {
      throw Exception("Dependency $type not found in FluxyDI registry.");
    }
    return holder.get() as T;
  }

  /// Removes a dependency from the registry and disposes it if it implements Disposable.
  static void delete<T>({String? tag}) {
    final type = T;
    final holder = _registry.remove(type);
    if (holder != null && holder.instance is FluxyDisposable) {
      (holder.instance as FluxyDisposable).onDispose();
    }
  }
}

class _DependencyHolder<T> {
  T? instance;
  FactoryFunc<T>? factory;
  String? tag;

  _DependencyHolder({this.instance, this.factory, this.tag});

  T get() {
    if (instance == null && factory != null) {
      instance = factory!();
    }
    return instance!;
  }
}

/// Interface for dependencies that need cleanup.
abstract class FluxyDisposable {
  void onDispose();
}

/// Base class for controllers with lifecycle management.
abstract class FluxyController extends FluxyDisposable {
  void onInit() {}
  @override
  void onDispose() {}
}
