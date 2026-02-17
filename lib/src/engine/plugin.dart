import 'dart:async';

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
}
