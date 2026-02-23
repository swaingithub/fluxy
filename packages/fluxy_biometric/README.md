# fluxy_biometric

Biometric authentication plugin for the Fluxy framework, providing secure and convenient biometric authentication using fingerprint, face recognition, and other biometric methods.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  fluxy_biometric: ^1.0.0
```

## Usage

First, ensure you have Fluxy initialized and the biometric plugin registered:

```dart
import 'package:fluxy/fluxy.dart';

void main() async {
  await Fluxy.init();
  Fluxy.autoRegister(); // Registers all available plugins including biometric
  
  runApp(MyApp());
}
```

### Basic Biometric Authentication

```dart
import 'package:fluxy/fluxy.dart';

class BiometricService {
  // Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await Fx.biometric.isAvailable;
      if (isAvailable) {
        Fx.toast.success('Biometric authentication is available');
      } else {
        Fx.toast.info('Biometric authentication is not available');
      }
      return isAvailable;
    } catch (e) {
      Fx.toast.error('Failed to check biometric availability: $e');
      return false;
    }
  }
  
  // Authenticate with biometrics
  Future<bool> authenticateWithBiometrics() async {
    try {
      final isAuthenticated = await Fx.biometric.authenticate(
        reason: 'Authenticate to access secure features',
        options: BiometricOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      
      if (isAuthenticated) {
        Fx.toast.success('Authentication successful');
      } else {
        Fx.toast.error('Authentication failed');
      }
      
      return isAuthenticated;
    } catch (e) {
      Fx.toast.error('Biometric authentication failed: $e');
      return false;
    }
  }
  
  // Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final biometrics = await Fx.biometric.getAvailableBiometrics();
      final types = biometrics.map((b) => b.toString()).join(', ');
      Fx.toast.success('Available biometrics: $types');
      return biometrics;
    } catch (e) {
      Fx.toast.error('Failed to get available biometrics: $e');
      return [];
    }
  }
}
```

### Advanced Biometric Features

```dart
class AdvancedBiometricService {
  // Authenticate with custom options
  Future<bool> authenticateWithCustomOptions() async {
    try {
      final isAuthenticated = await Fx.biometric.authenticate(
        reason: 'Please authenticate to continue',
        options: BiometricOptions(
          useErrorDialogs: false,
          stickyAuth: false,
          biometricOnly: true,
          sensitiveTransaction: true,
        ),
      );
      
      return isAuthenticated;
    } catch (e) {
      Fx.toast.error('Custom biometric authentication failed: $e');
      return false;
    }
  }
  
  // Check if device has specific biometric type
  Future<bool> hasFingerprint() async {
    try {
      final biometrics = await Fx.biometric.getAvailableBiometrics();
      return biometrics.contains(BiometricType.fingerprint);
    } catch (e) {
      Fx.toast.error('Failed to check fingerprint availability: $e');
      return false;
    }
  }
  
  Future<bool> hasFaceRecognition() async {
    try {
      final biometrics = await Fx.biometric.getAvailableBiometrics();
      return biometrics.contains(BiometricType.face);
    } catch (e) {
      Fx.toast.error('Failed to check face recognition availability: $e');
      return false;
    }
  }
  
  // Stop authentication process
  Future<void> stopAuthentication() async {
    try {
      await Fx.biometric.stopAuthentication();
      Fx.toast.info('Authentication stopped');
    } catch (e) {
      Fx.toast.error('Failed to stop authentication: $e');
    }
  }
}
```

### Biometric Security Management

```dart
class BiometricSecurityService {
  // Enable biometric authentication for app
  Future<void> enableBiometricAuthentication() async {
    try {
      // First check if biometrics are available
      final isAvailable = await Fx.biometric.isAvailable;
      if (!isAvailable) {
        Fx.toast.error('Biometric authentication is not available');
        return;
      }
      
      // Authenticate to enable biometrics
      final isAuthenticated = await Fx.biometric.authenticate(
        reason: 'Authenticate to enable biometric login',
        options: BiometricOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
      
      if (isAuthenticated) {
        // Store biometric preference
        await Fx.storage.setSecure('biometric_enabled', 'true');
        Fx.toast.success('Biometric authentication enabled');
      } else {
        Fx.toast.error('Failed to enable biometric authentication');
      }
    } catch (e) {
      Fx.toast.error('Failed to enable biometric authentication: $e');
    }
  }
  
  // Disable biometric authentication
  Future<void> disableBiometricAuthentication() async {
    try {
      await Fx.storage.removeSecure('biometric_enabled');
      Fx.toast.success('Biometric authentication disabled');
    } catch (e) {
      Fx.toast.error('Failed to disable biometric authentication: $e');
    }
  }
  
  // Check if biometric authentication is enabled
  Future<bool> isBiometricEnabled() async {
    try {
      final isEnabled = await Fx.storage.getSecure('biometric_enabled');
      return isEnabled == 'true';
    } catch (e) {
      Fx.toast.error('Failed to check biometric status: $e');
      return false;
    }
  }
  
  // Biometric login flow
  Future<bool> biometricLogin() async {
    try {
      // Check if biometric is enabled
      final isEnabled = await isBiometricEnabled();
      if (!isEnabled) {
        Fx.toast.info('Biometric authentication is not enabled');
        return false;
      }
      
      // Check if biometrics are available
      final isAvailable = await Fx.biometric.isAvailable;
      if (!isAvailable) {
        Fx.toast.error('Biometric authentication is not available');
        return false;
      }
      
      // Authenticate
      final isAuthenticated = await Fx.biometric.authenticate(
        reason: 'Login with biometrics',
        options: BiometricOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      
      if (isAuthenticated) {
        Fx.toast.success('Biometric login successful');
        return true;
      } else {
        Fx.toast.error('Biometric login failed');
        return false;
      }
    } catch (e) {
      Fx.toast.error('Biometric login failed: $e');
      return false;
    }
  }
}
```

### Biometric Settings Screen

```dart
import 'package:fluxy/fluxy.dart';

class BiometricSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Biometric Settings')),
      body: Fx.col([
        Fx.card([
          Fx.col([
            Fx.text('Biometric Authentication').font.lg().bold(),
            Fx.text('Use your fingerprint or face to authenticate').font.sm().muted(),
            Fx.switcher(
              flux(false).listen((value) async {
                if (value) {
                  await BiometricSecurityService().enableBiometricAuthentication();
                } else {
                  await BiometricSecurityService().disableBiometricAuthentication();
                }
              }),
              'Enable Biometric Authentication',
            ).gap(2),
          ]).gap(2),
        ]).gap(2),
        
        Fx.card([
          Fx.col([
            Fx.text('Available Biometrics').font.lg().bold(),
            Fx.button('Check Available Biometrics')
              .onTap(() async {
                final biometrics = await Fx.biometric.getAvailableBiometrics();
                final types = biometrics.map((b) => b.toString()).join(', ');
                Fx.toast.success('Available: $types');
              }),
          ]).gap(2),
        ]).gap(2),
        
        Fx.card([
          Fx.col([
            Fx.text('Test Authentication').font.lg().bold(),
            Fx.button('Test Biometric Authentication')
              .onTap(() async {
                final success = await Fx.biometric.authenticate(
                  reason: 'Test biometric authentication',
                );
                if (success) {
                  Fx.toast.success('Test successful');
                } else {
                  Fx.toast.error('Test failed');
                }
              }),
          ]).gap(2),
        ]).gap(2),
      ]).gap(2).p(2),
    );
  }
}
```

## Features

- **Biometric Authentication**: Support for fingerprint, face recognition, and other biometric methods
- **Security Options**: Configurable authentication options for different security levels
- **Availability Check**: Check if biometric authentication is available on the device
- **Type Detection**: Detect available biometric types on the device
- **Error Handling**: Comprehensive error handling with user-friendly messages
- **Cross-Platform**: Works on both iOS and Android devices
- **Integration**: Seamless integration with Fluxy storage for preferences

## API Reference

### Methods

- `isAvailable` - Check if biometric authentication is available
- `getAvailableBiometrics()` - Get list of available biometric types
- `authenticate(String reason, {BiometricOptions options})` - Authenticate with biometrics
- `stopAuthentication()` - Stop ongoing authentication process

### Properties

- `isAvailable` - Check if biometric authentication is available

### Biometric Types

- `BiometricType.fingerprint` - Fingerprint authentication
- `BiometricType.face` - Face recognition
- `BiometricType.iris` - Iris recognition
- `BiometricType.strong` - Strong biometric authentication
- `BiometricType.weak` - Weak biometric authentication

### Biometric Options

- `useErrorDialogs` - Show error dialogs for authentication failures
- `stickyAuth` - Keep authentication sticky until success or failure
- `biometricOnly` - Use biometric authentication only (no device PIN)
- `sensitiveTransaction` - Mark as sensitive transaction

## Error Handling

The biometric plugin provides comprehensive error handling:

```dart
try {
  await Fx.biometric.authenticate(reason: 'Authenticate');
} on BiometricException catch (e) {
  // Handle specific biometric errors
  switch (e.type) {
    case BiometricErrorType.notAvailable:
      Fx.toast.error('Biometric authentication is not available');
      break;
    case BiometricErrorType.notEnrolled:
      Fx.toast.error('No biometrics enrolled on this device');
      break;
    case BiometricErrorType.lockedOut:
      Fx.toast.error('Biometric authentication is locked out');
      break;
    case BiometricErrorType.permanentlyLockedOut:
      Fx.toast.error('Biometric authentication is permanently locked out');
      break;
    default:
      Fx.toast.error('Biometric error: $e');
  }
} catch (e) {
  Fx.toast.error('Unexpected biometric error: $e');
}
```

## Platform Configuration

### Android

Add the following to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.USE_FINGERPRINT" />
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
```

### iOS

Add the following to your `Info.plist`:

```xml
<key>NSFaceIDUsageDescription</key>
<string>This app uses Face ID for secure authentication</string>
```

## Security Considerations

- All biometric operations use platform-specific secure authentication
- Biometric data is never stored or transmitted
- Authentication results are handled securely
- Sensitive transactions can be marked for additional security
- Proper fallback to device PIN when biometrics fail

## License

This package is licensed under the MIT License. See the LICENSE file for details.
