# Migration Guide: Fluxy v0.2.6 → v1.0.0

This guide helps you migrate your Fluxy applications from v0.2.6 to v1.0.0.

## 🚨 Breaking Changes

Fluxy v1.0.0 introduces a modular architecture with separate packages for different features.

### 📦 Package Structure Changes

| Feature | v0.2.6 (Single Package) | v1.0.0 (Modular) |
|---------|--------------------------|-------------------|
| Forms & Validation | `package:fluxy/fx_validation.dart` | `package:fluxy_forms/fluxy_forms.dart` |
| Component Library | `package:fluxy/fx_components.dart` | `package:fluxy_components/fluxy_components.dart` |
| Testing Utilities | `package:fluxy/fx_test_utils.dart` | `package:fluxy_test/fluxy_test.dart` |
| Camera Plugin | `Fx.camera` | `package:fluxy_camera/fluxy_camera.dart` |
| Auth Plugin | `Fx.auth` | `package:fluxy_auth/fluxy_auth.dart` |
| Notifications | `Fx.notifications` | `package:fluxy_notifications/fluxy_notifications.dart` |
| Storage | `Fx.storage` | `package:fluxy_storage/fluxy_storage.dart` |

## 🛠️ Migration Steps

### Step 1: Update Dependencies

Add the new packages to your `pubspec.yaml`:

```yaml
dependencies:
  fluxy: ^1.0.0
  
  # Add these if you were using them before
  fluxy_forms: ^1.0.0
  fluxy_components: ^1.0.0
  fluxy_test: ^1.0.0
  fluxy_camera: ^1.0.0
  fluxy_auth: ^1.0.0
  fluxy_notifications: ^1.0.0
  fluxy_storage: ^1.0.0
```

### Step 2: Update Imports

#### Forms and Validation
```dart
// BEFORE
import 'package:fluxy/fx_validation.dart';

// AFTER
import 'package:fluxy_forms/fluxy_forms.dart';
```

#### Components
```dart
// BEFORE
import 'package:fluxy/fx_components.dart';

// AFTER
import 'package:fluxy_components/fluxy_components.dart';
```

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

// AFTER
import 'package:fluxy_camera/fluxy_camera.dart';
import 'package:fluxy_auth/fluxy_auth.dart';
import 'package:fluxy_notifications/fluxy_notifications.dart';

final image = await FluxyCamera.capture();
final auth = await FluxyAuth.authenticate();
await FluxyNotifications.show('Title', 'Body');
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

## 🔄 Compatibility Layer

Fluxy v1.0.0 includes a temporary compatibility layer that will show deprecation warnings but won't break your existing code immediately.

```dart
// This still works but shows deprecation warnings
final image = await FxCamera.capture(); // Deprecated: Use fluxy_camera package
```

The compatibility layer will be removed in v2.0.0.

## 🎯 Benefits of v1.0.0

1. **Smaller Core Package**: ~170KB vs 15MB+ (faster installation)
2. **Modular Dependencies**: Only install what you need
3. **Better Performance**: Reduced bundle size
4. **Independent Versioning**: Each package can evolve separately
5. **Clearer Architecture**: Separated concerns

## 🆘 Need Help?

- **GitHub Issues**: https://github.com/swaingithub/fluxy/issues
- **Documentation**: https://github.com/swaingithub/fluxy
- **Migration Support**: Create an issue with the tag "migration-help"

## ⏰ Timeline

- **v1.0.0**: Breaking changes with compatibility layer
- **v1.5.0**: Enhanced features in separate packages
- **v2.0.0**: Compatibility layer removed (planned for 6 months after v1.0.0)

## 🎉 Welcome to Fluxy v1.0.0!

Thank you for upgrading! The new modular architecture provides better performance, flexibility, and maintainability for professional Flutter applications.
