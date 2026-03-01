# fluxy_connectivity

[PLATFORM] Official Network Connectivity module for the Fluxy framework, providing reactive status monitoring and offline-first task queuing.

## [INSTALL] Installation

### Via CLI (Recommended)
Add the module using the Fluxy CLI to automatically handle dependency injection and registry updates.
```bash
fluxy module add connectivity
```

### Manual pubspec.yaml
```yaml
dependencies:
  fluxy_connectivity: ^1.1.0
```

---

## [BOOT] Managed Initialization

To use `fluxy_connectivity` correctly, your `main.dart` must follow the mandatory three-step boot sequence to hook the architectural registry.

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

Access all connectivity features through the stable `Fx.platform.connectivity` gateway.

### Basic Monitoring

```dart
// Reactive UI Status
Fx(() {
  final isOnline = Fx.platform.connectivity.isOnline.value;
  return Icon(isOnline ? Icons.wifi : Icons.wifi_off);
});
```

### Offline-First Queuing
The `whenOnline` utility allows you to register tasks that will automatically fire as soon as a stable connection is detected.

```dart
void syncData() async {
  // This task is queued if device is offline
  await Fx.platform.connectivity.whenOnline('data_sync', () async {
    await api.post('/sync');
    Fx.toast.success("Synchronized!");
  });
}
```

---

## [API] Reference

### Methods
- `whenOnline(key, action)`: Queues an action until the device is online. Uses a unique ID to prevent duplicates.
- `refresh()`: Forces a manual re-check of the network state.

### Properties (How to Add and Use)
Fluxy Connectivity properties are reactive signals. You "use" them by accessing `.value` and "add" reactive logic by wrapping them in `Fx()`.

| Property | Type | Instruction |
| :--- | :--- | :--- |
| `isOnline` | `Signal<bool>` | **Use**: `Fx.platform.connectivity.isOnline.value`. Rebuilds reactive widgets automatically. |
| `connectionType` | `Signal<ConnType>` | **Use**: `Fx.platform.connectivity.connectionType.value` (wifi, mobile, etc). |

---

## [PROPERTIES] Property Instruction: Add and Use It

To **add** a custom listener to a property:
```dart
Fx.platform.connectivity.isOnline.listen((online) {
  print("[SYS] Connectivity changed to: $online");
});
```

To **use** a property in your UI:
```dart
Fx(() => Fx.text("Status: ${Fx.platform.connectivity.isOnline.value ? 'Online' : 'Offline'}"));
```

---

## [RULES] Industrial Standard vs. Outdated Style

| Feature | [WRONG] The Outdated Way | [RIGHT] The Fluxy Standard |
| :--- | :--- | :--- |
| **Plugin Access** | `Fx.connectivity` or `Connectivity().check()` | `Fx.platform.connectivity` |
| **Logic** | `if (await checkConnection())` | `Fx.platform.connectivity.whenOnline()` |
| **UI** | Manual stream builders | Integrated `Fx()` signal rebuilds |

---

## [PITFALLS] Common Pitfalls & Fixes

### 1. "Signal doesn't update on simulator"
*   **The Cause**: Mobile simulators sometimes fail to broadcast network state changes to the OS layer correctly.
*   **The Fix**: Toggle the data connection manually in the simulator settings or restart the emulator.

### 2. "whenOnline fires multiple times"
*   **The Cause**: Using the same key for different tasks or not providing a key.
*   **The Fix**: Ensure every task has a unique, descriptive key (e.g., `'upload_profile_v1'`).

## License

This package is licensed under the MIT License. See the LICENSE file for details.
