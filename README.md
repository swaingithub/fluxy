# Fluxy: The Full-Stack Application Platform for Flutter

Fluxy is a comprehensive development platform designed to extend the capabilities of Flutter. It unifies high-performance reactive state management, a declarative **Atomic Styling DSL**, cloud-based CI/CD orchestration, and Over-The-Air (OTA) distribution into a single, cohesive engine.

Fluxy is built for engineering teams who require rapid iteration, simplified state synchronization, and sophisticated infrastructure for mobile application deployment.

[![Pub Version](https://img.shields.io/pub/v/fluxy?color=blue)](https://pub.dev/packages/fluxy)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## Technical Overview

Modern application development often faces challenges with widget tree depth, state management boilerplate, and sluggish deployment cycles. Fluxy addresses these bottlenecks by bringing a "SwiftUI-like" experience to Flutter.

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
  fluxy: ^0.1.3
```

Then, activate the Fluxy CLI globally for project orchestration:

```bash
dart pub global activate fluxy
```

---

## What's New in 2.0 DSL

Fluxy 0.1.4 introduces a massive DSL upgrade to rival standard declarative frameworks.

### 1. Enhanced Input System
A production-grade text input supporting validation, formatting, and focus control.

```dart
Fx.input(
  signal: email,
  placeholder: "Enter email",
  keyboardType: TextInputType.emailAddress,
  inputFormatters: [LengthLimitingTextInputFormatter(50)],
  validators: [
    (val) => val.contains('@') ? null : "Invalid email",
    (val) => val.length > 5 ? null : "Too short"
  ]
)
```

### 2. Spacing & Layout DSL
Gone are the days of manual `SizedBox`. Use fluent gaps and spacing.

```dart
Fx.row(
  children: [
    Fx.text("Item 1"),
    Fx.gap(16),       // Intelligent Gap
    Fx.text("Item 2"),
    Fx.hgap(8),       // Horizontal Gap
    Fx.text("Item 3"),
  ]
).gap(12) // Flex gap
```

### 3. Declarative Conditionals
Cleaner conditional rendering without ternary clutter.

```dart
Fx.cond(
  isLoading,
  Fx.text("Loading..."),
  Fx.button("Submit")
)
```

### 4. Duration Extensions
Readable time definitions.

```dart
Fx.text("Fade In")
  .animate(
    duration: 500.ms,
    delay: 1.sec,
    fade: 0.0
  )
```

---

## Core Framework Usage

### Atomic Styling DSL

```dart
Fx.scaffold(
  appBar: Fx.appBar(title: "Fluxy 2.0"),
  body: Fx.col(children: [
    Fx.text("Upgrade Complete").font.xl.bold.center(),
    
    // Scrollable list with container styling
    Fx.list(children: [
      Fx.text("Feature A").p(12).bg.slate50,
      Fx.text("Feature B").p(12).bg.slate50,
    ])
    .gap(8)
    .padding(16)
    .border(Colors.grey)
    .expand() // Fills remaining space
  ])
)
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

---

## Command Line Interface (CLI)

The Fluxy CLI facilitates project scaffolding and cloud integration.

- **Initialization**: `fluxy init <app_name>` - Scaffolds a new project with the Fluxy architecture.
- **Development**: `fluxy run` - Optimized development runner.
- **Cloud Builds**: `fluxy cloud build <android|ios>` - Configures GitHub Actions for automated cloud builds.
- **Deployment**: `fluxy cloud deploy` - Sets up automated deployment to TestFlight and Google Play.

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
