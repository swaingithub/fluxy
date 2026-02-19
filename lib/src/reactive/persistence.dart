part of 'signal.dart';

/// Configuration for flux persistence.
class PersistenceConfig {
  final String key;
  final bool secure;
  final bool autoLoad;
  final Duration? debounce; // Wait before persisting rapidly changing values

  const PersistenceConfig({
    required this.key,
    this.secure = false,
    this.autoLoad = true,
    this.debounce,
  });
}

/// Abstract interface for storage adapters.
abstract class StorageAdapter {
  Future<void> init();
  Future<void> write(String key, String value, {bool secure = false});
  Future<String?> read(String key, {bool secure = false});
  Future<void> delete(String key, {bool secure = false});
  Future<void> clear();
}

/// Default implementation using SharedPreferences and FlutterSecureStorage.
class DefaultStorageAdapter implements StorageAdapter {
  SharedPreferences? _prefs;
  final _secureStorage = const FlutterSecureStorage();

  @override
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  Future<void> write(String key, String value, {bool secure = false}) async {
    if (secure) {
      await _secureStorage.write(key: key, value: value);
    } else {
      await _prefs?.setString(key, value);
    }
  }

  @override
  Future<String?> read(String key, {bool secure = false}) async {
    if (secure) {
      return await _secureStorage.read(key: key);
    } else {
      return _prefs?.getString(key);
    }
  }

  @override
  Future<void> delete(String key, {bool secure = false}) async {
    if (secure) {
      await _secureStorage.delete(key: key);
    } else {
      await _prefs?.remove(key);
    }
  }

  @override
  Future<void> clear() async {
    await _prefs?.clear();
    await _secureStorage.deleteAll();
  }
}

/// The persistence engine for Fluxy.
class FluxyPersistence {
  static StorageAdapter _adapter = DefaultStorageAdapter();
  static bool _isInitialized = false;
  static final List<WeakReference<PersistentFlux>> _persistentFluxes = [];

  static void _register(PersistentFlux flux) {
    _persistentFluxes.add(WeakReference(flux));
  }

  /// Sets a custom storage adapter (e.g., Hive, SQLite).
  static void setAdapter(StorageAdapter adapter) {
    _adapter = adapter;
    _isInitialized = false; // Re-initialize with new adapter
  }

  /// Initializes the storage engine.
  static Future<void> init() async {
    if (!_isInitialized) {
      await _adapter.init();
      _isInitialized = true;
    }
  }

  /// Forces all registered persistent fluxes to reload their data.
  /// This is the key to global "State Hydration".
  static Future<void> hydrate() async {
    if (!_isInitialized) await init();
    
    final futures = <Future<void>>[];
    for (final ref in _persistentFluxes) {
      final flux = ref.target;
      if (flux != null) {
        futures.add(flux.load());
      }
    }
    await Future.wait(futures);
  }

  static Future<void> save(
    String key,
    dynamic value, {
    bool secure = false,
  }) async {
    if (!_isInitialized) await init();
    try {
      final String encoded = jsonEncode(value);
      await _adapter.write(key, encoded, secure: secure);
    } catch (e) {
      debugPrint("Fluxy [Persistence] Error saving key '$key': $e");
    }
  }

  static Future<dynamic> load(String key, {bool secure = false}) async {
    if (!_isInitialized) await init();
    try {
      final String? encoded = await _adapter.read(key, secure: secure);
      if (encoded == null) return null;
      return jsonDecode(encoded);
    } catch (e) {
      debugPrint("Fluxy [Persistence] Error loading key '$key': $e");
      return null;
    }
  }

  static Future<void> clear() async {
    if (!_isInitialized) await init();
    await _adapter.clear();
  }
}

/// A middleware that automatically persists any flux with a 'persistKey' metadata.
class HydrationMiddleware extends FluxyMiddleware {
  @override
  void onUpdate(Flux flux, dynamic oldValue, dynamic newValue) {
    if (flux is PersistentFlux) return; // Already handled by the class itself
    
    // We check if the flux has a persistKey metadata 
    // (This requires adding a persistKey field to the base Flux class)
    if (flux.persistKey != null) {
      FluxyPersistence.save(flux.persistKey!, newValue);
    }
  }
}

/// A flux that automatically persists its value.
/// Previously known as PersistentSignal.
class PersistentFlux<T> extends Flux<T> {
  final PersistenceConfig config;
  final T Function(dynamic json)? fromJson;
  Timer? _debounceTimer;

  PersistentFlux(super.initialValue, this.config, {super.label, this.fromJson}) {
    FluxyPersistence._register(this);
    if (config.autoLoad) {
      load();
    }
  }

  /// Loads the value from storage.
  Future<void> load() async {
    final stored = await FluxyPersistence.load(
      config.key,
      secure: config.secure,
    );
    if (stored != null) {
      try {
        if (fromJson != null) {
          value = fromJson!(stored);
        } else {
          value = stored as T;
        }
      } catch (e) {
        debugPrint(
          "Fluxy [Persistence] Type mismatch for key '${config.key}': $e",
        );
      }
    }
  }

  @override
  set value(T newValue) {
    if (_deepEquals(_value, newValue)) return;
    super.value = newValue;
    _scheduleSave(newValue);
  }

  void _scheduleSave(T newValue) {
    if (config.debounce != null) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(config.debounce!, () {
        FluxyPersistence.save(config.key, newValue, secure: config.secure);
      });
    } else {
      FluxyPersistence.save(config.key, newValue, secure: config.secure);
    }
  }
}

typedef PersistentSignal<T> = PersistentFlux<T>;
