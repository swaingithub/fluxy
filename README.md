# Fluxy: The Full-Stack Application Platform for Flutter

Fluxy is a comprehensive development platform designed to extend the capabilities of Flutter. It unifies high-performance reactive state management, a declarative **Atomic Styling DSL**, cloud-based CI/CD orchestration, and Over-The-Air (OTA) distribution into a single, cohesive engine.

Fluxy is built for engineering teams who require rapid iteration, simplified state synchronization, and sophisticated infrastructure for mobile application deployment.

[![Pub Version](https://img.shields.io/pub/v/fluxy?color=blue)](https://pub.dev/packages/fluxy)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## Technical Overview

Modern application development often faces challenges with widget tree depth, state management boilerplate, and sluggish deployment cycles. Fluxy addresses these bottlenecks by introducing a platform-layer on top of the Flutter core.

### Core Pillars

1. **Signals-Based Reactivity**: An atomic state management system based on dependency tracking, eliminating the need for `setState`, `ChangeNotifier`, or complex boilerplate.
2. **Atomic Styling DSL**: A hyper-expressive, chainable API for building interfaces. Use shorthands like `.p(16)`, `.mt(8)`, and `.shadowXL()` to build complex UIs with 70% less code.
3. **Fluxy Cloud**: An automated build and deployment orchestration layer using GitHub Actions for serverless CI/CD.
4. **Instant OTA (Server-Driven UI)**: A SDUI engine that allows developers to update application logic and interfaces instantly without re-submitting to App Stores.
5. **Integrated DevTools**: A premium reactive graph inspector and state debugger built directly into the framework.

---

## Feature Comparison

| Capability | Standard Flutter | Fluxy Platform |
| :--- | :--- | :--- |
| **State Management** | Provider / BLoC / Riverpod | **Signals (Atomic Dependency Tracking)** |
| **UI Paradigm** | Nested Widget Trees | **Chainable Atomic DSL (Fluent)** |
| **Build Pipeline** | Manual Native Compilation | **Fluxy Cloud (GitHub Actions Integration)** |
| **Distribution** | App Store / Play Store Review | **Instant OTA (Server-Driven UI)** |
| **Developer Tools** | External DevTools | **Integrated In-App Reactive Inspector** |

---

## Installation

Add Fluxy to your `pubspec.yaml` file:

```yaml
dependencies:
  fluxy: ^0.1.1
```

Then, activate the Fluxy CLI globally for project orchestration:

```bash
dart pub global activate fluxy
```

---

## Core Framework Usage

### Atomic Styling DSL (New in 0.1.1)

Fluxy 0.1.1 introduces **Atomic Modifiers**, allowing you to style any widget fluently.

```dart
Fx.column(
  gap: 12,
  children: [
    Fx.avatar(fallback: "JD").size(FxAvatarSize.xl),
    Fx.text("John Doe").bold().fontSize(24).mt(4),
    Fx.button("Follow", onTap: () {})
        .p(16)
        .px(32)
        .bg(Colors.blue)
        .shadowXL()
  ]
).center().p(24);
```

### Reactive State Management

Fluxy utilizes **Signals** to manage state. A signal is an atomic value that tracks its subscribers and notifies them only when the value changes.

```dart
// Define a reactive signal
final count = flux(0);

// Consume in a reactive UI
Fx.column(
  children: [
    Fx.text(() => "Current Value: ${count.value}").font(32).bold(),
    Fx.button("Increment", onTap: () => count.value++)
  ]
).center();
```

### Premium Widgets

Fluxy includes a suite of high-performance widgets designed for modern apps:
- **FxAvatar**: Smart profile images with fallbacks and multiple shapes.
- **FxBadge**: Notification overlays that anchor to any widget.
- **FxDropdown**: Overlay-based "web-style" selection with custom slide animations.
- **FxBottomBar**: Premium pill-style navigation with smooth physics.

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
- **Dependency Tree-Shaking**: The framework is modular, ensuring that unused features are removed during production compilation.
- **Native Efficiency**: Fluxy compiles directly to ARM/x64 machine code via the Flutter compiler, maintaining 60/120 FPS performance.

---

## Roadmap and Release Status (v0.1.1 Alpha)

- **Signals & State Engine**: Production Ready
- **Atomic DSL & Modifiers**: Production Ready
- **Premium Widget Suite**: Production Ready
- **Fluxy CLI & Cloud Sync**: Production Ready
- **Over-The-Air Distribution**: Production Ready
- **Reactive Inspector**: Beta

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
