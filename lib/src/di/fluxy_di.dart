import '../engine/controller.dart';

typedef FactoryFunc<T> = T Function();

/// A production-grade Dependency Injection container for Fluxy.
class FluxyDI {
  static final Map<String, _DependencyHolder<dynamic>> _registry = {};

  static String _getKey(Type type, String? tag) =>
      "${type.toString()}${tag ?? ''}";

  /// Registers a singleton instance.
  static T put<T>(T instance, {String? tag}) {
    final key = _getKey(T, tag);
    _registry[key] = _DependencyHolder<T>(instance: instance, tag: tag);
    
    // Auto-init for non-lazy puts
    if (instance is FluxController && !instance.isInitialized) {
      instance.onInit();
    }
    
    return instance;
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
      throw FluxyDIException(
        "Dependency $T ${tag != null ? 'with tag [$tag]' : ''} not found. Did you forget to put() or lazyPut()?",
      );
    }
    return holder.get() as T;
  }

  /// Removes a dependency from the registry and disposes it if it implements Disposable.
  static void delete<T>({String? tag}) {
    final key = _getKey(T, tag);
    final holder = _registry.remove(key);
    if (holder != null && holder.instance != null) {
      final inst = holder.instance;
      if (inst is FluxController) {
        inst.onDispose();
      } else if (inst is FluxyDisposable) {
        inst.onDispose();
      }
    }
  }

  /// Checks if a dependency is registered.
  static bool exists<T>({String? tag}) => _registry.containsKey(_getKey(T, tag));
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
      
      // Hook into FluxController lifecycle
      if (instance is FluxController && !(instance as FluxController).isInitialized) {
        (instance as FluxController).onInit();
      }
    }
    if (instance == null) {
      throw FluxyDIException(
        "Failed to resolve dependency of type $T. Factory returned null.",
      );
    }
    return instance!;
  }
}

/// Interface for dependencies that need cleanup.
abstract class FluxyDisposable {
  void onDispose();
}
