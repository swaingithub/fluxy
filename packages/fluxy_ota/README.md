# fluxy_ota

[PLATFORM] Official Over-The-Air (OTA) module for the Fluxy framework. [EXPERIMENTAL]

## [INSTALL] Installation

### Via CLI (Recommended)
```bash
fluxy module add ota
```

### Manual pubspec.yaml
```yaml
dependencies:
  fluxy_ota: ^1.0.0
```

---

## [USAGE] Implementation Paradigms

Access the OTA lifecycle via the unified `Fx.platform.ota` gateway.

### Updating Manifest

```dart
// Check for manifest updates
final hasUpdate = await Fx.platform.ota.check();

if (hasUpdate) {
  // Sync remote styles and metadata
  await Fx.platform.ota.sync();
}
```

---

## [API] Reference

### Properties (How to Add and Use)
Fluxy OTA uses reactive signals to manage the update state.

| Property | Type | Instruction |
| :--- | :--- | :--- |
| `status` | `Signal<OtaStatus>` | **Use**: `Fx.platform.ota.status.value`. Reflects current networking state. |
| `manifest` | `Signal<Map>` | **Use**: `Fx.platform.ota.manifest.value`. Hydrated after successful sync. |

---

## [RULES] Industrial Standard vs. Outdated Style

| Feature | [WRONG] The Outdated Way | [RIGHT] The Fluxy Standard |
| :--- | :--- | :--- |
| **Plugin Access** | `FluxyRemote.sync()` | `Fx.platform.ota.sync()` |
| **State** | Manual checks for local files | Reactive `status` signal |
| **Logic** | Static asset bundle updates | Dynamic JSON manifest orchestration |

---

## [PITFALLS] Common Pitfalls & Fixes

### 1. "OTA Sync fails on Android"
*   **The Cause**: Lack of internet permission or cleartext traffic blocked.
*   **The Fix**: Ensure `INTERNET` permission is in `AndroidManifest.xml` and your manifest server uses HTTPS.

## License

This package is licensed under the MIT License. See the LICENSE file for details.
