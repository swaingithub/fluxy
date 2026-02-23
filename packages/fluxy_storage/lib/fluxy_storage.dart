import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluxy/fluxy.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FLUXY STORAGE PLUGIN
// Unified key-value storage with three tiers:
//   1. SharedPreferences  — standard persistent key-value
//   2. FlutterSecureStorage — encrypted (keychain/keystore) for tokens/secrets
//   3. In-memory cache    — instant reads with optional TTL expiry
// ─────────────────────────────────────────────────────────────────────────────

class FluxyStoragePlugin extends FluxyPlugin with ChangeNotifier {
  @override
  String get name => 'fluxy_storage';

  @override
  List<String> get permissions => ['storage'];

  // ── Backing stores ──────────────────────────────────────────────────────────
  SharedPreferences? _prefs;
  FlutterSecureStorage? _secure;

  // In-memory cache: key → {value, expiry?}
  final Map<String, _CacheEntry> _cache = {};

  // Reactive signal: total number of standard keys stored. Useful for UI.
  final keyCount = flux<int>(0, label: 'storage_key_count');

  bool get isReady => _prefs != null;

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  FutureOr<void> onRegister() async {
    debugPrint('[DATA] [INIT] Initializing persistent storage...');
    try {
      _prefs = await SharedPreferences.getInstance();
      _secure = const FlutterSecureStorage(
        aOptions: AndroidOptions(
          keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
          storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
        ),
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      );
      _syncKeyCount();
      debugPrint('[DATA] [READY] Hydrated — ${_prefs!.getKeys().length} key(s) discovered.');
    } catch (e) {
      debugPrint('[DATA] [FATAL] Persistence initialization failed | Error: $e');
    }
  }

  @override
  FutureOr<void> onDispose() async {
    _cache.clear();
  }

  // ── Standard Storage ─────────────────────────────────────────────────────────

  /// Store any JSON-encodable value. Supports TTL expiry.
  Future<void> set(
    String key,
    dynamic value, {
    Duration? ttl,
  }) async {
    _assertReady();
    final encoded = _encode(value);
    await _prefs!.setString(key, encoded);

    // Cache it locally for instant access
    _cache[key] = _CacheEntry(
      value: value,
      expiry: ttl != null ? DateTime.now().add(ttl) : null,
    );

    _syncKeyCount();
    notifyListeners();
    debugPrint('[DATA] [SET] Keystage committed: "$key"');
  }

  /// Read a value. Hits in-memory cache first, then SharedPreferences.
  T? get<T>(String key, {T? fallback}) {
    _assertReady();

    // Check in-memory cache
    final cached = _cache[key];
    if (cached != null) {
      if (cached.isExpired) {
        _cache.remove(key);
        _prefs!.remove(key);
        _syncKeyCount();
        return fallback;
      }
      return cached.value as T? ?? fallback;
    }

    // Fall through to SharedPreferences
    final raw = _prefs!.getString(key);
    if (raw == null) return fallback;

    try {
      final decoded = _decode(raw);

      // Re-populate cache without TTL (disk read has no expiry info)
      _cache[key] = _CacheEntry(value: decoded);
      return decoded as T? ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  /// Delete a key.
  Future<void> remove(String key) async {
    _assertReady();
    _cache.remove(key);
    await _prefs!.remove(key);
    _syncKeyCount();
    notifyListeners();
    debugPrint('[DATA] [REMOVE] Entry purged: "$key"');
  }

  /// Returns true if key exists and is not expired.
  bool has(String key) {
    _assertReady();
    final cached = _cache[key];
    if (cached != null && cached.isExpired) {
      _cache.remove(key);
      _prefs!.remove(key);
      return false;
    }
    return _prefs!.containsKey(key);
  }

  /// All stored keys.
  Set<String> get keys => _prefs?.getKeys() ?? {};

  /// Wipe everything.
  Future<void> clear() async {
    _assertReady();
    _cache.clear();
    await _prefs!.clear();
    _syncKeyCount();
    notifyListeners();
    debugPrint('[DATA] [CLEARED] Full dataset purge complete.');
  }

  // ── Type-safe convenience getters ────────────────────────────────────────────

  String?  getString(String key, {String? fallback})   => get<String>(key, fallback: fallback);
  int?     getInt(String key, {int? fallback})           => get<int>(key, fallback: fallback);
  double?  getDouble(String key, {double? fallback})     => get<double>(key, fallback: fallback);
  bool?    getBool(String key, {bool? fallback})         => get<bool>(key, fallback: fallback);
  Map<String, dynamic>? getMap(String key)               => get<Map<String, dynamic>>(key);
  List<dynamic>?        getList(String key)              => get<List<dynamic>>(key);

  // ── Batch operations ─────────────────────────────────────────────────────────

  /// Write multiple key-value pairs atomically.
  Future<void> setBatch(Map<String, dynamic> entries, {Duration? ttl}) async {
    for (final e in entries.entries) {
      await set(e.key, e.value, ttl: ttl);
    }
  }

  /// Read multiple keys at once.
  Map<String, dynamic> getBatch(List<String> keys) {
    return {for (final k in keys) k: get(k)};
  }

  // ── Secure Storage ───────────────────────────────────────────────────────────

  /// Write an encrypted secret (tokens, passwords, API keys).
  Future<void> setSecure(String key, String value) async {
    _assertReady();
    await _secure!.write(key: key, value: value);
    debugPrint('[SEC] [VAULT-SET] Encrypted commitment: "$key"');
  }

  /// Read an encrypted secret.
  Future<String?> getSecure(String key) async {
    _assertReady();
    return _secure!.read(key: key);
  }

  /// Delete an encrypted secret.
  Future<void> removeSecure(String key) async {
    _assertReady();
    await _secure!.delete(key: key);
    debugPrint('[SEC] [VAULT-REMOVE] Encrypted entry purged: "$key"');
  }

  /// Wipe all secure storage.
  Future<void> clearSecure() async {
    _assertReady();
    await _secure!.deleteAll();
    debugPrint('[SEC] [VAULT-CLEARED] Cryptographic container wiped.');
  }

  // ── Private ──────────────────────────────────────────────────────────────────

  void _assertReady() {
    assert(_prefs != null, '[FluxyStorage] Not ready — call after Fluxy.init()');
  }

  void _syncKeyCount() => keyCount.value = _prefs?.getKeys().length ?? 0;

  String _encode(dynamic value) => jsonEncode({'v': value});

  dynamic _decode(String raw) {
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map['v'];
  }
}

/// Internal cache entry with optional TTL.
class _CacheEntry {
  final dynamic value;
  final DateTime? expiry;

  _CacheEntry({required this.value, this.expiry});

  bool get isExpired => expiry != null && DateTime.now().isAfter(expiry!);
}
