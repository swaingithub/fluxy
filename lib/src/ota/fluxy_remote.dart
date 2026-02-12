import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages Over-The-Air updates and asset caching.
class FluxyRemote {
  static const String _versionKey = 'fluxy_ota_version';
  static bool _initialized = false;
  static Directory? _assetsDir;

  /// Initializes the OTA system.
  static Future<void> init() async {
    if (_initialized) return;
    final appDir = await getApplicationDocumentsDirectory();
    _assetsDir = Directory('${appDir.path}/fluxy_ota');
    if (!_assetsDir!.existsSync()) {
      _assetsDir!.createSync(recursive: true);
    }
    _initialized = true;
  }

  /// Checks for updates from the given manifest URL.
  /// 
  /// Manifest format: 
  /// ```json
  /// { 
  ///   "version": 2, 
  ///   "assets": { 
  ///     "home.json": "https://api.example.com/assets/home.json", 
  ///     "theme.json": "https://api.example.com/assets/theme.json" 
  ///   } 
  /// }
  /// ```
  static Future<void> update(String manifestUrl) async {
    try {
      await init();
      debugPrint('[FluxyRemote] Checking for updates...');
      final response = await http.get(Uri.parse(manifestUrl));
      if (response.statusCode != 200) throw HttpException('Failed to fetch manifest: ${response.statusCode}');

      final Map<String, dynamic> manifest = jsonDecode(response.body);
      final int newVersion = manifest['version'] ?? 0;
      
      final prefs = await SharedPreferences.getInstance();
      final int currentVersion = prefs.getInt(_versionKey) ?? 0;

      if (newVersion > currentVersion) {
        debugPrint('[FluxyRemote] New version detected: $newVersion (Current: $currentVersion). Downloading...');
        await _downloadAssets(manifest['assets']);
        await prefs.setInt(_versionKey, newVersion);
        debugPrint('[FluxyRemote] Update complete. Version is now $newVersion.');
      } else {
        debugPrint('[FluxyRemote] Already up to date (Version $currentVersion).');
      }
    } catch (e) {
      debugPrint('[FluxyRemote] Update failed: $e');
      // Non-blocking, just log
    }
  }

  static Future<void> _downloadAssets(Map<String, dynamic>? assets) async {
    if (assets == null) return;
    
    for (final entry in assets.entries) {
      final String filename = entry.key;
      final String url = entry.value;
      
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final file = File('${_assetsDir!.path}/$filename');
          await file.writeAsBytes(response.bodyBytes);
          debugPrint('[FluxyRemote] Downloaded $filename');
        } else {
           debugPrint('[FluxyRemote] Failed to download $filename: ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('[FluxyRemote] Exception downloading $filename: $e');
      }
    }
  }

  /// Retrieves a JSON asset, preferring local cache if available.
  /// If not found in cache, returns null (caller should handle fallback).
  static Future<Map<String, dynamic>?> getJson(String filename) async {
    await init();
    final file = File('${_assetsDir!.path}/$filename');
    if (file.existsSync()) {
      try {
        final content = await file.readAsString();
        return jsonDecode(content);
      } catch (e) {
        debugPrint('[FluxyRemote] Failed to read cache for $filename: $e');
      }
    }
    return null;
  }
}
