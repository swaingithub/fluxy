# Fluxy — Reactive UI + State + Fluent DSL for Flutter

**Build Flutter apps with SwiftUI-like syntax, fine-grained reactivity, and zero boilerplate.**

Fluxy is a next-generation reactive UI engine for Flutter that unifies **declarative layouts**, **signals-based state management**, and **utility-first styling** into a single, elegant developer experience.

[![Pub Version](https://img.shields.io/pub/v/fluxy?color=blue)](https://pub.dev/packages/fluxy)
[![Pub Likes](https://img.shields.io/pub/likes/fluxy)](https://pub.dev/packages/fluxy)
[![Pub Popularity](https://img.shields.io/pub/popularity/fluxy)](https://pub.dev/packages/fluxy)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## Why Fluxy?

Flutter is powerful, but as applications scale, developers often face:

* Deep widget nesting
* Excessive boilerplate
* Complex state wiring
* Heavy reliance on `BuildContext`

Fluxy solves these problems by introducing a **modern reactive architecture inspired by SwiftUI, SolidJS, and Tailwind CSS**, while remaining fully compatible with Flutter’s rendering engine.

Fluxy enables developers to write **clean, expressive UI code**, manage state with **atomic reactivity**, and style interfaces with **fluent, chainable APIs**.

---

## Minimal Example

```dart
final count = flux(0);

Fx.column(
  Fx.text(() => "Count: ${count.value}").font(32).bold(),
  Fx.button("+", onTap: () => count.value++)
      .bg(Colors.blue)
      .radius(12)
      .pad(12)
)
.center()
.pad(24);
```

**No `setState`, no builders, no boilerplate. Just reactive UI.**

---

## Core Advantages

* **Signals-Based Reactivity**
  Reactive state powered by dependency tracking. UI updates automatically when data changes.

* **Atomic UI Rebuilds**
  Only the widgets directly dependent on changed state are rebuilt, resulting in smoother animations and lower CPU usage.

* **Fluent Styling API**
  Chainable modifiers like `.bg().radius().pad()` eliminate verbose `BoxDecoration` code.

* **Declarative Layout DSL**
  Readable layout primitives such as `Fx.column`, `Fx.row`, and `Fx.stack`.

* **Utility-First Styling**
  Tailwind-inspired `className` system for rapid UI construction.

* **Zero Boilerplate State**
  No providers, no context lookups, no event classes.

---

## Flutter vs Fluxy

| Feature        | Standard Flutter           | Fluxy                     |
| -------------- | -------------------------- | ------------------------- |
| Syntax         | Nested widgets             | Fluent chaining           |
| State          | setState / Provider / BLoC | Signals (`flux()`)        |
| Rebuild Scope  | Widget-level               | **Atomic micro-rebuilds** |
| Boilerplate    | High                       | **Minimal**               |
| Styling        | BoxDecoration              | Utility + modifiers       |
| Learning Curve | Medium                     | **Low**                   |

---

## Installation

```yaml
dependencies:
  fluxy: ^0.0.3
```

---

## Quick Start

### Reactive Counter

```dart
final count = flux(0);

class CounterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Fx.column(
      children: [
        Fx.text(() => "Count: ${count.value}")
            .font(42)
            .bold(),

        Fx.button(
          "+",
          onTap: () => count.value++,
        ).bg(Colors.indigo).radius(16).pad(12),
      ],
    ).center();
  }
}
```

---

## Reactive Engine

Fluxy is built on a **fine-grained reactivity graph** that tracks dependencies at the signal level.

### Signals

```dart
final username = flux("Guest");

username.value = "John"; // UI updates instantly
```

---

### Computed Signals

```dart
final a = flux(10);
final b = flux(20);

final total = computed(() => a.value + b.value);
```

---

### Effects

```dart
effect(() {
  print("Count changed → ${count.value}");
});
```

---

## Fluent UI Styling

### Modifiers

```dart
Fx.box()
  .size(120, 120)
  .bg(Colors.teal)
  .radius(20)
  .shadow(blur: 16)
  .center()
  .child(Fx.text("Fluxy").color(Colors.white));
```

---

### Utility Classes

```dart
Fx.box(
  className: "px-6 py-4 bg-slate-900 rounded-2xl items-center",
  child: Fx.text("Utility Styling").color(Colors.white),
);
```

---

## Responsive Design

```dart
Fx.box(
  responsive: FxResponsiveStyle(
    xs: FxStyle(padding: EdgeInsets.all(8)),
    md: FxStyle(padding: EdgeInsets.all(24)),
    lg: FxStyle(padding: EdgeInsets.all(48)),
  ),
);
```

---

## Navigation & Dependency Injection

```dart
Fx.go("/dashboard");

final api = Fluxy.find<ApiService>();
```

---

## Internal Architecture

Fluxy consists of four tightly integrated subsystems:

1. **Reactivity Graph**
   Tracks relationships between signals and widgets.

2. **Diff Engine**
   Calculates minimal UI changes to avoid redundant rebuilds.

3. **Style Resolver**
   Merges className utilities, inline styles, and responsive rules.

4. **Decoration Mapper**
   Converts Fluxy styles into native Flutter render objects.

---

## Performance Philosophy

Fluxy is designed around:

* Minimal widget rebuilds
* Batched state propagation
* GPU-friendly rendering paths
* Zero unnecessary layout recalculations

This results in **smoother animations, faster rebuilds, and lower power consumption**.

---

## Roadmap

* [ ] Fluxy CLI
* [ ] DevTools & State Inspector
* [ ] Motion Engine (`.animate()`)
* [ ] Reactive Layout Transitions
* [ ] Theme Orchestration System
* [ ] Desktop & Web Optimization Layer

---

## Who Should Use Fluxy?

* Flutter developers seeking SwiftUI-style development
* Teams building high-performance dashboards
* Startups optimizing iteration speed
* Engineers tired of widget boilerplate

---

## Community & Support

* GitHub Issues: [https://github.com/swaingithub/fluxy/issues](https://github.com/swaingithub/fluxy/issues)
* Discussions: [https://github.com/swaingithub/fluxy/discussions](https://github.com/swaingithub/fluxy/discussions)

---

## License

MIT License
Copyright © 2026

---

# Final Note

Fluxy is not just a UI helper.
It is an **entire rethinking of Flutter application architecture.**

**Build faster. Write cleaner. Scale confidently.**
