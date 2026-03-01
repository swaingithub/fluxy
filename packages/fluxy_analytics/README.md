# fluxy_analytics

[PLATFORM] Official Analytics and User Tracking module for the Fluxy framework, providing unified event dispatching and identity management.

## [INSTALL] Installation

### Via CLI (Recommended)
Add the module using the Fluxy CLI to automatically handle dependency injection and registry updates.
```bash
fluxy module add analytics
```

### Manual pubspec.yaml
```yaml
dependencies:
  fluxy_analytics: ^1.1.0
```

---

## [BOOT] Managed Initialization

To use `fluxy_analytics` correctly, your `main.dart` must follow the mandatory three-step boot sequence to hook the architectural registry.

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

Access all analytics features through the stable `Fx.platform.analytics` gateway.

### Event Tracking

```dart
// Log a semantic event
Fx.platform.analytics.logEvent('button_click', parameters: {
  'screen_id': 'login_view',
  'btn_label': 'sign_in',
});
```

### User Identification
Fluxy Analytics automatically bridges with `fluxy_auth` for identity state.

```dart
// Identify a specific user
Fx.platform.analytics.identify('user_007', traits: {
  'plan': 'premium',
  'region': 'EU',
});
```

---

## [API] Reference

### Methods
- `logEvent(name, {parameters})`: Dispatches a custom event to all registered backends.
- `logScreen(name)`: Tracks screen views for navigation analytics.
- `identify(userId, {traits})`: Links a user to their behavior across sessions.
- `reset()`: Wipes the current identity and resets tracking tokens.

### Properties (How to Add and Use)
Fluxy Analytics properties are reactive signals used for monitoring tracking health.

| Property | Type | Instruction |
| :--- | :--- | :--- |
| `eventCount` | `Signal<int>` | **Use**: `Fx.platform.analytics.eventCount.value`. Useful for debug dashboards. |

---

## [PROPERTIES] Property Instruction: Add and Use It

To **add** a custom listener for debug logging:
```dart
Fx.platform.analytics.eventCount.listen((count) {
  debugPrint("[SYS] [ANALYTICS] Dispatched event #$count");
});
```

To **use** the event count in a developer overlay:
```dart
Fx(() => Fx.text("Tracking Live: ${Fx.platform.analytics.eventCount.value} events"));
```

---

## [RULES] Industrial Standard vs. Outdated Style

| Feature | [WRONG] The Outdated Way | [RIGHT] The Fluxy Standard |
| :--- | :--- | :--- |
| **Plugin Access** | `Fx.analytics` or `FirebaseAnalytics.instance` | `Fx.platform.analytics` |
| **Tracking** | Manual calls in every widget | Centralized in `FluxController` |
| **Identity** | Manual token management | Built-in identity bridging |

## License

This package is licensed under the MIT License. See the LICENSE file for details.
