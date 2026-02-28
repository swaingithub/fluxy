# fluxy_device

[PLATFORM] Official Environment Awareness module for the Fluxy framework. Provides comprehensive hardware metadata and application state knowledge.

## [INSTALL] Installation

### Via CLI (Recommended)
```bash
fluxy module add device
```

### Manual pubspec.yaml
```yaml
dependencies:
  fluxy_device: ^1.0.0
```

---

## [USAGE] Implementation Paradigms

Access environmental knowledge via the unified `Fx.platform.device` gateway.

### Hardware Awareness

```dart
// Check if running on a real phone
if (Fx.platform.device.isPhysical) {
  print("[SYS] Physical hardware detected.");
}

// Access deep metadata
final brand = Fx.platform.device.meta.value['brand'];
final model = Fx.platform.device.meta.value['model'];
```

### Reactive Versioning
```dart
Fx(() {
  return Fx.text("v${Fx.platform.device.appVersion.value}");
});
```

---

## [API] Reference

### Properties (How to Add and Use)
Fluxy Device hydrates its knowledge during the `onRegister` phase of the Fluxy lifecycle.

| Property | Type | Instruction |
| :--- | :--- | :--- |
| `meta` | `Signal<Map>` | **Use**: `Fx.platform.device.meta.value`. Contains hardware details (OS, Model, etc). |
| `appVersion` | `Signal<String>` | **Use**: `Fx.platform.device.appVersion.value`. Automatically pulled from package info. |

---

## [RULES] Industrial Standard vs. Outdated Style

| Feature | [WRONG] The Outdated Way | [RIGHT] The Fluxy Standard |
| :--- | :--- | :--- |
| **Plugin Access** | `DeviceInfoPlugin().iosInfo` | `Fx.platform.device.meta.value` |
| **Logic** | Checking Platform.isAndroid everywhere | Accessing the unified `meta` signal |
| **Storage** | Storing version numbers in constants | Auto-hydration from `pubspec.yaml` |

---

## [PLATFORM] Supported Metadata

- **Android**: Model, SDK, Brand, Physical status.
- **iOS**: UTSName (Machine), OS Version, Physical status.
- **Web**: Browser Name, App Version.

## License

This package is licensed under the MIT License. See the LICENSE file for details.
