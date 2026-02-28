# fluxy_biometric

[PLATFORM] Official Biometric Authentication module for the Fluxy framework, providing secure Face ID and Fingerprint verification via the Unified Platform API.

## [INSTALL] Installation

### Via CLI (Recommended)
Add the module using the Fluxy CLI to automatically handle dependency injection and registry updates.
```bash
fluxy module add biometric
```

### Manual pubspec.yaml
```yaml
dependencies:
  fluxy_biometric: ^1.0.0
```

---

## [BOOT] Managed Initialization

To use `fluxy_biometric` correctly, your `main.dart` must follow the mandatory three-step boot sequence to hook the architectural registry.

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

Access biometric features through the stable `Fx.platform.biometric` gateway.

### Secure Challenge

```dart
Future<void> openVault() async {
  // Simple hardware challenge
  final success = await Fx.platform.biometric.authenticate(
    reason: "Please verify your identity to access the secure vault.",
  );
  
  if (success) {
    print("[SYS] Vault access granted.");
  }
}
```

### Reactive UI Status
Check for hardware support reactively to show or hide biometric settings.

```dart
Fx(() {
  final canScan = Fx.platform.biometric.isAvailable.value;
  return canScan ? BiometricToggle() : Fx.text("Hardware Unavailable");
});
```

---

## [API] Reference

### Methods
- `authenticate({reason})`: Triggers the OS-level Face ID or Fingerprint prompt.
- `isAvailable()`: Returns true if hardware is present and data is enrolled.
- `getAvailableTypes()`: Returns a list of supported hardware (Face, Fingerprint, Iris).

### Properties (How to Add and Use)
Fluxy Biometric properties are reactive signals used for managing security state.

| Property | Type | Instruction |
| :--- | :--- | :--- |
| `isAvailable` | `Signal<bool>` | **Use**: `Fx.platform.biometric.isAvailable.value`. Automatically updates based on hardware state. |

---

## [PROPERTIES] Property Instruction: Add and Use It

To **add** a custom listener for security auditing:
```dart
Fx.platform.biometric.isAvailable.listen((ready) {
  debugPrint("[SYS] [SEC] Biometric hardware status: $ready");
});
```

To **use** the reactive status in your profile view:
```dart
Fx(() {
  return SwitchListTile(
    title: Fx.text("Enable Face ID"),
    value: Fx.platform.storage.getBool('use_bio', fallback: false),
    onChanged: Fx.platform.biometric.isAvailable.value ? (v) => savePref(v) : null,
  );
});
```

---

## [RULES] Industrial Standard vs. Outdated Style

| Feature | [WRONG] The Outdated Way | [RIGHT] The Fluxy Standard |
| :--- | :--- | :--- |
| **Plugin Access** | `Fx.biometric` or `LocalAuthentication.authenticate()` | `Fx.platform.biometric` |
| **Availability** | Checking hardware inside every click | Rebuilding via the `isAvailable` signal |
| **Errors** | Manual try-catch blocks | Centralized Fluxy Error Pipeline |

## License

This package is licensed under the MIT License. See the LICENSE file for details.
