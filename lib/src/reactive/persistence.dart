part of 'signal.dart';

/// Configuration for signal persistence.
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

/// The persistence engine for Fluxy signals.
class FluxyPersistence {
  static StorageAdapter _adapter = DefaultStorageAdapter();
  static bool _isInitialized = false;

  /// Sets a custom storage adapter (e.g., Hive, SQLite).
  static void setAdapter(StorageAdapter adapter) {
    _adapter = adapter;
  }

  /// Initializes the storage engine.
  static Future<void> init() async {
    if (!_isInitialized) {
      await _adapter.init();
      _isInitialized = true;
    }
  }

  static Future<void> save(String key, dynamic value, {bool secure = false}) async {
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

/// A signal that automatically persists its value.
class PersistentSignal<T> extends Signal<T> {
  final PersistenceConfig config;
  Timer? _debounceTimer;

  PersistentSignal(super.initialValue, this.config, {super.label}) {
    if (config.autoLoad) {
      _load();
    }
  }

  Future<void> _load() async {
    final stored = await FluxyPersistence.load(config.key, secure: config.secure);
    if (stored != null) {
      try {
        // Handle basic types directly, map conversions might be needed for objects
        // For simple signals (int, bool, String, Map, List), jsonDecode works fine.
        value = stored as T;
      } catch (e) {
        debugPrint("Fluxy [Persistence] Type mismatch for key '${config.key}': $e");
        // Fallback to initial value if type fails
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


