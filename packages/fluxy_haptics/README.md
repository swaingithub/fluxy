# fluxy_haptics

[PLATFORM] Official Sensory Feedback module for the Fluxy framework. Provides high-performance tactile confirmation for industrial-grade user interfaces.

## [INSTALL] Installation

### Via CLI (Recommended)
```bash
fluxy module add haptics
```

### Manual pubspec.yaml
```yaml
dependencies:
  fluxy_haptics: ^1.0.0
```

---

## [USAGE] Implementation Paradigms

Access haptics through the convenient `Fx.haptic` shortcut or the unified `Fx.platform.haptic` gateway.

### Semantic Feedback

```dart
// Success pulse (Medium Impact)
Fx.haptic.success();

// Error alert (Vibrate)
Fx.haptic.error();

// UI Selection click
Fx.haptic.selection();

// Custom Impacts
Fx.haptic.light();
Fx.haptic.medium();
Fx.haptic.heavy();
```

---

## [RULES] Industrial Standard vs. Outdated Style

| Feature | [WRONG] The Outdated Way | [RIGHT] The Fluxy Standard |
| :--- | :--- | :--- |
| **Plugin Access** | `HapticFeedback.lightImpact()` | `Fx.haptic.light()` |
| **Logic** | Manual checks for vibration settings | Managed `enabled` signal in Fluxy |
| **Consistency** | Inconsistent vibration patterns | Semantic `success()` and `error()` methods |

---

## [API] Reference

### Properties (How to Add and Use)
Fluxy Haptics uses a reactive signal to manage the sensory state globally.

| Property | Type | Instruction |
| :--- | :--- | :--- |
| `enabled` | `Signal<bool>` | **Use**: `Fx.platform.haptic.enabled.value`. **Modify**: `Fx.platform.haptic.enabled.value = false` to mute the app. |

---

## [SECURITY] Sensory Integrity

- **Battery**: Physical haptic actuators consume power. Use `light()` for high-frequency events and `heavy()` only for destructive actions.
- **Accessibility**: Provide visual cues alongside haptics, as some users may have vibration disabled at the OS level.

## License

This package is licensed under the MIT License. See the LICENSE file for details.
