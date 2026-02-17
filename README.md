# Fluxy: The Application Framework for Flutter

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
*   **Reactive Timeline**: Inspect state updates throughout the application lifecycle.

---

## Technical Quickstart

### Installation
Add Fluxy to your project's dependencies:

```yaml
dependencies:
  fluxy: ^0.2.2
```

### 1. Framework Initialization
```dart
void main() async {
  await Fluxy.init(); // Initialize persistence and framework engines
  
  runApp(
    Fluxy.debug( // Enable professional devtools
      child: FluxyApp(
        initialRoute: homeRoutes.first,
        routes: [...homeRoutes],
      ),
    ),
  );
}
```

### 2. Atomic Reactivity
```dart
final count = flux(0, label: "Counter"); // 'label' makes it readable in DevTools

Fx(() => Fx.text("Current Value: ${count.value}")).center()
```

### 3. Declarative Styling DSL
Construct complex interfaces with a highly efficient, modifier-based syntax.

```dart
Fx.box()
  .w(300).h(200).p(16)
  .glass(10).rounded(24)
  .background(Colors.indigo)
  .animate(fade: 0.0, slide: const Offset(0, 0.2))
  .child(Fx.text("Professional UI").bold().whiteText())
```

---

## Feature Overview

| Feature | Description |
| :--- | :--- |
| **Native Networking** | High-performance, zero-dependency HTTP client with integrated logging. |
| **Architectural Scaffolding** | CLI-driven generation of feature domains, layouts, and models. |
| **Atomic Reactivity** | Fine-grained state management with zero-rebuild overhead. |
| **Scoped Dependency Injection** | Managed dependency lifecycles (App, Route, Factory) with cleanup. |
| **Unified Error Pipeline** | Centralized global error handling for production stability. |
| **Integrated Inspector** | Real-time debugging interface for DI, Networking, and State. |

---

## Enterprise Reliability
Fluxy is built for production environments, featuring global middleware, error boundaries, secure persistence, and comprehensive testing utilities. It provides the structural integrity required for large-scale application development.

**Standardize your architecture with Fluxy.**
