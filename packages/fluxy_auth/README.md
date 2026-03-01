# fluxy_auth

[PLATFORM] Official Authentication module for the Fluxy framework, providing secure user identity and session management via the Unified Platform API.

## [INSTALL] Installation

### Via CLI (Recommended)
Add the module using the Fluxy CLI to automatically handle dependency injection and registry updates.
```bash
fluxy module add auth
```

### Manual pubspec.yaml
```yaml
dependencies:
  fluxy_auth: ^1.1.0
```

---

## [BOOT] Managed Initialization

To use `fluxy_auth` correctly, your `main.dart` must follow the mandatory three-step boot sequence to hook the architectural registry.

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

Access all authentication features through the stable `Fx.platform.auth` gateway.

### Basic Authentication

```dart
class AuthService {
  // Sign in with email and password
  Future<bool> login(String email, String password) async {
    try {
      // The Industrial Standard: Access via Fx.platform
      final success = await Fx.platform.auth.login(email, password);
      return success;
    } catch (e) {
      Fx.toast.error('Sign in failed: $e');
      return false;
    }
  }
  
  // Sign out current user
  Future<void> logout() {
    Fx.platform.auth.logout();
    Fx.toast.success('Signed out successfully');
  }
}
```

### Reactive Auth UI
Everything in `fluxy_auth` is signal-based. Use the `Fx()` builder to handle view transitions automatically.

```dart
Fx(() {
  if (Fx.platform.auth.isAuthenticated.value) {
    return DashboardView();
  }
  return LoginView();
});
```

---

## [API] Reference

### Methods
- `login(email, password)`: Authenticates the user and sets the identity signals.
- `logout()`: Clears the current session and resets identity signals.

### Properties (Reactive Signals)
Fluxy Auth uses high-performance signals for state. You can "use" them by accessing `.value` or "add" custom listeners via `.listen()`.

| Property | Type | Instruction |
| :--- | :--- | :--- |
| `isAuthenticated` | `Signal<bool>` | **Use**: `Fx.platform.auth.isAuthenticated.value`. **Listen**: `isAuthenticated.listen((v) => ...)` |
| `user` | `Signal<Map?>` | **Use**: `Fx.platform.auth.user.value?['name']`. **Listen**: `user.listen((u) => ...)` |

---

## [RULES] Industrial Standard vs. Outdated Style

| Feature | [WRONG] The Outdated Way | [RIGHT] The Fluxy Standard |
| :--- | :--- | :--- |
| **Plugin Access** | `Fx.auth` or `FluxyPluginEngine.find()` | `Fx.platform.auth` |
| **State Check** | `if (auth.currentUser != null)` | `Fx(() => auth.isAuthenticated.value)` |
| **Registration** | Manual `Fluxy.register()` in main.dart | `fluxy module add` + `Fluxy.autoRegister()` |
| **Networking** | Manual header injection | Automatic Auth Interceptors via `Fx.http` |

---

## [ERROR] Professional Error Handling

```dart
try {
  await Fx.platform.auth.login(email, password);
} on AuthException catch (e) {
  // All auth errors are categorized for the industrial pipeline
  Fx.toast.error(e.message);
} catch (e) {
  debugPrint('[SYS] [AUTH] Unexpected error: $e');
}
```

---

## [PITFALLS] Common Pitfalls & Fixes

### 1. "Auth module is null"
*   **The Cause**: Calling `Fx.platform.auth` before `Fluxy.autoRegister()` or neglecting the `registerRegistry` step.
*   **The Fix**: Ensure your `main()` follow the exact 1-2-3 boot sequence.

### 2. "UI doesn't update on logout"
*   **The Cause**: Accessing the `isAuthenticated` signal outside of an `Fx()` builder.
*   **The Fix**: Wrap your top-level layout in an `Fx(() => ...)` widget.

---

## [SECURITY] Security Considerations

- **Tokens**: Securely stored in the hardware enclave using `fluxy_storage`.
- **Encryption**: AES-256 encrypted persistence for sensitive identity data.
- **Interceptors**: `Fx.http` automatically monitors the auth state to manage headers.

## License

This package is licensed under the MIT License. See the LICENSE file for details.
