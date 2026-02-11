# Fluxy

**The High-Performance Reactive UI Engine for Flutter.**

Fluxy is a revolutionary framework designed to bring **SwiftUI-style declarativeness** and **Tailwind-style styling velocity** to Flutter. It eliminates deep widget nesting and manual state management, allowing you to build stunning, responsive UIs with pure, expressive code.

[![Pub Version](https://img.shields.io/pub/v/fluxy?color=blue)](https://pub.dev/packages/fluxy)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## Table of Contents
1. [Core Features](#core-features)
2. [Installation](#installation)
3. [The Fx DSL (Building UI)](#the-fx-dsl-building-ui)
4. [Reactive State Management (Signals)](#reactive-state-management-signals)
5. [The Power of Modifiers (Styling)](#the-power-of-modifiers-styling)
6. [Responsive Design (Mobile-First)](#responsive-design-mobile-first)
7. [Navigation & Dependency Injection](#navigation--dependency-injection)
8. [Full API Reference](#full-api-reference)

---

## Core Features

- **Signals**: Zero-boilerplate reactivity. Update only what changes.
- **Fluent API**: Chain styles like `.pad(16).bg(Colors.blue).radius(12)`.
- **Modern Layout**: Built-in support for `gap`, `grid`, and `stack`.
- **Breakpoint Sensitive**: Responsive styles built directly into every widget.
- **Zero-Context Navigation**: Navigate easily with `Fx.go()`.

---

## Installation

Add Fluxy to your `pubspec.yaml`:

```yaml
dependencies:
  fluxy: ^1.0.0-alpha.1
```

---

## The Fx DSL (Building UI)

Fluxy replaces complex Flutter widgets with simple `Fx` methods.

### 1. Basic Layouts
```dart
// Vertical Layout (Column)
Fx.column(
  gap: 16, // Consistent spacing between items
  children: [
    Fx.text("Welcome"),
    Fx.button(onTap: () {}, child: "Get Started"),
  ],
)

// Horizontal Layout (Row)
Fx.row(
  children: [
    Fx.box().size(40, 40).bg(Colors.red),
    Fx.text("Side by side"),
  ],
)
```

### 2. Smart Components
- **`Fx.card()`**: A pre-styled container with shadow and padding.
- **`Fx.button()`**: A responsive button with hover and press effects.
- **`Fx.container()`**: A flexible box (alias for `Fx.box`).

---

## Reactive State Management (Signals)

Fluxy uses **Signals** for state. They are faster than `setState` and easier than `Provider`.

### `flux(value)` - Primitive State
```dart
final count = flux(0); 

// Usage in UI:
Fx.text(() => "Current: ${count.value}") // Automatically updates when value changes
```

### `computed(() => ...)` - Derived State
```dart
final firstName = flux("John");
final fullName = computed(() => "${firstName.value} Doe");
```

### `Fx.async` - Handling API Calls
```dart
final data = asyncFlux(() => api.fetchData());

Fx.async(
  data,
  loading: () => CircularProgressIndicator(),
  error: (err) => Fx.text("Error!"),
  data: (val) => Fx.text("Result: $val"),
)
```

---

## The Power of Modifiers (Styling)

Instead of wrapping widgets in 10 different containers, use **dot notation**.

### Layout & Sizing
- `.pad(16)` / `.padX(12)` / `.padY(8)`
- `.margin(10)`
- `.width(200)` / `.height(50)` / `.size(50, 50)`
- `.center()` / `.align(Alignment.bottomRight)`

### Visuals
- `.bg(Colors.blue)`
- `.radius(12)`
- `.shadow()` / `.border(color: Colors.black)`
- `.opacity(0.8)`
- `.glass(10)` (Apply blur effect)

### Interactive
- `.pointer()` (Show hand cursor)
- `.onTap(() => print("Clicked"))`

### Text Specific
- `.font(18)` / `.bold()` / `.color(Colors.white)`
- `.maxLines(2)` / `.overflow(TextOverflow.ellipsis)`

---

## Responsive Design (Mobile-First)

Fluxy handles different screen sizes effortlessly.

### Breakpoint Overrides
```dart
Fx.box(
  responsive: FxResponsiveStyle(
    xs: FxStyle(padding: EdgeInsets.all(8)),   // Phone
    md: FxStyle(padding: EdgeInsets.all(24)),  // Tablet
    lg: FxStyle(padding: EdgeInsets.all(40)),  // Desktop
  ),
  child: myContent,
)
```

### Conditional Widgets
```dart
Fx.responsive(
  mobile: MobileWidget(),
  desktop: DesktopSidebar(),
)
```

---

## Navigation & Dependency Injection

### Navigation
Navigate from anywhere—no `context` needed!
```dart
Fx.go('/dashboard');
Fx.back();
Fx.offAll('/login'); // Move to page and clear history
```

### Dependency Injection (DI)
```dart
// Register
Fluxy.put(MyService());

// Find anywhere
final service = Fluxy.find<MyService>();
```

---

## Full API Reference

### Layout
| Method | Description |
| :--- | :--- |
| `Fx.box()` | The fundamental <div> equivalent. |
| `Fx.column()` | Vertical flex layout. |
| `Fx.row()` | Horizontal flex layout. |
| `Fx.grid()` | Modern grid layout. |
| `Fx.stack()` | Layered positioning. |
| `Fx.gap(v)` | A spacer between items. |

### Styling Categories
1. **Dimensions**: `width`, `height`, `size`, `aspectRatio`.
2. **Spacing**: `pad`, `padX`, `padY`, `margin`, `marginX`, `marginY`.
3. **Decoration**: `bg`, `radius`, `shadow`, `border`, `glass`, `opacity`.
4. **Text**: `font`, `bold`, `weight`, `color`, `textAlign`, `maxLines`.
5. **Flexbox**: `flex`, `fit`, `expanded`, `space`.

---

## 👋 Build the Future

Fluxy is designed for speed. Check the `/example` folder for 5 full-screen templates including:
- Responsive Dashboard
- Login & Auth
- User Profiles
- Project Management
- Settings Interface

**Build fast. Build beautiful.**

- **Issues**: [GitHub](https://github.com/swaingithub/fluxy/issues)
- **License**: MIT
