

typedef FactoryFunc<T> = T Function();

/// A production-grade Dependency Injection container for Fluxy.
class FluxyDI {
  static final Map<String, _DependencyHolder<dynamic>> _registry = {};

  static String _getKey(Type type, String? tag) => "${type.toString()}${tag ?? ''}";

  /// Registers a singleton instance.
  static void put<T>(T instance, {String? tag}) {
    final key = _getKey(T, tag);
    _registry[key] = _DependencyHolder<T>(instance: instance, tag: tag);
  }

  /// Registers a lazy singleton (created only when first accessed).
  static void lazyPut<T>(FactoryFunc<T> factory, {String? tag}) {
    final key = _getKey(T, tag);
    _registry[key] = _DependencyHolder<T>(factory: factory, tag: tag);
  }

  /// Finds and returns the registered dependency.
  static T find<T>({String? tag}) {
    final key = _getKey(T, tag);
    final holder = _registry[key];
    if (holder == null) {
      throw FluxyDIException("Dependency $T ${tag != null ? 'with tag [$tag]' : ''} not found. Did you forget to put() or lazyPut()?");
    }
    return holder.get() as T;
  }

  /// Removes a dependency from the registry and disposes it if it implements Disposable.
  static void delete<T>({String? tag}) {
    final key = _getKey(T, tag);
    final holder = _registry.remove(key);
    if (holder != null && holder.instance is FluxyDisposable) {
      (holder.instance as FluxyDisposable).onDispose();
    }
  }
}

class FluxyDIException implements Exception {
  final String message;
  FluxyDIException(this.message);
  @override
  String toString() => "FluxyDIException: $message";
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
    if (instance == null) {
      throw FluxyDIException("Failed to resolve dependency of type $T. Factory returned null.");
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
