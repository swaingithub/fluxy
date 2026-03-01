# fluxy_permissions

[PLATFORM] Official Device Permissions module for the Fluxy framework, providing reactive status monitoring and unified platform manifest injection.

## [INSTALL] Installation

### Via CLI (Recommended)
Add the module using the Fluxy CLI to automatically handle dependency injection and registry updates.
```bash
fluxy module add permissions
```

### Manual pubspec.yaml
```yaml
dependencies:
  fluxy_permissions: ^1.1.0
```

---

## [BOOT] Managed Initialization

To use `fluxy_permissions` correctly, your `main.dart` must follow the mandatory three-step boot sequence to hook the architectural registry.

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

Access all permission features through the stable `Fx.platform.permissions` gateway.

### Status Monitoring

```dart
// Reactive UI Status
Fx(() {
  final status = Fx.platform.permissions.statusOf(FluxyPermission.camera).value;
  return Fx.text("Camera Ready: ${status == PermissionStatus.granted}");
});
```

### Requesting Access
```dart
void requestCamera() async {
  final status = await Fx.platform.permissions.request(FluxyPermission.camera);
  
  if (status == PermissionStatus.granted) {
    Fx.platform.camera.fullView(context: context);
  } else {
    Fx.toast.warning("Camera permission denied.");
  }
}
```

---

## [API] Reference

### Methods
- `request(permission)`: Triggers a standard permission prompt.
- `statusOf(permission)`: Returns a reactive signal for any specific hardware permission.
- `openSettings()`: Opens the OS settings page for the current application.

### Properties (How to Add and Use)
Fluxy Permissions properties are reactive signals. You "use" them by accessing `.value` and "add" reactive logic by wrapping them in `Fx()`.

| Property | Type | Instruction |
| :--- | :--- | :--- |
| `status` | `Signal<Map>` | **Use**: `Fx.platform.permissions.statusOf(p).value`. Rebuilds widgets automatically. |

---

## [PROPERTIES] Property Instruction: Add and Use It

To **add** a custom listener for hardware readiness:
```dart
Fx.platform.permissions.statusOf(FluxyPermission.location).listen((status) {
  if (status == PermissionStatus.granted) startLocationTracking();
});
```

To **use** current permission state to gate feature UI:
```dart
Fx(() {
  final isGranted = Fx.platform.permissions.statusOf(FluxyPermission.microphone).value.isGranted;
  return isGranted ? VoiceRecorder() : PermissionGate();
});
```

---

## [RULES] Industrial Standard vs. Outdated Style

| Feature | [WRONG] The Outdated Way | [RIGHT] The Fluxy Standard |
| :--- | :--- | :--- |
| **Plugin Access** | `Fx.permissions` or `permission_handler` | `Fx.platform.permissions` |
| **UI Updates** | Manual `AppLifecycle` listeners | Integrated `Fx()` signal rebuilds |
| **Manifests** | Manual `info.plist` edits | CLI Injection during `module add` |

## License

This package is licensed under the MIT License. See the LICENSE file for details.
