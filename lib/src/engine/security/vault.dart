import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';

/// Industrial-Grade Secure Vault for Fluxy.
/// Uses Hardware-Backed storage (KeyStore/Keychain) + Application-Level Scrambling.
class FluxyVault {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  /// Key used for secondary scrambling (Optional Layer)
  static String? _internalSalt;

  /// Initializes the vault with an optional application-specific salt.
  static void init({String? salt}) {
    _internalSalt = salt;
  }

  /// Saves a value securely.
  static Future<void> write(String key, String value) async {
    final secured = _scramble(value);
    await _storage.write(key: key, value: secured);
  }

  /// Reads a value securely.
  static Future<String?> read(String key) async {
    final secured = await _storage.read(key: key);
    if (secured == null) return null;
    return _unscramble(secured);
  }

  /// Deletes a key.
  static Future<void> delete(String key) async => await _storage.delete(key: key);

  /// Clears the entire vault.
  static Future<void> clear() async => await _storage.deleteAll();

  static String _scramble(String value) {
    if (_internalSalt == null) return value;
    // Simple XOR/Base64 scrambling as a secondary layer
    final bytes = utf8.encode(value);
    final saltBytes = utf8.encode(_internalSalt!);
    final scrambled = List<int>.generate(bytes.length, (i) => bytes[i] ^ saltBytes[i % saltBytes.length]);
    return base64Encode(scrambled);
  }

  static String _unscramble(String binary) {
    if (_internalSalt == null) return binary;
    try {
      final bytes = base64Decode(binary);
      final saltBytes = utf8.encode(_internalSalt!);
      final unscrambled = List<int>.generate(bytes.length, (i) => bytes[i] ^ saltBytes[i % saltBytes.length]);
      return utf8.decode(unscrambled);
    } catch (_) {
      return binary; // Fallback to raw if decoding fails
    }
  }

  /// Generates a unique device fingerprint for security tracking.
  static String generateFingerprint(String seed) {
    return sha256.convert(utf8.encode(seed + (_internalSalt ?? 'fluxy-core'))).toString();
  }
}
