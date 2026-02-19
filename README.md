# Fluxy: The Stability-First Engineering Engine

Fluxy is a comprehensive, production-grade application platform designed to unify the entire development lifecycle. It provides a complete structural foundation, moving beyond simple state management to offer native high-performance networking, atomic reactivity, lifecycle controllers, offline-first repositories, and integrated developer tooling.

---

## Framework Philosophy

Fluxy serves as a structural authority for the Flutter ecosystem. It is designed to solve common architectural challenges, such as the classical rebuild problem, while eliminating the need for excessive third-party dependencies by providing robust, native engines for core tasks.

### The Fluxy Standard (Official Architecture)

Fluxy promotes an opinionated structure to ensure scalability and maintainable code quality. The recommended pattern is the Core/Features decomposition:

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

### CLI Support (Solution Generation)

The Fluxy CLI facilitates rapid development by scaffolding entire architectural solutions.

```bash
# Generate a complete feature domain with UI, logic, and networking
fluxy g auth login

# Generate a responsive layout template
fluxy g layout main
```

---

## Core Framework Pillars

### 1. Project-Based Networking (FluxyHttp)
A high-performance HTTP client built directly into the framework.
*   **Automatic Serialization**: Native support for JSON serialization and error handling.
*   **Global Interceptors**: Comprehensive request and response hook management.
*   **Unified Configuration**: Centralized management for base URLs, headers, and timeouts.

```dart
final response = await Fx.http.get('/profile');
print(response.data['username']); // Automatically decoded
```

### 2. Architectural Controllers (FluxController)
Fluxy provides a formalized logic layer with native lifecycle management. Controllers are automatically managed by the framework when associated with routes.

```dart
class AuthController extends FluxController {
  final user = flux<User?>(null);

  @override
  void onInit() {
    loadUser(); // Executed upon association
  }
}
```

### 3. Integrated Developer Tools (Fluxy Inspector)
The framework includes a premium debugging interface available in non-release modes.
*   **DI Container Inspection**: Review active dependencies and their lifecycle scopes.
*   **Network Activity Monitoring**: Track real-time network requests and payloads.
*   **Stability Dashboard**: Real-time visualization of auto-repaired layout violations and stability metrics.

### 4. Fluxy Stability Kernel™ (SafeUI)
Fluxy proactively prevents 80% of common Flutter layout crashes (unbounded height/width, nested scrollables) by introducing framework-level safeguards and an auto-repair engine.
*   **Auto-Constraint Enforcement**: Widgets automatically fallback to safe dimensions in unbounded contexts.
*   **Flex Solver Intelligence**: Automatically repairs "Infinite Constraint" violations in `FxRow` and `FxCol` when stretching inside scrollables.
*   **Real-time Repairs**: All layout corrections are logged and visible in the Fluxy Inspector.

### 5. Universal Style Engine™
Fluxy mirrors all visual modifiers into the `FxStyle` object, enabling high-fidelity interactive state modeling. Use the same modifiers in `onHover` or `onPressed` builders that you use on the widgets themselves.

---

## Technical Quickstart

### Installation
Add Fluxy to your project's dependencies:

```yaml
dependencies:
  fluxy: ^0.2.4
```

### 1. Framework Initialization
```dart
void main() async {
  await Fluxy.init(); // Initialize persistence and framework engines
  
  runApp(
    Fluxy.debug( // Enable professional devtools + Layout Guard
      child: FluxyApp(
        initialRoute: homeRoutes.first,
        routes: [...homeRoutes],
      ),
    ),
  );
}
```

### 2. Atomic Reactivity & Magical Persistence
```dart
// Automatic offline-first persistence with one flag
final balance = flux(100.0, key: "user_balance", persist: true); 

Fx(() => Fx.text("Balance: ${balance.value}")).center()
```

### 3. Data Visualization (Fx.chart)
Create high-performance, reactive charts with zero boilerplate.

```dart
Fx.chart(
  data: mySignal, 
  type: FxChartType.line
).h(250).pressScale()
```

---

## Feature Overview

| Feature | Description |
| :--- | :--- |
| **Stability Kernel™** | Full-stack crash protection: Layout, State, Async, Data, and Interaction guards. |
| **Data Visualization** | High-performance, reactive Bar and Line charts with smooth entrance animations. |
| **Style Engine™** | Modifier parity across widgets and styles for high-fidelity interactive design. |
| **Magical Persistence** | Automatic state serialization and hydration via the `persist: true` flag. |
| **Viewport Architecture** | Native support for robust, scrollable layouts via `Fx.viewport`, `Fx.scrollCenter`, and `Fx.sliver`. |
| **Motion DSL** | Physics-based animation presets and orchestrated staggered reveals. |
| **Semantic Proxies** | Global theme-aware color getters (`Fx.primary`, `Fx.success`) for rapid styling. |
| **Native Primitives** | Premium Infinite List, Parallax, and Pull-to-Refresh with zero boilerplate. |

---

## Enterprise Reliability
Fluxy is built for production environments, featuring global middleware, error boundaries, secure persistence, and comprehensive testing utilities. It provides the structural integrity required for large-scale application development.

**Standardize your architecture with Fluxy.**
