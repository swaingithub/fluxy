import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluxy/fluxy.dart';

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
  ///   },
  ///   "disabled_plugins": ["fluxy_analytics"]
  /// }
  /// ```
  static Future<void> update(String manifestUrl) async {
    try {
      await init();
      debugPrint('[OTA] [INIT] Checking for remote manifest... [EXPERIMENTAL]');

      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(manifestUrl));
      final response = await request.close();

      if (response.statusCode != 200) {
        throw HttpException('Failed to fetch manifest: ${response.statusCode}');
      }

      final body = await response.transform(utf8.decoder).join();
      final Map<String, dynamic> manifest = jsonDecode(body);
      final int newVersion = manifest['version'] ?? 0;

      final prefs = await SharedPreferences.getInstance();
      final int currentVersion = prefs.getInt(_versionKey) ?? 0;

      if (newVersion > currentVersion) {
        debugPrint(
          '[OTA] [SYNC] New version identified: v$newVersion (Local: v$currentVersion). Synchronizing assets...',
        );
        await _downloadAssets(manifest['assets']);
        await prefs.setInt(_versionKey, newVersion);
        debugPrint(
          '[OTA] [READY] Update lifecycle successful. Current environment: v$newVersion.',
        );
      }
      
      // Always apply plugin status from latest manifest if available
      if (manifest.containsKey('disabled_plugins')) {
        final List<dynamic> disabled = manifest['disabled_plugins'];
        for (final pluginName in disabled) {
          FluxyPluginEngine.setPluginEnabled(pluginName.toString(), false);
        }
      }
    } catch (e) {
      debugPrint('[OTA] [FATAL] Update sequence interrupted | Error: $e');
    }
  }

  static Future<void> _downloadAssets(Map<String, dynamic>? assets) async {
    if (assets == null) return;
    final client = HttpClient();

    for (final entry in assets.entries) {
      final String filename = entry.key;
      final String url = entry.value;

      try {
        final request = await client.getUrl(Uri.parse(url));
        final response = await request.close();

        if (response.statusCode == 200) {
          final bytes = await response.fold<List<int>>(
            [],
            (a, b) => a..addAll(b),
          );
          final file = File('${_assetsDir!.path}/$filename');
          await file.writeAsBytes(bytes);
          debugPrint('[FluxyRemote] Downloaded $filename');
        } else {
          debugPrint(
            '[FluxyRemote] Failed to download $filename: ${response.statusCode}',
          );
        }
      } catch (e) {
        debugPrint('[OTA] [ERROR] Asset transfer failure ($filename) | Error: $e');
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
