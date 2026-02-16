# Fluxy: The Application Framework for Flutter

Fluxy is a comprehensive, production-grade application platform unifying the entire development lifecycle. It moves beyond "state management" to provide a complete structural foundation, including **Native High-Performance Networking, Atomic Reactivity, Lifecycle Controllers, Offline-First Repositories, and Zero-Glue Tooling.**

---

## 🚀 The Framework Philosophy

Fluxy isn't just a library; it's a **Structural Authority** for Flutter. It solves the "Classical Rebuild Problem" and eliminates the need for third-party networking bloat by providing native, industry-standard engines out of the box.

### 🏛️ The Fluxy Standard (Official Architecture)

Fluxy is opinionated about structure. To ensure scalability and "Senior Grade" code quality, we officially recommend the **Core/Features** pattern:

```text
lib/
 ├── core/            # Platform-wide services, middleware, and global themes
 └── features/        # Business domains (Feature-based decomposition)
      └── dashboard/
           ├── dashboard.controller.dart  # Business logic & UI State
           ├── dashboard.repository.dart  # Data Layer (Remote/Local)
           ├── dashboard.view.dart        # Pure UI Components (DSL)
           └── dashboard.routes.dart      # Feature-specific route map
```

### ⚡ CLI Power (Generating Solutions)

Don't just scaffold folders; scaffold **solutions.**
```bash
# Generate a complete login feature with UI, logic, and networking
fluxy g auth login

# Generate a social news feed with shimmer loaders and native sync
fluxy g news feed
```

---

## 💎 Core Framework Pillars

### 1. Native Fluxy Networking (`Fx.http`)
A zero-dependency, high-performance HTTP client built directly into the framework.
*   **Zero Glues**: Automatically serialized JSON and error handling.
*   **Interceptors**: Native request/response hooks.
*   **Global Config**: Set base URLs and timeouts once.

```dart
final response = await Fx.http.get('/profile');
print(response.data['username']); // Already decoded Map
```

### 2. Architectural Controllers (`FluxController`)
Define exactly where logic lives. Fluxy automatically manages the lifecycle of your controllers when bound to routes.

```dart
class AuthController extends FluxController {
  final user = flux<User?>(null);

  @override
  void onInit() {
    loadUser(); // Called when injected/routed
  }
}
```

### 3. High-Performance Isolate Workers (`fluxIsolate`)
Kill UI jank by moving heavy tasks to background threads natively.

*   **`fluxIsolate`**: Simple fire-and-forget background tasks (Standard `Future`).
*   **`fluxWorker`**: Reactive background workers with built-in loading/error states.

---

## 🛠️ Usage Quickstart

### Installation
```yaml
dependencies:
  fluxy: ^0.1.9
```

### 1. Initialize the Engine
```dart
void main() async {
  await Fluxy.init(); // Setup Persistence & Middleware
  runApp(FluxyApp(routes: myRoutes));
}
```

### 2. Atomic Reactivity
```dart
final count = flux(0);

Fx(() => Fx.text("Value: ${count.value}")).center()
```

### 3. Declarative Styling DSL
Build beautiful, high-performance interfaces with 70% less code.

```dart
Fx.box()
  .w(300).h(200).p(16)
  .glass(10).rounded(24)
  .background(Colors.indigo)
  .animate(fade: 0.0, slide: const Offset(0, 0.2))
  .child(Fx.text("Premium UI").bold().whiteText())
```

---

## ✨ Feature Matrix

| Feature | Description |
| :--- | :--- |
| **Native Networking** | Zero-dependency high-performance HTTP client (`Fx.http`). |
| **Blueprints** | Scaffolds complete feature solutions (Login, Feed, etc.). |
| **Atomic Signals** | High-performance state tracking with zero-rebuild overhead. |
| **Controllers** | Formalized business logic layer with lifecycle hooks. |
| **Repositories** | Standardized offline-first patterns with recursive sync. |
| **Local OTA Server** | Instant local development for Server-Driven UI (`fluxy serve`). |

---

## 🛡️ Senior Grade Reliability
Fluxy includes built-in Middleware, Global Error Boundaries, Deep Persistence, and an integrated **Reactive Inspector** to ensure your production environment is always healthy.

**Build faster. Architecture smarter. Scale with Fluxy.**
