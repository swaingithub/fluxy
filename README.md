# Fluxy: The Full-Stack Application Platform for Flutter

Fluxy is a comprehensive development platform designed to extend the capabilities of Flutter. It unifies high-performance reactive state management, a declarative fluent UI DSL, cloud-based CI/CD orchestration, and Over-The-Air (OTA) distribution into a single, cohesive engine.

Fluxy is built for engineering teams who require rapid iteration, simplified state synchronization, and sophisticated infrastructure for mobile application deployment.

[![Pub Version](https://img.shields.io/pub/v/fluxy?color=blue)](https://pub.dev/packages/fluxy)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## Technical Overview

Modern application development often faces challenges with widget tree depth, state management boilerplate, and slow deployment cycles. Fluxy addresses these bottlenecks by introducing a platform-layer on top of the Flutter core.

### Core Pillars

1. **Signals-Based Reactivity**: An atomic state management system based on dependency tracking, eliminating the need for `setState`, `ChangeNotifier`, or complex boilerplate.
2. **Fluent UI DSL**: A chainable API for building and styling interfaces that reduces code verbosity and improves maintainability.
3. **Fluxy Cloud**: An automated build and deployment orchestration layer using GitHub Actions for serverless CI/CD.
4. **Over-The-Air (OTA) Updates**: A Server-Driven UI (SDUI) engine that allows developers to update application logic and interfaces instantly without re-submitting to App Stores.
5. **Fluxy Play**: A companion preview environment that enables on-device testing of remote assets without native compilation.

---

## Feature Comparison

| Capability | Standard Flutter | Fluxy Platform |
| :--- | :--- | :--- |
| **State Management** | Provider / BLoC / Riverpod | **Signals (Atomic Dependency Tracking)** |
| **UI Paradigm** | Nested Widget Trees | **Fluent, Chainable DSL** |
| **Build Pipeline** | Manual Native Compilation | **Fluxy Cloud (GitHub Actions Integration)** |
| **Distribution** | App Store / Play Store Review | **Instant OTA (Server-Driven UI)** |
| **On-Device Previews** | Hot Reload (compilation needed) | **Fluxy Play (Instant Manifest Preview)** |
| **Analysis & Debug** | Dart DevTools | **Integrated Reactive Graph Inspector** |

---

## Installation

Add Fluxy to your `pubspec.yaml` file:

```yaml
dependencies:
  fluxy: ^0.0.6
```

Then, activate the Fluxy CLI globally for project orchestration:

```bash
dart pub global activate fluxy
```

---

## Core Framework Usage

### Reactive State Management

Fluxy utilizes **Signals** to manage state. A signal is an atomic value that tracks its subscribers and notifies them only when the value changes.

```dart
// Define a reactive signal
final count = flux(0);

// Consume in a reactive UI
Fx.column(
  children: [
    Fx.text(() => "Current Value: ${count.value}").font(32).bold(),
    Fx.button("Increment", onTap: () => count.value++).bg(Colors.blue).pad(16)
  ]
).center();
```

### Server-Driven UI (OTA)

Fluxy allows you to render entire application modules remotely using JSON manifests. This enables instant updates and A/B testing.

```dart
// Render a remote view from a manifest URL
FxRemoteView(
  path: 'https://cdn.example.com/assets/dashboard.json',
  placeholder: CircularProgressIndicator(),
);

// Trigger a background update of the application assets
Fluxy.update('https://cdn.example.com/manifest.json');
```

---

## Command Line Interface (CLI)

The Fluxy CLI facilitates project scaffolding and cloud integration.

- **Initialization**: `fluxy init <app_name>` - Scaffolds a new project with the Fluxy architecture.
- **Development**: `fluxy run` - Optimized development runner.
- **Cloud Builds**: `fluxy cloud build <android|ios>` - Configures GitHub Actions for automated cloud builds.
- **Deployment**: `fluxy cloud deploy` - Sets up automated deployment to TestFlight and Google Play.

---

## Performance and Optimization

Fluxy is designed with a "Payload-First" philosophy:

- **Atomic Rebuilds**: Only widgets that directly consume a signal are rebuilt, minimizing CPU cycles.
- **Dependency Tree-Shaking**: The framework is modular, ensuring that unused features (like Cloud or OTA) are removed during the production compile phase.
- **Native Efficiency**: Fluxy compiles directly to ARM/x64 machine code via the Flutter compiler, maintaining 60/120 FPS performance.

---

## Debugging and Developer Tooling

Fluxy provides an integrated in-app inspector for monitoring the reactive graph and performance metrics.

```dart
void main() {
  // Initialize debugging extensions
  FluxyDebug.init();
  
  runApp(
    Fluxy.debug(
      child: MyApp(),
    ),
  );
}
```

---

## Roadmap and Release Status

- **Signals & State Engine**: Production Ready
- **Fluent UI Extensions**: Production Ready
- **Motion & Animation Engine**: Production Ready
- **Fluxy CLI & Cloud Sync**: Production Ready
- **Over-The-Air Distribution**: Production Ready
- **DevTools Service Extensions**: Beta
- **Fluxy Play Environment**: Production Ready

---

## Documentation and Community

- **Official Documentation**: [fluxy-doc.vercel.app](https://fluxy-doc.vercel.app/)
- **Source Repository**: [github.com/swaingithub/fluxy](https://github.com/swaingithub/fluxy)
- **Issue Tracking**: [Report a Bug](https://github.com/swaingithub/fluxy/issues)

---

## License

Fluxy is released under the **MIT License**.
Copyright © 2026. All rights reserved.

---

**Build faster. Write cleaner. Scale confidently.**
