# fluxy_platform

A meta-package for the Fluxy framework that includes the core engine and all official plugins in a single convenient package.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  fluxy_platform: ^1.0.0
```

## Usage

First, ensure you have Fluxy initialized:

```dart
import 'package:fluxy_platform/fluxy_platform.dart';

void main() async {
  await Fluxy.init();
  Fluxy.autoRegister(); // Registers all available plugins
  
  runApp(MyApp());
}
```

## What's Included

The fluxy_platform package includes:

### Core Framework
- **fluxy**: The core Fluxy framework with reactive state management, DSL, routing, and HTTP client

### Authentication & Security
- **fluxy_auth**: Authentication plugin with email/password and social login support
- **fluxy_biometric**: Biometric authentication using fingerprint and face recognition
- **fluxy_permissions**: Permission management for camera, storage, location, and more

### Media & Hardware
- **fluxy_camera**: Camera plugin for photo capture, video recording, and gallery integration
- **fluxy_notifications**: Push and local notifications with scheduling and styling options

### Data & Storage
- **fluxy_storage**: Unified storage with secure and non-secure options
- **fluxy_analytics**: Analytics tracking for user behavior and app performance

### Connectivity & Platform
- **fluxy_connectivity**: Network connectivity monitoring and management
- **fluxy_ota**: Over-the-air updates and hot reload capabilities

## Features

### Complete Framework Access
```dart
// Authentication
await Fx.auth.signIn(email, password);
await Fx.biometric.authenticate();

// Permissions
await Fx.permissions.request(FluxyPermission.camera);
await Fx.permissions.requestAll([...]);

// Camera
await Fx.camera.capturePhoto();
await Fx.camera.startVideoRecording();

// Notifications
await Fx.notifications.show(title: 'Hello', body: 'World');
await Fx.notifications.schedule(...);

// Storage
await Fx.storage.set('key', 'value');
await Fx.storage.setSecure('token', 'auth_token');

// Analytics
await Fx.analytics.track('event_name', parameters: {...});

// Connectivity
final isConnected = await Fx.connectivity.isConnected;
Fx.connectivity.connectivityChanges.listen(...);
```

### Platform Integration
```dart
// Platform-specific operations
final platformInfo = await Fx.platform.getDeviceInfo();
final appVersion = await Fx.platform.getAppVersion();

// OTA updates
await Fx.ota.checkForUpdates();
await Fx.ota.downloadAndInstall();
```

## Benefits of Using fluxy_platform

### Convenience
- Single dependency for all Fluxy functionality
- Automatic version compatibility between packages
- Simplified dependency management

### Compatibility
- All plugins tested together for compatibility
- Unified API across all modules
- Consistent error handling and patterns

### Performance
- Optimized package loading
- Reduced dependency resolution time
- Shared resources between plugins

## Individual Packages vs Platform Package

### Use Individual Packages When:
- You need only specific functionality
- You want to minimize app size
- You prefer fine-grained dependency control

### Use Platform Package When:
- You need comprehensive Fluxy functionality
- You want simplified dependency management
- You prefer automatic version compatibility

## Migration from Individual Packages

If you're currently using individual Fluxy packages, you can easily migrate:

### Before (Individual Packages)
```yaml
dependencies:
  fluxy: ^1.0.0
  fluxy_auth: ^1.0.0
  fluxy_camera: ^1.0.0
  fluxy_permissions: ^1.0.0
  # ... other packages
```

### After (Platform Package)
```yaml
dependencies:
  fluxy_platform: ^1.0.0
```

The imports remain the same:
```dart
import 'package:fluxy/fluxy.dart';
import 'package:fluxy_platform/fluxy_platform.dart';
```

## API Reference

Since fluxy_platform includes all individual packages, you have access to all their APIs:

### Authentication
- `Fx.auth.signIn()`, `Fx.auth.signOut()`
- `Fx.biometric.authenticate()`

### Permissions
- `Fx.permissions.request()`, `Fx.permissions.statusOf()`

### Camera
- `Fx.camera.capturePhoto()`, `Fx.camera.pickImageFromGallery()`

### Notifications
- `Fx.notifications.show()`, `Fx.notifications.schedule()`

### Storage
- `Fx.storage.set()`, `Fx.storage.get()`
- `Fx.storage.setSecure()`, `Fx.storage.getSecure()`

### Analytics
- `Fx.analytics.track()`, `Fx.analytics.trackScreen()`

### Connectivity
- `Fx.connectivity.isConnected`, `Fx.connectivity.connectivityChanges`

### Platform
- `Fx.platform.getDeviceInfo()`, `Fx.platform.getAppVersion()`

### OTA
- `Fx.ota.checkForUpdates()`, `Fx.ota.downloadAndInstall()`

## Error Handling

The platform package provides unified error handling across all modules:

```dart
try {
  await Fx.auth.signIn(email, password);
} catch (e) {
  // Handle authentication errors
}

try {
  await Fx.camera.capturePhoto();
} catch (e) {
  // Handle camera errors
}

try {
  await Fx.notifications.show(title: 'Test', body: 'Message');
} catch (e) {
  // Handle notification errors
}
```

## Platform Support

All included packages support:
- **iOS**: Full native integration
- **Android**: Complete API support
- **Web**: Limited support where applicable

## License

This package is licensed under the MIT License. See the LICENSE file for details.

## Individual Package Licenses

Each included package maintains its own MIT License. Refer to individual package documentation for specific licensing information.
