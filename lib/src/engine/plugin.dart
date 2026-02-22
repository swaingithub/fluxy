import 'dart:async';
import 'package:flutter/foundation.dart';

/// The interface for creating Fluxy plugins.
/// Plugins can extend the framework's capabilities (Analytics, Auth, DevTools, etc.)
abstract class FluxyPlugin {
  /// The unique name of the plugin.
  String get name;

  /// Called when the plugin is registered via [Fluxy.register].
  /// Use this to initialize services or register dependencies.
  FutureOr<void> onRegister();

  /// Called after [Fluxy.init] has completed and the app is ready.
  FutureOr<void> onAppReady() {}

  /// Called when the plugin is being removed or the app is shutting down.
  FutureOr<void> onDispose() {}

  /// Whether the plugin is currently enabled.
  bool get isEnabled => FluxyPluginEngine.isPluginEnabled(name);

  /// The permissions required by this plugin (e.g., 'storage', 'camera', 'network').
  /// This is used for sandboxing and security auditing.
  List<String> get permissions => const [];
}

/// The engine that manages the lifecycle of all registered Fluxy plugins.
class FluxyPluginEngine {
  static final List<FluxyPlugin> _plugins = [];
  static final Map<String, bool> _pluginStatus = {};

  /// Registers a plugin to the engine.
  static void register(FluxyPlugin plugin) {
    if (!_plugins.any((p) => p.name == plugin.name)) {
      _plugins.add(plugin);
      // Plugins are enabled by default unless remotely disabled
      _pluginStatus.putIfAbsent(plugin.name, () => true);
    }
  }

  /// Sets the enabled status of a plugin (Kill-switch).
  static void setPluginEnabled(String name, bool enabled) {
    _pluginStatus[name] = enabled;
    debugPrint('[SYS] [KERNEL] Plugin "$name" policy set to: ${enabled ? 'ACTIVE' : 'INACTIVE'}');
  }

  /// Checks if a plugin is enabled.
  static bool isPluginEnabled(String name) => _pluginStatus[name] ?? true;

  /// Lists all registered plugins.
  static List<FluxyPlugin> get plugins => List.unmodifiable(_plugins);

  /// Finds a registered plugin by type.
  static T? find<T extends FluxyPlugin>() {
    for (final plugin in _plugins) {
      if (plugin is T) return plugin;
    }
    return null;
  }

  /// Initializes all registered plugins.
  static Future<void> onRegisterAll() async {
    for (final plugin in _plugins) {
      if (!isPluginEnabled(plugin.name)) {
        debugPrint('[SYS] [KERNEL] Skipping registration for disabled module: ${plugin.name}');
        continue;
      }
      try {
        await plugin.onRegister();
      } catch (e, stack) {
        debugPrint('[SYS] [FATAL] Error registering module "${plugin.name}" | Error: $e');
        debugPrint(stack.toString());
      }
    }
  }

  /// Notifies all plugins that the app is ready.
  static Future<void> onAppReadyAll() async {
    for (final plugin in _plugins) {
      if (!isPluginEnabled(plugin.name)) continue;
      try {
        await plugin.onAppReady();
      } catch (e, stack) {
        debugPrint('[SYS] [ERROR] Ready signal failure for module "${plugin.name}" | Error: $e');
        debugPrint(stack.toString());
      }
    }
  }

  /// Disposes all registered plugins.
  static Future<void> onDisposeAll() async {
    for (final plugin in _plugins) {
      if (!isPluginEnabled(plugin.name)) continue;
      await plugin.onDispose();
    }
    _plugins.clear();
  }
}
