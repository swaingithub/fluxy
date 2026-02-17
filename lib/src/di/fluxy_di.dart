import '../engine/controller.dart';

typedef FactoryFunc<T> = T Function();

/// Defines the lifetime scope of a dependency.
enum FxScope {
  /// Singleton: Created once and lives for the entire app session.
  app,
  /// Route: Tied to a specific route/page. Disposed when the route is removed.
  route,
  /// Factory: A new instance is created every time [find] is called.
  factory,
}

/// A production-grade Dependency Injection container for Fluxy.
class FluxyDI {
  static final Map<String, _DependencyHolder<dynamic>> _registry = {};

  static String _getKey(Type type, String? tag) =>
      "${type.toString()}${tag ?? ''}";

  /// Registers a singleton instance.
  /// Default scope is [FxScope.app].
  static T put<T>(T instance, {String? tag, FxScope scope = FxScope.app}) {
    final key = _getKey(T, tag);
    _registry[key] = _DependencyHolder<T>(instance: instance, tag: tag, scope: scope);
    
    // Auto-init for non-lazy puts
    if (instance is FluxController && !instance.isInitialized) {
      instance.onInit();
    }
    
    return instance;
  }

  /// Registers an instance using its runtime type.
  /// Internal use for framework-managed controllers.
  static void putByRuntimeType(dynamic instance, {String? tag, FxScope scope = FxScope.route}) {
    final key = _getKey(instance.runtimeType, tag);
    _registry[key] = _DependencyHolder<dynamic>(instance: instance, tag: tag, scope: scope);
    
    if (instance is FluxController && !instance.isInitialized) {
      instance.onInit();
    }
  }

  /// Registers a lazy singleton (created only when first accessed).
  static void lazyPut<T>(FactoryFunc<T> factory, {String? tag, FxScope scope = FxScope.app}) {
    final key = _getKey(T, tag);
    _registry[key] = _DependencyHolder<T>(factory: factory, tag: tag, scope: scope);
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
    if (holder != null) {
      _disposeDependency(holder);
    }
  }

  /// Resets the DI container by clearing and disposing all dependencies.
  /// Use primarily in unit tests.
  static void reset() {
    for (final holder in _registry.values) {
      _disposeDependency(holder);
    }
    _registry.clear();
  }

  /// Clears all dependencies within a specific scope.
  static void clearScope(FxScope scope) {
    final keysToRemove = _registry.entries
        .where((entry) => entry.value.scope == scope)
        .map((entry) => entry.key)
        .toList();

    for (final key in keysToRemove) {
      final holder = _registry.remove(key);
      if (holder != null) {
        _disposeDependency(holder);
      }
    }
  }

  static void _disposeDependency(_DependencyHolder holder) {
    if (holder.instance != null) {
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

  /// Internal helper to remove a dependency by its runtime type.
  static void deleteByRuntimeType(dynamic instance, {String? tag}) {
    final key = _getKey(instance.runtimeType, tag);
    final holder = _registry.remove(key);
    if (holder != null) {
      _disposeDependency(holder);
    }
  }

  /// Returns a map of all currently registered dependencies and their metadata.
  /// Used primarily by Fluxy DevTools.
  static Map<String, Map<String, dynamic>> get activeRegistry =>
      _registry.map((key, value) => MapEntry(key, {
            'type': value.instance?.runtimeType.toString() ?? 'Lazy/Factory',
            'tag': value.tag,
            'scope': value.scope.name,
            'isInitialized': value.instance != null,
            'instance': value.instance,
          }));
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
  FxScope scope;
  bool _isResolving = false;

  _DependencyHolder({this.instance, this.factory, this.tag, this.scope = FxScope.app});

  T get() {
    if (_isResolving) {
      throw FluxyDIException("Circular dependency detected while resolving $T ${tag ?? ''}");
    }

    if (scope == FxScope.factory) {
      if (factory == null) {
        throw FluxyDIException("Factory scope requires a factory function.");
      }
      _isResolving = true;
      try {
        final newInst = factory!();
        if (newInst is FluxController && !newInst.isInitialized) {
          newInst.onInit();
        }
        return newInst;
      } finally {
        _isResolving = false;
      }
    }

    if (instance == null && factory != null) {
      _isResolving = true;
      try {
        instance = factory!();
        
        // Hook into FluxController lifecycle
        if (instance is FluxController && !(instance as FluxController).isInitialized) {
          (instance as FluxController).onInit();
        }
      } finally {
        _isResolving = false;
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
