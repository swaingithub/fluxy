# fluxy_camera

Camera plugin for the Fluxy framework, providing comprehensive camera functionality including photo capture, video recording, and gallery integration.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  fluxy_camera: ^1.0.0
```

## Usage

First, ensure you have Fluxy initialized and the camera plugin registered:

```dart
import 'package:fluxy/fluxy.dart';

void main() async {
  await Fluxy.init();
  Fluxy.autoRegister(); // Registers all available plugins including camera
  
  runApp(MyApp());
}
```

### Basic Camera Operations

```dart
import 'package:fluxy/fluxy.dart';

class CameraService {
  // Initialize camera
  Future<void> initializeCamera() async {
    try {
      await Fx.camera.initialize();
      Fx.toast.success('Camera initialized successfully');
    } catch (e) {
      Fx.toast.error('Camera initialization failed: $e');
    }
  }
  
  // Capture photo
  Future<String?> capturePhoto() async {
    try {
      final imagePath = await Fx.camera.capturePhoto();
      if (imagePath != null) {
        Fx.toast.success('Photo captured successfully');
        return imagePath;
      }
      return null;
    } catch (e) {
      Fx.toast.error('Photo capture failed: $e');
      return null;
    }
  }
  
  // Start video recording
  Future<void> startVideoRecording() async {
    try {
      await Fx.camera.startVideoRecording();
      Fx.toast.success('Video recording started');
    } catch (e) {
      Fx.toast.error('Video recording failed to start: $e');
    }
  }
  
  // Stop video recording
  Future<String?> stopVideoRecording() async {
    try {
      final videoPath = await Fx.camera.stopVideoRecording();
      if (videoPath != null) {
        Fx.toast.success('Video recording stopped');
        return videoPath;
      }
      return null;
    } catch (e) {
      Fx.toast.error('Video recording failed to stop: $e');
      return null;
    }
  }
  
  // Dispose camera
  void disposeCamera() {
    Fx.camera.dispose();
  }
}
```

### Gallery Integration

```dart
class GalleryService {
  // Pick image from gallery
  Future<String?> pickImageFromGallery() async {
    try {
      final imagePath = await Fx.camera.pickImageFromGallery();
      if (imagePath != null) {
        Fx.toast.success('Image selected from gallery');
        return imagePath;
      }
      return null;
    } catch (e) {
      Fx.toast.error('Gallery image selection failed: $e');
      return null;
    }
  }
  
  // Pick video from gallery
  Future<String?> pickVideoFromGallery() async {
    try {
      final videoPath = await Fx.camera.pickVideoFromGallery();
      if (videoPath != null) {
        Fx.toast.success('Video selected from gallery');
        return videoPath;
      }
      return null;
    } catch (e) {
      Fx.toast.error('Gallery video selection failed: $e');
      return null;
    }
  }
}
```

### Camera Configuration

```dart
class CameraConfiguration {
  // Set camera resolution
  Future<void> setResolution(ResolutionPreset resolution) async {
    try {
      await Fx.camera.setResolution(resolution);
      Fx.toast.success('Camera resolution updated');
    } catch (e) {
      Fx.toast.error('Failed to set resolution: $e');
    }
  }
  
  // Switch between front and back camera
  Future<void> switchCamera() async {
    try {
      await Fx.camera.switchCamera();
      Fx.toast.success('Camera switched');
    } catch (e) {
      Fx.toast.error('Failed to switch camera: $e');
    }
  }
  
  // Toggle flash
  Future<void> toggleFlash() async {
    try {
      await Fx.camera.toggleFlash();
      Fx.toast.success('Flash toggled');
    } catch (e) {
      Fx.toast.error('Failed to toggle flash: $e');
    }
  }
  
  // Set focus mode
  Future<void> setFocusMode(FocusMode mode) async {
    try {
      await Fx.camera.setFocusMode(mode);
      Fx.toast.success('Focus mode set');
    } catch (e) {
      Fx.toast.error('Failed to set focus mode: $e');
    }
  }
}
```

### Camera Preview Widget

```dart
import 'package:fluxy/fluxy.dart';

class CameraPreviewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Camera')),
      body: Fx.col([
        // Camera preview widget
        Fx.camera.preview(
          width: double.infinity,
          height: 300,
        ),
        
        // Camera controls
        Fx.row([
          Fx.button('Capture Photo')
            .onTap(() async {
              final path = await Fx.camera.capturePhoto();
              if (path != null) {
                // Handle captured photo
              }
            }),
            
          Fx.button('Gallery')
            .onTap(() async {
              final path = await Fx.camera.pickImageFromGallery();
              if (path != null) {
                // Handle selected image
              }
            }),
            
          Fx.button('Switch Camera')
            .onTap(() async {
              await Fx.camera.switchCamera();
            }),
        ]).gap(2).center(),
      ]).gap(2).p(2),
    );
  }
}
```

## Features

- **Photo Capture**: High-quality photo capture with configurable resolution
- **Video Recording**: Video recording with duration and quality controls
- **Gallery Integration**: Pick images and videos from device gallery
- **Camera Controls**: Switch cameras, toggle flash, set focus modes
- **Preview Widget**: Built-in camera preview widget for easy integration
- **Error Handling**: Comprehensive error handling with user-friendly messages
- **Permission Management**: Automatic camera permission handling
- **Cross-Platform**: Works on both iOS and Android devices

## API Reference

### Methods

- `initialize()` - Initialize camera with default settings
- `capturePhoto()` - Capture a photo and return file path
- `startVideoRecording()` - Start recording video
- `stopVideoRecording()` - Stop recording and return video file path
- `pickImageFromGallery()` - Pick image from device gallery
- `pickVideoFromGallery()` - Pick video from device gallery
- `switchCamera()` - Switch between front and back camera
- `toggleFlash()` - Toggle camera flash on/off
- `setResolution(ResolutionPreset)` - Set camera resolution
- `setFocusMode(FocusMode)` - Set camera focus mode
- `dispose()` - Dispose camera resources

### Properties

- `isInitialized` - Check if camera is initialized
- `isRecording` - Check if currently recording video
- `currentCamera` - Get current camera (front/back)
- `flashMode` - Get current flash mode

### Widgets

- `Fx.camera.preview()` - Camera preview widget

## Error Handling

The camera plugin provides comprehensive error handling:

```dart
try {
  await Fx.camera.capturePhoto();
} on CameraException catch (e) {
  // Handle specific camera errors
  switch (e.code) {
    case 'CameraAccessDenied':
      Fx.toast.error('Camera access denied. Please check permissions.');
      break;
    case 'CameraAccessRestricted':
      Fx.toast.error('Camera access is restricted.');
      break;
    case 'NoCameraAvailable':
      Fx.toast.error('No camera available on this device.');
      break;
    default:
      Fx.toast.error('Camera error: ${e.description}');
  }
} catch (e) {
  Fx.toast.error('Unexpected camera error: $e');
}
```

## Permissions

The camera plugin automatically handles camera permissions:

```dart
// Check camera permission status
final hasPermission = await Fx.camera.hasPermission;

// Request camera permission
final permissionGranted = await Fx.camera.requestPermission();

if (permissionGranted) {
  // Camera permission granted, proceed with camera operations
} else {
  // Camera permission denied, show message to user
  Fx.toast.error('Camera permission is required to use camera features');
}
```

## Platform Support

- **iOS**: Full camera functionality with native integration
- **Android**: Complete camera support including front/back cameras
- **Web**: Limited support (camera preview and basic capture)

## Security Considerations

- All camera operations require explicit user permission
- Captured media is stored in secure device locations
- Camera resources are properly disposed when not in use
- No unauthorized background camera access

## License

This package is licensed under the MIT License. See the LICENSE file for details.
