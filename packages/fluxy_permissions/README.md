# fluxy_permissions

Permission management plugin for the Fluxy framework, providing a unified API for handling device permissions across iOS and Android platforms.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  fluxy_permissions: ^1.0.0
```

## Usage

First, ensure you have Fluxy initialized and the permissions plugin registered:

```dart
import 'package:fluxy/fluxy.dart';

void main() async {
  await Fluxy.init();
  Fluxy.autoRegister(); // Registers all available plugins including permissions
  
  runApp(MyApp());
}
```

### Basic Permission Management

```dart
import 'package:fluxy/fluxy.dart';

class PermissionService {
  // Request single permission
  Future<bool> requestCameraPermission() async {
    try {
      final status = await Fx.permissions.request(FluxyPermission.camera);
      if (status == FluxyPermissionStatus.granted) {
        Fx.toast.success('Camera permission granted');
        return true;
      } else {
        Fx.toast.error('Camera permission denied');
        return false;
      }
    } catch (e) {
      Fx.toast.error('Permission request failed: $e');
      return false;
    }
  }
  
  // Check permission status
  Future<bool> checkPermission(FluxyPermission permission) async {
    try {
      final status = await Fx.permissions.statusOf(permission);
      return status == FluxyPermissionStatus.granted;
    } catch (e) {
      Fx.toast.error('Permission check failed: $e');
      return false;
    }
  }
  
  // Request multiple permissions
  Future<Map<FluxyPermission, FluxyPermissionStatus>> requestMultiplePermissions() async {
    try {
      final results = await Fx.permissions.requestAll([
        FluxyPermission.camera,
        FluxyPermission.microphone,
        FluxyPermission.storage,
        FluxyPermission.location,
      ]);
      
      // Check results
      for (final entry in results.entries) {
        final permission = entry.key;
        final status = entry.value;
        
        if (status == FluxyPermissionStatus.granted) {
          Fx.toast.success('${permission.toString()} granted');
        } else {
          Fx.toast.error('${permission.toString()} denied');
        }
      }
      
      return results;
    } catch (e) {
      Fx.toast.error('Multiple permission request failed: $e');
      return {};
    }
  }
}
```

### Permission Status Monitoring

```dart
class PermissionMonitor {
  // Listen to permission status changes
  void startPermissionMonitoring() {
    Fx.permissions.statusChanges.listen((permissionChange) {
      final permission = permissionChange.permission;
      final status = permissionChange.status;
      
      switch (status) {
        case FluxyPermissionStatus.granted:
          Fx.toast.success('${permission.toString()} granted');
          break;
        case FluxyPermissionStatus.denied:
          Fx.toast.warning('${permission.toString()} denied');
          break;
        case FluxyPermissionStatus.permanentlyDenied:
          Fx.toast.error('${permission.toString()} permanently denied');
          _showSettingsDialog();
          break;
        case FluxyPermissionStatus.restricted:
          Fx.toast.error('${permission.toString()} restricted');
          break;
      }
    });
  }
  
  // Show settings dialog for permanently denied permissions
  void _showSettingsDialog() {
    Fx.dialog.confirm(
      'Permission Required',
      'This permission is required for the app to function properly. Please enable it in settings.',
      onConfirm: () => Fx.permissions.openSettings(),
      confirmText: 'Open Settings',
      cancelText: 'Cancel',
    );
  }
}
```

### Advanced Permission Handling

```dart
class AdvancedPermissionService {
  // Request permission with rationale
  Future<bool> requestWithRationale(FluxyPermission permission, String rationale) async {
    try {
      // Check if permission is already granted
      final status = await Fx.permissions.statusOf(permission);
      if (status == FluxyPermissionStatus.granted) {
        return true;
      }
      
      // Show rationale dialog
      final shouldProceed = await Fx.dialog.confirm(
        'Permission Required',
        rationale,
        confirmText: 'Grant Permission',
        cancelText: 'Cancel',
      );
      
      if (!shouldProceed) {
        return false;
      }
      
      // Request permission
      final newStatus = await Fx.permissions.request(permission);
      return newStatus == FluxyPermissionStatus.granted;
      
    } catch (e) {
      Fx.toast.error('Permission request failed: $e');
      return false;
    }
  }
  
  // Handle permanently denied permissions
  Future<bool> handlePermanentlyDenied(FluxyPermission permission) async {
    try {
      final status = await Fx.permissions.statusOf(permission);
      
      if (status == FluxyPermissionStatus.permanentlyDenied) {
        final shouldOpenSettings = await Fx.dialog.confirm(
          'Permission Permanently Denied',
          'This permission was permanently denied. Please enable it in app settings.',
          confirmText: 'Open Settings',
          cancelText: 'Cancel',
        );
        
        if (shouldOpenSettings) {
          await Fx.permissions.openSettings();
          return true;
        }
      }
      
      return false;
    } catch (e) {
      Fx.toast.error('Failed to handle permanently denied permission: $e');
      return false;
    }
  }
}
```

### Permission Utilities

```dart
class PermissionUtils {
  // Check if any permissions are granted
  Future<bool> hasAnyPermission(List<FluxyPermission> permissions) async {
    for (final permission in permissions) {
      final status = await Fx.permissions.statusOf(permission);
      if (status == FluxyPermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }
  
  // Check if all permissions are granted
  Future<bool> hasAllPermissions(List<FluxyPermission> permissions) async {
    for (final permission in permissions) {
      final status = await Fx.permissions.statusOf(permission);
      if (status != FluxyPermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }
  
  // Get denied permissions
  Future<List<FluxyPermission>> getDeniedPermissions(List<FluxyPermission> permissions) async {
    final denied = <FluxyPermission>[];
    
    for (final permission in permissions) {
      final status = await Fx.permissions.statusOf(permission);
      if (status != FluxyPermissionStatus.granted) {
        denied.add(permission);
      }
    }
    
    return denied;
  }
}
```

## Features

- **Unified API**: Single interface for all platform permissions
- **Batch Requests**: Request multiple permissions at once
- **Status Monitoring**: Real-time permission status changes
- **Cross-Platform**: Works on both iOS and Android
- **Error Handling**: Comprehensive error handling with specific error types
- **User-Friendly**: Built-in dialogs and toast notifications
- **Settings Integration**: Direct access to app settings for permanently denied permissions
- **Permission Types**: Support for all common device permissions

## API Reference

### Methods

- `request(FluxyPermission)` - Request a single permission
- `requestAll(List<FluxyPermission>)` - Request multiple permissions
- `statusOf(FluxyPermission)` - Get current status of a permission
- `isGranted(FluxyPermission)` - Check if permission is granted
- `openSettings()` - Open app settings
- `shouldShowRationale(FluxyPermission)` - Check if rationale should be shown

### Properties

- `statusChanges` - Stream of permission status changes

### Permission Types

- `FluxyPermission.camera` - Camera access
- `FluxyPermission.microphone` - Microphone access
- `FluxyPermission.storage` - Storage access
- `FluxyPermission.location` - Location access
- `FluxyPermission.photos` - Photo library access
- `FluxyPermission.contacts` - Contacts access
- `FluxyPermission.notifications` - Push notifications
- `FluxyPermission.phone` - Phone access
- `FluxyPermission.sms` - SMS access
- `FluxyPermission.calendar` - Calendar access

### Permission Status

- `FluxyPermissionStatus.granted` - Permission granted
- `FluxyPermissionStatus.denied` - Permission denied
- `FluxyPermissionStatus.permanentlyDenied` - Permission permanently denied
- `FluxyPermissionStatus.restricted` - Permission restricted
- `FluxyPermissionStatus.limited` - Permission limited (iOS 14+)

## Error Handling

The permissions plugin provides comprehensive error handling:

```dart
try {
  await Fx.permissions.request(FluxyPermission.camera);
} on PermissionException catch (e) {
  // Handle specific permission errors
  switch (e.type) {
    case PermissionErrorType.disabled:
      Fx.toast.error('Permission service is disabled');
      break;
    case PermissionErrorType.denied:
      Fx.toast.error('Permission was denied');
      break;
    case PermissionErrorType.permanentlyDenied:
      Fx.toast.error('Permission was permanently denied');
      break;
    case PermissionErrorType.restricted:
      Fx.toast.error('Permission is restricted');
      break;
    default:
      Fx.toast.error('Permission error: $e');
  }
} catch (e) {
  Fx.toast.error('Unexpected permission error: $e');
}
```

## Platform Configuration

### Android

Add the following permissions to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS

Add the following permissions to your `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take photos</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to record audio</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to provide location-based features</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to select images</string>
```

## Security Considerations

- All permission requests require explicit user consent
- Permission status is monitored in real-time
- Sensitive permissions require additional user confirmation
- No unauthorized background permission access
- Proper handling of permanently denied permissions

## License

This package is licensed under the MIT License. See the LICENSE file for details.
