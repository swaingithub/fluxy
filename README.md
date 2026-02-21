# Fluxy: The Managed Application Platform for Flutter

**Build enterprise-grade Flutter apps with the speed of a startup and the stability of a bank.**

Fluxy is a comprehensive, production-grade application platform designed to unify the entire development lifecycle. More than just a library, Fluxy provides a **Managed Runtime Architecture** that combines reactive state, declarative UI, a physics-based motion engine, and a suite of high-performance platform modules.

---

## 🏛️ The Platform Philosophy

Fluxy serves as the **structural authority** for the Flutter ecosystem. It eliminates the need for dozens of fragmented third-party dependencies by providing a robust, natively integrated suite of core engines.

### 🔌 Managed Plugin Architecture (`Fx.platform`)
Fluxy v0.2.5 introduces the **Managed Runtime**. Platform modules (Camera, Auth, Notifications) are no longer loose dependencies—they are managed components that hook into the application's lifecycle, error pipeline, and security kernel.

*   **Auto-Registration**: Plugins are automatically discovered and wired up via `Fluxy.autoRegister()`.
*   **Safety Intercepts**: Every plugin call is wrapped in a stability guard that prevents native crashes from reaching your UI.
*   **Unified API**: Access everything from a single entry point: `Fx.camera`, `Fx.storage`, `Fx.biometric`.

---

## 📦 Core Platform Modules (The "Big 8")

Every Fluxy project starts with these industrial-grade modules pre-optimized:

*   🔔 **Notifications**: v20.0+ compatible, time-zone aware, with automatic Android 13+ permission handling and exact-alarm fallbacks.
*   📸 **Camera**: High-speed interface with real-time reactive state, gallery integration, and instant capture-to-view.
*   🔐 **Biometric**: v3.0+ FaceID/Fingerprint support with standardized platform prompts and secure error handling.
*   💾 **Storage**: Unified abstraction for high-speed cache (`SharedPreferences`) and the encrypted `SecureVault`.
*   🛡️ **Permissions**: Declarative, single-line permission handling across Android & iOS.
*   🔑 **Auth**: Reactive identity engine with global session tracking and middleware support.
*   📡 **Connectivity**: Real-time reactive monitoring of network status.
*   📊 **Analytics**: Standardized event tracking with native delivery providers.

---

## 💎 Engineering Pillars

### 1. Fluxy Stability Kernel™ (SafeUI)
Fluxy proactively prevents 80% of common Flutter layout crashes (unbounded height/width, nested scrollables).
*   **Auto-Constraint Enforcement**: Widgets automatically fallback to safe dimensions in unbounded contexts.
*   **Flex Solver Intelligence**: Automatically repairs "Infinite Constraint" violations in `FxRow` and `FxCol`.
*   **Structural Recursion**: Modifiers automatically "peer through" layout widgets (like `Expanded`) to apply styles correctly.

### 2. Universal Style Engine™
Fluxy mirrors all visual modifiers into the `FxStyle` object. This enables high-fidelity interactive state modeling—use the same modifiers in `onHover` or `onPressed` builders that you use on the widgets themselves.

### 3. Integrated Developer Tools (Fluxy Inspector)
A premium debugging interface (non-release only):
*   **DI Container Inspection**: Review active dependencies and their lifecycle scopes.
*   **Network Activity Logs**: Full inspection of HTTP payloads and latency.
*   **Stability Dashboard**: Real-time log of every auto-repaired layout violation.

---

## 🚀 Technical Quickstart

### Installation
```yaml
dependencies:
  fluxy: ^0.2.5
```

### 1. Initialize the Platform
```dart
void main() async {
  // Boots storage, persistence, and all registered modules
  await Fluxy.init(); 

  runApp(
    Fluxy.debug( // Enable Inspector + Layout Guards
      child: FluxyApp(
        initialRoute: homeRoutes.first,
        routes: [...homeRoutes],
      ),
    ),
  );
}
```

### 2. High-Speed Media Rendering
```dart
// Display an asset, network image, or a local photo from the camera
Fx.img("file://${Fx.camera.lastImage.path}")
  .cover()
  .rounded(12)
  .liftOnHover();
```

### 3. Reactive State with Persistence
```dart
// Auto-saves to disk and restores on app boot magically
final balance = flux(100.0, key: "user_account", persist: true); 

Fx(() => Fx.text("Balance: ${balance.value}")).center()
```

---

## 🛠️ Feature Matrix

| Feature | Description |
| :--- | :--- |
| **Stability Kernel™** | Full-stack crash protection for Layout, State, and Async logic. |
| **Managed Runtime** | Fluxy Plugin module registration and unified platform access. |
| **Data Visualization** | High-performance reactive charts (`Fx.chart`) with entrance motion. |
| **Universal Stylizer** | Modifier parity across widgets and interactive state styles. |
| **Viewport Engine** | Robust scrollable layouts via `Fx.viewport` and `Fx.sliver`. |
| **Motion DSL** | Physics-based animation presets and staggered entrance reveal. |

---

## Enterprise Reliability
Fluxy is built for production. It provides the structural integrity, global error boundaries, and architectural authority required for large-scale, mission-critical applications.

**Standardize your Flutter engineering with Fluxy.**
