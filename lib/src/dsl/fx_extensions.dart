import 'package:fluxy/fluxy.dart';

/// Extension for direct access to Fluxy plugins
/// Provides convenient shortcuts: Fx.permissions, Fx.camera, etc.
extension FxPlugins on Fx {
  /// Direct access to permissions plugin
  /// Usage: `Fx.permissions.request()` instead of `Fx.platform.permissions.request()`
  static dynamic get permissions => Fluxy.find<dynamic>();
  
  /// Direct access to camera plugin
  /// Usage: `Fx.camera.capture()` instead of `Fx.platform.camera.capture()`
  static dynamic get camera => Fluxy.find<dynamic>();
  
  /// Direct access to biometric plugin
  /// Usage: `Fx.biometric.authenticate()` instead of `Fx.platform.biometric.authenticate()`
  static dynamic get biometric => Fluxy.find<dynamic>();

  /// Direct access to storage plugin
  /// Usage: `Fx.storage.set()` instead of `Fx.platform.storage.set()`
  static dynamic get storage => Fluxy.find<dynamic>();

  /// Direct access to analytics plugin
  /// Usage: `Fx.analytics.track()` instead of `Fx.platform.analytics.track()`
  static dynamic get analytics => Fluxy.find<dynamic>();
  
  /// Direct access to auth plugin
  /// Usage: `Fx.auth.signIn()` instead of `Fx.platform.auth.signIn()`
  static dynamic get auth => Fluxy.find<dynamic>();
  
  /// Direct access to notifications plugin
  /// Usage: `Fx.notifications.show()` instead of `Fx.platform.notifications.show()`
  static dynamic get notifications => Fluxy.find<dynamic>();
  
  /// Direct access to connectivity plugin
  /// Usage: `Fx.connectivity.check()` instead of `Fx.platform.connectivity.check()`
  static dynamic get connectivity => Fluxy.find<dynamic>();
  
  /// Direct access to platform plugin
  /// Usage: `Fx.platform.getVersion()` instead of `Fx.platform.platform.getVersion()`
  static dynamic get platform => Fluxy.find<dynamic>();
  
  /// Direct access to ota plugin
  /// Usage: `Fx.ota.update()` instead of `Fx.platform.ota.update()`
  static dynamic get ota => Fluxy.find<dynamic>();

  /// Direct access to animations plugin
  /// Usage: `Fx.animations.fast` instead of `Fx.platform.animations.fast`
  static dynamic get animations => Fluxy.find<dynamic>();
}
