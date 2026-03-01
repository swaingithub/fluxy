# fluxy_notifications

[PLATFORM] Official Push Notification module for the Fluxy framework, providing unified channel management and timezone-aware scheduling.

## [INSTALL] Installation

### Via CLI (Recommended)
Add the module using the Fluxy CLI to automatically handle dependency injection and registry updates.
```bash
fluxy module add notifications
```

### Manual pubspec.yaml
```yaml
dependencies:
  fluxy_notifications: ^1.1.0
```

---

## [BOOT] Managed Initialization

To use `fluxy_notifications` correctly, your `main.dart` must follow the mandatory three-step boot sequence to hook the architectural registry.

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

Access all notification features through the stable `Fx.platform.notifications` gateway.

### Basic Alerts

```dart
// Immediate alert
Fx.platform.notifications.show(
  title: "Order Processed",
  body: "Your item is on its way!",
);

// Scheduled reminder
Fx.platform.notifications.schedule(
  id: 1,
  title: "Reminder",
  body: "Time for your workout!",
  scheduledDate: DateTime.now().add(const Duration(hours: 2)),
);
```

### Channel Management (Android)
```dart
Fx.platform.notifications.createChannel(
  id: "marketing",
  name: "Promotions",
  importance: Importance.medium,
);
```

---

## [API] Reference

### Methods
- `show(title, body, {payload})`: Displays an immediate notification.
- `schedule(id, title, body, date)`: Sets a future alert (timezone aware).
- `cancel(id)`: Removes a specific scheduled notification.
- `requestPermission()`: Managed permission prompt for modern OS versions.

### Properties (How to Add and Use)
Fluxy Notifications properties are reactive signals for monitoring active alert states.

| Property | Type | Instruction |
| :--- | :--- | :--- |
| `activeNotifications` | `Signal<List>` | **Use**: `Fx.platform.notifications.activeNotifications.value`. Useful for custom notification center UI. |

---

## [PROPERTIES] Property Instruction: Add and Use It

To **add** a custom listener for payload routing:
```dart
Fx.platform.notifications.activeNotifications.listen((list) {
  debugPrint("[SYS] [NOTIF] Pending alerts: ${list.length}");
});
```

To **use** the notification property in your UI:
```dart
Fx(() {
  final count = Fx.platform.notifications.activeNotifications.value.length;
  return Badge(label: Fx.text("$count"));
});
```

---

## [RULES] Industrial Standard vs. Outdated Style

| Feature | [WRONG] The Outdated Way | [RIGHT] The Fluxy Standard |
| :--- | :--- | :--- |
| **Plugin Access** | `Fx.notifications` or manual boilerplate | `Fx.platform.notifications` |
| **Logic** | Manual channel setup in code | Auto-channeling via Platform API |
| **Scheduling** | Guessing timezones for alerts | Native timezone-aware scheduling |

## License

This package is licensed under the MIT License. See the LICENSE file for details.
