# fluxy_camera

[PLATFORM] Official Camera module for the Fluxy framework, providing managed device hardware access and pre-built capture interfaces.

## [INSTALL] Installation

### Via CLI (Recommended)
Add the module using the Fluxy CLI to automatically handle dependency injection and registry updates.
```bash
fluxy module add camera
```

### Manual pubspec.yaml
```yaml
dependencies:
  fluxy_camera: ^1.0.0
```

---

## [BOOT] Managed Initialization

To use `fluxy_camera` correctly, your `main.dart` must follow the mandatory three-step boot sequence to hook the architectural registry.

```dart
import 'package:fluxy/fluxy.dart';
import 'core/registry/fluxy_registry.dart'; 

void main() async {
  // 1. Initialize Kernel
  await Fluxy.init();
  
  // 2. Hook the Registry
  Fluxy.registerRegistry(() => registerFluxyPlugins()); 
  
  // 3. Auto-boot all modules
  Fluxy.autoRegister(); 
  runApp(MyApp());
}
```

---

## [USAGE] Implementation Paradigms

Access all camera features through the stable `Fx.platform.camera` gateway.

### High-Level Capture (The Industrial Way)
Use the `fullView` method to open a managed capture interface that handles hardware lifecycle and permissions automatically.

```dart
void takePhoto(BuildContext context) async {
  final file = await Fx.platform.camera.fullView(context: context);
  
  if (file != null) {
    print("[SYS] Image captured: ${file.path}");
  }
}
```

### Deep-Level Control
For custom layouts, use the `FxCamera` widget or the underlying controller.

```dart
FxCamera(
  onCapture: (file) => handleFile(file),
).h(300).rounded(20);
```

---

## [API] Reference

### Methods
- `fullView(context)`: Opens a full-screen managed camera modal.
- `capture()`: Triggers a direct capture from the primary camera.
- `disposeCache()`: Clears temporary image assets stored in cache.

### Properties (How to Add and Use)
Fluxy Camera properties are accessed via the platform helper.

| Property | Type | Instruction |
| :--- | :--- | :--- |
| **Available Cameras** | `List<CameraDescription>` | **Use**: `Fx.platform.camera.cameras`. Check if hardware is present. |
| **Active Controller** | `CameraController?` | **Use**: Access underlying plugin controller for advanced hardware settings. |

---

## [PROPERTIES] Property Instruction: Add and Use It

To **add** logic that checks for camera availability:
```dart
if (Fx.platform.camera.cameras.isEmpty) {
  Fx.toast.error("No camera hardware detected.");
}
```

To **use** the managed capture property in a button:
```dart
Fx.button("Scan Label")
  .onTap(() => Fx.platform.camera.fullView(context: context));
```

---

## [RULES] Industrial Standard vs. Outdated Style

| Feature | [WRONG] The Outdated Way | [RIGHT] The Fluxy Standard |
| :--- | :--- | :--- |
| **Plugin Access** | `Fx.camera` or `CameraController.initialize()` | `Fx.platform.camera` |
| **Capture UI** | Building custom overlay stacks | `Fx.platform.camera.fullView()` |
| **Lifecycle** | Manual `.dispose()` calls | Managed automatically by Fluxy |
| **Permissions** | Manual `permission_handler` logic | Automatic check inside `fullView` |

---

## [PITFALLS] Common Pitfalls & Fixes

### 1. "Black screen on startup"
*   **The Cause**: Running on an emulator without a simulated camera backend.
*   **The Fix**: Ensure your emulator has "Camera" enabled in its AVD settings.

### 2. "Camera doesn't initialize"
*   **The Cause**: Not calling `Fluxy.autoRegister()` in `main()`.
*   **The Fix**: Ensure all 3 boot steps are present in your `main.dart`.

## License

This package is licensed under the MIT License. See the LICENSE file for details.
