part of 'signal.dart';

/// Configuration for signal persistence.
class PersistenceConfig {
  final String key;
  final bool secure;
  final bool autoLoad;

  const PersistenceConfig({
    required this.key,
    this.secure = false,
    this.autoLoad = true,
  });
}

/// The persistence engine for Fluxy signals.
class FluxyPersistence {
  static SharedPreferences? _prefs;
  static const _secureStorage = FlutterSecureStorage();

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> save(String key, dynamic value, {bool secure = false}) async {
    final String encoded = jsonEncode(value);
    if (secure) {
      await _secureStorage.write(key: key, value: encoded);
    } else {
      await _prefs?.setString(key, encoded);
    }
  }

  static Future<dynamic> load(String key, {bool secure = false}) async {
    String? encoded;
    if (secure) {
      encoded = await _secureStorage.read(key: key);
    } else {
      encoded = _prefs?.getString(key);
    }
    
    if (encoded == null) return null;
    try {
      return jsonDecode(encoded);
    } catch (_) {
      return null;
    }
  }
}

/// A signal that automatically persists its value.
class PersistentSignal<T> extends Signal<T> {
  final PersistenceConfig config;

  PersistentSignal(super.initialValue, this.config, {super.label}) {
    if (config.autoLoad) {
      _load();
    }
  }

  Future<void> _load() async {
    final stored = await FluxyPersistence.load(config.key, secure: config.secure);
    if (stored != null) {
      try {
        super.value = stored as T;
      } catch (e) {
        debugPrint("Fluxy [Persistence] Type mismatch for key '${config.key}': $e");
      }
    }
  }

  @override
  set value(T newValue) {
    if (_deepEquals(_value, newValue)) return;
    super.value = newValue;
    FluxyPersistence.save(config.key, newValue, secure: config.secure);
  }
}

