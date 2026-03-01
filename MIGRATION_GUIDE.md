# Migration Guide: Fluxy v0.2.6 → v1.0.0 (Legacy)

This guide helps you migrate your Fluxy applications from v0.2.6 to v1.0.0.

## Breaking Changes

Fluxy v1.0.0 introduces a modular architecture with separate packages for different features.

### Package Structure Changes

| Feature | v0.2.6 (Single Package) | v1.0.0 (Modular) |
|---------|--------------------------|-------------------|
| Testing Utilities | `package:fluxy/fx_test_utils.dart` | `package:fluxy_test/fluxy_test.dart` |
| Camera Plugin | `Fx.camera` | `package:fluxy_camera/fluxy_camera.dart` |
| Auth Plugin | `Fx.auth` | `package:fluxy_auth/fluxy_auth.dart` |
| Notifications | `Fx.notifications` | `package:fluxy_notifications/fluxy_notifications.dart` |
| Storage | `Fx.storage` | `package:fluxy_storage/fluxy_storage.dart` |
| Connectivity | `Fx.connectivity` | `package:fluxy_connectivity/fluxy_connectivity.dart` |
| Analytics | `Fx.analytics` | `package:fluxy_analytics/fluxy_analytics.dart` |
| Biometrics | `Fx.biometric` | `package:fluxy_biometric/fluxy_biometric.dart` |
| OTA Updates | `Fx.ota` | `package:fluxy_ota/fluxy_ota.dart` |
| Haptics | `Fx.haptic` | `package:fluxy_haptics/fluxy_haptics.dart` |
| Logger | `debugPrint` | `package:fluxy_logger/fluxy_logger.dart` |
| Device | `DeviceInfo` | `package:fluxy_device/fluxy_device.dart` |

## Migration Steps

### Step 1: Update Dependencies

Add the new packages to your `pubspec.yaml`:

```yaml
dependencies:
  fluxy: ^1.1.0
  
  # Add these if you were using them before
  fluxy_test: ^1.1.0
  fluxy_camera: ^1.1.0
  fluxy_auth: ^1.1.0
  fluxy_notifications: ^1.1.0
  fluxy_storage: ^1.1.0
  fluxy_connectivity: ^1.1.0
  fluxy_analytics: ^1.1.0
  fluxy_biometric: ^1.1.0
  fluxy_ota: ^1.1.0
  fluxy_haptics: ^1.1.0
  fluxy_logger: ^1.1.0
  fluxy_device: ^1.1.0
```

### Step 2: Update Imports

#### Testing
```dart
// BEFORE
import 'package:fluxy/fx_test_utils.dart';

// AFTER
import 'package:fluxy_test/fluxy_test.dart';
```

#### Hardware Plugins
```dart
// BEFORE
final image = await Fx.camera.capture();
final auth = await Fx.auth.authenticate();
await Fx.notifications.show('Title', 'Body');

// AFTER (The Industrial Right Way)
final image = await Fx.platform.camera.fullView(context: context);
final auth = await Fx.platform.auth.login(email, pass);
await Fx.platform.notifications.show('Title', 'Body');
```

### Step 3: Update API Calls

#### Camera
```dart
// BEFORE
final image = await Fx.camera.capture();

// AFTER
import 'package:fluxy_camera/fluxy_camera.dart';
final image = await FluxyCamera.capture();
```

#### Authentication
```dart
// BEFORE
final isAuthenticated = await Fx.auth.authenticate();

// AFTER
import 'package:fluxy_auth/fluxy_auth.dart';
final isAuthenticated = await FluxyAuth.authenticate();
```

#### Storage
```dart
// BEFORE
await Fx.storage.set('key', 'value');
final value = await Fx.storage.get('key');

// AFTER
import 'package:fluxy_storage/fluxy_storage.dart';
await FluxyStorage.set('key', 'value');
final value = await FluxyStorage.get('key');
```

## Compatibility Layer

Fluxy v1.0.0 includes a temporary compatibility layer that will show deprecation warnings but won't break your existing code immediately.

```dart
// This still works but shows deprecation warnings
final image = await FxCamera.capture(); // Deprecated: Use fluxy_camera package
```

The compatibility layer will be removed in v2.0.0.

## Benefits of v1.0.0

1. **Smaller Core Package**: ~170KB vs 15MB+ (faster installation)
2. **Modular Dependencies**: Only install what you need
3. **Better Performance**: Reduced bundle size
4. **Independent Versioning**: Each package can evolve separately
5. **Clearer Architecture**: Separated concerns

## Need Help?

- **GitHub Issues**: https://github.com/swaingithub/fluxy/issues
- **Documentation**: https://github.com/swaingithub/fluxy
- **Migration Support**: Create an issue with the tag "migration-help"

---

# Migration Guide: Fluxy v1.0.x → v1.1.0 (Latest)

Fluxy v1.1.0 is a feature-rich update that introduces the **Stability Kernel™** and several new high-performance modules. Migration is seamless as there are no breaking API changes, only new capabilities to opt into.

## New Modules

If you need the new real-time or stability features, add these to your `pubspec.yaml`:

```yaml
dependencies:
  fluxy: ^1.1.0
  fluxy_websocket: ^1.1.0    # Real-time communication
  fluxy_sync: ^1.1.0         # Offline-first synchronization
  fluxy_presence: ^1.1.0     # User presence tracking
  fluxy_geo: ^1.1.0          # Geofencing and location
  fluxy_stream_bridge: ^1.1.0 # Reactive Stream adapter
```

## Stability Kernel™

The Stability Kernel is enabled by default. You can configure its sensitivity in your `main()` function:

```dart
void main() async {
  await Fluxy.init(
    // Optional: Configure Kernel sensitivity
    strictMode: false, // Set to true to throw errors instead of auto-repairing
  );
  runApp(FluxyApp(routes: appRoutes));
}
```

## Managed Resource Manager

v1.1.0 introduces `FluxyResourceManager` for handling hardware lifecycles. 

**Before (Manual):**
```dart
@override
void dispose() {
  myController.dispose();
  super.dispose();
}
```

**After (Managed):**
```dart
// Resources are automatically cleaned up when the app enters deep sleep
final socket = FluxyResourceManager.websocket('wss://api.example.com');
```

---

## [DONE] Welcome to Fluxy v1.1.0!

Thank you for upgrading! The new Stability Kernel and real-time modules make Fluxy the most resilient platform for professional Flutter development.
