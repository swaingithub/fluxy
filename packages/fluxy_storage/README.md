# fluxy_storage

[PLATFORM] Official Persistent Storage module for the Fluxy framework, providing high-performance reactive key-value persistence with Secure Enclave support.

## [INSTALL] Installation

### Via CLI (Recommended)
Add the module using the Fluxy CLI to automatically handle dependency injection and registry updates.
```bash
fluxy module add storage
```

### Manual pubspec.yaml
```yaml
dependencies:
  fluxy_storage: ^1.1.0
```

---

## [BOOT] Managed Initialization

To use `fluxy_storage` correctly, your `main.dart` must follow the mandatory three-step boot sequence to hook the architectural registry.

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

Access all storage features through the stable `Fx.platform.storage` gateway.

### Basic Operations

```dart
// Store primitive data
await Fx.platform.storage.set('theme_mode', 'dark');

// Store sensitive data in Secure Enclave
await Fx.platform.storage.set('api_token', 'xxx-yyy-zzz', secure: true);

// Retrieve with reactive fallback
final theme = Fx.platform.storage.getString('theme_mode', fallback: 'light');
```

### Reactive Storage UI
Fluxy Storage integrates directly with the `Fx()` builder. When a value in storage changes, dependent UI rebuilds automatically.

```dart
Fx(() {
  final count = Fx.platform.storage.getInt('launch_count', fallback: 0);
  return Fx.text("App launched $count times");
});
```

---

## [API] Reference

### Methods
- `set(key, value, {secure})`: Persists a value to disk. Use `secure: true` for encryption.
- `get(key, {secure})`: Retrieves a raw value.
- `getString/Int/Bool(key, {fallback})`: Type-safe getters with integrated fallback logic.
- `remove(key, {secure})`: Deletes a specific entry.
- `clear({secure})`: Wipes all entries from the specified storage tier.

### Properties (How to Add and Use)
Fluxy Storage properties are accessed via the platform helper. To "add" data, use `.set()`. To "use" it reactively, wrap your retrieval in `Fx()`.

| Feature | Instruction | Example |
| :--- | :--- | :--- |
| **Add Data** | Use the `.set` method with a unique key. | `Fx.platform.storage.set('key', value)` |
| **Use Data** | Use type-safe getters inside reactive builders. | `Fx(() => Fx.platform.storage.getString('key'))` |
| **Reactive Sync** | Updates to storage trigger global rebuilds. | No manual listeners required. |

---

## [RULES] Industrial Standard vs. Outdated Style

| Feature | [WRONG] The Outdated Way | [RIGHT] The Fluxy Standard |
| :--- | :--- | :--- |
| **Plugin Access** | `Fx.storage` or `SharedPreferences.getInstance()` | `Fx.platform.storage` |
| **Security** | Manual encryption logic | `secure: true` flag |
| **Reactivity** | Manual listeners or polling | Integrated `Fx()` signal rebuilds |
| **Fallbacks** | `val ?? 'default'` | `storage.getString(key, fallback: 'default')` |

---

## [PITFALLS] Common Pitfalls & Fixes

### 1. "Value is null on first launch"
*   **The Cause**: Expecting a value that hasn't been set yet without a fallback.
*   **The Fix**: Always provide a `fallback` in your getters: `getString('key', fallback: '')`.

### 2. "Secure storage fails on Android"
*   **The Cause**: Missing min SDK requirements for EncryptedSharedPreferences.
*   **The Fix**: Ensure `minSdkVersion` is at least 18 in your `build.gradle`.

---

## [SECURITY] Security Considerations

- **Encryption**: Secure storage uses AES-256 GCM on Android and Keychain on iOS.
- **Scope**: Regular storage is for UX preferences. Sensitive PII must use `secure: true`.

## License

This package is licensed under the MIT License. See the LICENSE file for details.
