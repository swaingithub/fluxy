# [PLATFORM] Fluxy Framework
### Industrial-Grade Managed Application Platform for Flutter

**Standardize your Flutter engineering with a high-integrity, unified runtime environment.**

Fluxy is not just a library; it is a **Managed Application Platform (MAP)** designed to provide architectural authority to the Flutter ecosystem. It replaces fragmented third-party dependencies with a single, high-performance kernel that manages state, layout stability, platform hardware, and security.

---

## **v1.0.0 - Major Update**

**Fluxy v1.0.0 introduces a modular architecture!** 

- **Smaller core package** (172KB vs 15MB+)
- **Separate packages** for specific features
- **Migration required** from v0.2.6
- **Professional logging system** with semantic bracketed tags
- **Experimental guardrails** for OTA, SDUI, and Cloud CLI

**[Read Migration Guide](MIGRATION_GUIDE.md)**

### Recent Updates (v0.2.5 - v0.2.6)
- **v0.2.6**: Industrial Log Professionalization & Experimental Guardrails
- **v0.2.5**: The Platform Era with Managed Runtime Architecture

---

## [INSTALL] Installation

### Core Package
```yaml
dependencies:
  fluxy: ^1.0.0
```

### Modular Packages (Add as needed)
```yaml
dependencies:
  fluxy_forms: ^1.0.0        # Forms and validation
  fluxy_camera: ^1.0.0       # Camera functionality  
  fluxy_auth: ^1.0.0         # Authentication and biometrics
  fluxy_notifications: ^1.0.0 # Push notifications
  fluxy_storage: ^1.0.0      # Data persistence
  fluxy_test: ^1.0.0         # Testing utilities
  fluxy_analytics: ^1.0.0    # Analytics and tracking
  fluxy_biometric: ^1.0.0    # Biometric authentication
  fluxy_connectivity: ^1.0.0 # Network connectivity
  fluxy_permissions: ^1.0.0  # Device permissions
  fluxy_platform: ^1.0.0     # Platform integration
  fluxy_ota: ^1.0.0          # Over-the-air updates
```

### Quick Start
```dart
import 'package:fluxy/fluxy.dart';

void main() async {
  await Fluxy.init();
  runApp(FluxyApp(routes: appRoutes));
}
```

## [ARCH] Structural Hierarchy

Fluxy is built on a layered architecture that ensures separation of concerns while maintaining a unified developer experience.

1.  **[LEVEL 0] The Stability Kernel™**: The lowest layer, providing auto-correction for layout violations, async race protection, and global error intercepts.
2.  **[LEVEL 1] Managed Runtime**: A unified plugin engine that lifecycle-manages hardware modules (Camera, Biometrics, Notifications) with zero-config registration.
3.  **[LEVEL 2] Reactive Flux Engine**: A signal-based state management system with built-in persistence, computed derivations, and automatic memory cleanup.
4.  **[LEVEL 3] Fluxy DSL**: A declarative styling and layout language that provides modifier-based parity across all Flutter widgets.

---

## [ENGINE] How it Works

Fluxy operates as a **Structural Authority**. When you initialize `Fluxy.init()`, the framework takes control of the application lifecycle:

*   **Hydration**: Restores persisted state (`flux` signals) from the encrypted vault before the first frame.
*   **Discovery**: Automatically wires up all platform modules via the `FluxyPluginEngine`.
*   **Interception**: Wraps the widget tree in a `FluxyLayoutGuard` that "solves" impossible layout constraints in real-time, preventing the "Red Screen of Death" in production.

---

## [MATRIX] Comparative Analysis

| Feature | Fluxy | BLoC | Provider | GetX |
| :--- | :--- | :--- | :--- | :--- |
| **Logic/UI Binding** | High-Performance Signals | Streams/Events | ChangeNotifiers | Observables |
| **Platform Modules** | Native Managed (Unified) | External Packages | External Packages | Integrated Utils |
| **Stability** | Active Kernel (Auto-Fix) | Passive (Manual) | Passive (Manual) | Passive (Manual) |
| **Boilerplate** | Minimal (Zero-Setup) | High (Event/State) | Medium | Minimal |
| **Architecture** | Managed Runtime | Pattern-Only | Pattern-Only | Utility-First |
| **Enterprise Readiness** | High (Internal Audits) | High | Medium | Medium |

---

## [CODE] Implementation Paradigms

Fluxy simplifies complex Flutter patterns into intuitive, high-performance DSL chains.

### 1. High-Fidelity Infrastructure
```dart
void main() async {
  await Fluxy.init(); // Hydrates state and boots Managed Runtime
  runApp(Fluxy.debug(child: FluxyApp(routes: appRoutes)));
}
```

**v1.0.0 Updates:**
- Modular architecture with separate packages
- Professional logging system with `[KERNEL]`, `[SYS]`, `[DATA]`, `[IO]` tags
- Experimental feature guardrails for OTA, SDUI, and Cloud CLI
- Core package reduced to 172KB for faster installation

### 2. Reactive State with Persistent Vault
```dart
// Native persistence with zero-config encryption
final session = flux<User?>(null, key: 'auth_session', persist: true);

Fx(() => Fx.text("Welcome, ${session.value?.name ?? 'Guest'}")
  .font(size: 18, weight: FontWeight.bold)
  .color(Colors.blueAccent)
  .center()
);
```

**v0.2.6 Updates:**
- Professional logging system replacing emoji-based logs
- Standardized log levels: `[INIT]`, `[READY]`, `[AUDIT]`, `[REPAIR]`, `[FATAL]`, `[PANIC]`
- ASCII framing for diagnostic summaries

**v0.2.5 Updates:**
- Managed Runtime Architecture with `FluxyPluginEngine`
- Unified Platform API (`Fx.platform`) for centralized access
- Automatic plugin registration via `Fluxy.autoRegister()`

### 3. Managed Hardware Interfacing
```dart
Future<void> captureSecure() async {
  final isSecure = await Fx.biometric.authenticate();
  if (isSecure) {
    final image = await Fx.camera.capture();
    await Fx.storage.setSecure('last_scan', image.path);
  }
}
```

**v1.0.0 Modular Packages:**
- `fluxy_forms` - Forms and validation
- `fluxy_camera` - Camera functionality  
- `fluxy_auth` - Authentication and biometrics
- `fluxy_notifications` - Push notifications
- `fluxy_storage` - Data persistence
- `fluxy_test` - Testing utilities
- `fluxy_analytics` - Analytics and tracking
- `fluxy_biometric` - Biometric authentication
- `fluxy_connectivity` - Network connectivity
- `fluxy_permissions` - Device permissions
- `fluxy_platform` - Platform integration
- `fluxy_ota` - Over-the-air updates

**v0.2.5 Platform Modules:**
- Full compatibility with latest platform versions
- Automatic permission handling for Android 13+ and iOS
- Robust "Exact Alarm" fallback logic for notifications

---

## [STRENGTH] Core Pillars

### 1. The Stability Kernel (Resilience)
The framework proactively monitors the render tree. If a layout violation is detected (e.g., an unbounded height inside a scrollable), the Kernel intercepts the exception and applies an **Auto-Repair** (clamping the height to the viewport) to keep the app interactive while logging a diagnostic trace.

### 2. Universal Modifier DSL (Speed)
Development speed is accelerated through a chainable modifier system. Every `Fx` widget supports 100+ modifiers for layout, styling, and motion, which are strictly typed and mirrored into a `FxStyle` object for state-based logic.

### 3. Professional Logging System (v0.2.6)
Fluxy v0.2.6 introduced an industrial-grade logging system that replaces emoji-based logs with semantic bracketed tags for better readability and professional debugging:

```dart
// Professional Log Tags
[KERNEL] [SYS] [DATA] [IO]    // System components
[INIT] [READY] [AUDIT] [REPAIR] [FATAL] [PANIC]  // Log levels
[EXPERIMENTAL]               // Experimental features
```

**Key Features:**
- **Semantic Tags**: `[KERNEL]` for core operations, `[SYS]` for system events
- **Standardized Levels**: `[INIT]` for startup, `[READY]` for operational state
- **ASCII Framing**: Clean diagnostic summaries without visual clutter
- **Experimental Guardrails**: Clear warnings for OTA, SDUI, and Cloud CLI features

### 4. Unified Hardware Access (Consistency)
Accessing `Fx.camera`, `Fx.biometric`, or `Fx.notifications` follows a consistent pattern. All modules share the same permission handling, error reporting, and reactive status signals.

---

## [STATUS] Roadmap & Active Development

Fluxy is under active development with a focus on enterprise-grade features.

*   **[PROG] SDUI (Server-Driven UI)**: Universal JSON-to-Fluxy renderer with dynamic styling. [EXPERIMENTAL]
*   **[PROG] Fluxy Cloud CLI**: Automated CI/CD scaffolding for Android/iOS with zero-config GitHub Actions. [EXPERIMENTAL]
*   **[PROG] Time-Travel Debugging**: Advanced state inspection in the DevTools timeline.
*   **[PROG] OTA (Over-the-Air) Style Updates**: Update app branding and themes without a Store release. [EXPERIMENTAL]

### Recent Releases
- **v1.0.0** (2024-02-23): Modular Architecture with separate packages
- **v0.2.6** (2024-02-20): Industrial Log Professionalization & Experimental Guardrails
- **v0.2.5** (2024-02-15): The Platform Era with Managed Runtime Architecture

**[View Complete Changelog](CHANGELOG.md)**

---

## [COMMUNITY] Support & Contribution

We are seeking contribution from the community to make Fluxy the default standard for professional Flutter apps.

### How to Support:
*   **[CONTRIBUTE]**: Submit PRs for Core Plugins or Layout Modifiers.
*   **[FEEDBACK]**: Document edge cases where the Stability Kernel should intercept.
*   **[SHARE]**: If Fluxy helped you clear a production deadline, share your success story.

**[DOCS]** Visit the [Full Documentation Site](https://fluxy-docs.vercel.app) for in-depth implementation guides.

---

## [LEGAL] Enterprise Reliability
Fluxy is designed for environments where failure is not an option. It provides the structural integrity, global error boundaries, and architectural authority required for large-scale, mission-critical applications.

**Standardize your Flutter engineering with [Fluxy].**
