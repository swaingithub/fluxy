import '../plugins/fluxy_permissions.dart';
import '../plugins/fluxy_camera.dart';
import '../plugins/fluxy_biometric.dart';
import '../plugins/fluxy_storage.dart';
import '../plugins/fluxy_analytics.dart';
import '../plugins/fluxy_auth.dart';
import '../plugins/fluxy_notifications.dart';
import '../plugins/fluxy_connectivity.dart';

/// Extension to add plugin shortcuts to Fx class
extension FxPlugins on Fx {
  /// Permissions plugin shortcut
  static final permissions = FluxyPermissionsPlugin();
  
  /// Camera plugin shortcut  
  static final camera = FluxyCameraPlugin();
  
  /// Biometric plugin shortcut
  static final biometric = FluxyBiometricPlugin();
  
  /// Storage plugin shortcut
  static final storage = FluxyStoragePlugin();
  
  /// Analytics plugin shortcut
  static final analytics = FluxyAnalyticsPlugin();
  
  /// Auth plugin shortcut
  static final auth = FluxyAuthPlugin();
  
  /// Notifications plugin shortcut
  static final notifications = FluxyNotificationsPlugin();
  
  /// Connectivity plugin shortcut
  static final connectivity = FluxyConnectivityPlugin();
}
