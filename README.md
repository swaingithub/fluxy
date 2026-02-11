# 💎 Fluxy

**The High-Performance Reactive UI Engine for Flutter.**

Fluxy is a revolutionary framework that brings the development speed of **SwiftUI** and the styling flexibility of **Tailwind CSS** to the Flutter ecosystem. No more deep widget nesting. No more boilerplate `setState` or `Provider`. Just pure, expressive code.

---

## 🚀 Why Fluxy?

- **Zero-Boilerplate Reactivity**: Use `flux()` signals that automatically update only the widgets that depend on them.
- **Fluent Modifier API**: Style your widgets using chainable methods like `.pad(16).bg(Colors.blue).radius(12)`.
- **Hybrid Styling**: Mix inline modifiers with Tailwind-style utility classes (`Fx.box(className: "p-4 bg-slate-100")`).
- **Web-First Layout**: Native support for `gap`, `flex`, and `grid` systems that behave like modern CSS.
- **Zero-Context Navigation**: Navigate anywhere with `Fx.go('/home')` without passing `BuildContext`.

---

## 📦 Installation

Add Fluxy to your `pubspec.yaml`:

```yaml
dependencies:
  fluxy: ^1.0.0-alpha.1
```

---

## 🛠️ Quick Start

### 1. The Reactive Counter

```dart
final count = flux(0); // Create a signal

Widget build(BuildContext context) {
  return Fx.column(
    gap: 20,
    children: [
      Fx.text(() => "Count is: ${count.value}").font(24).bold(),
      Fx.button(
        onTap: () => count.value++,
        child: "Increment",
      ),
    ],
  ).center();
}
```

### 2. Modern Components

```dart
Fx.card(
  child: Fx.row(
    gap: 12,
    children: [
      Fx.box().size(48, 48).bg(Colors.blue).radius(12).center()
        .child(Icon(Icons.bolt, color: Colors.white)),
      Fx.column(
        children: [
          Fx.text("Fluxy v1.0").bold(),
          Fx.text("SwiftUI for Flutter").color(Colors.grey),
        ],
      ),
    ],
  ),
).pad(16);
```

### 3. Responsive Layouts

```dart
Fx.responsive(
  mobile: Fx.text("Compact View"),
  tablet: Fx.row(children: [...]),
  desktop: MyComplexDashboard(),
);
```

---

## 🎨 Design System

Fluxy comes with a powerful `FxStyle` engine that powers the fluent API:

- **Layout**: `pad`, `margin`, `width`, `height`, `size`, `align`, `center`, `spacer`
- **Flex**: `flex`, `flexGrow`, `flexShrink`, `gap`, `expanded`
- **Visuals**: `bg`, `radius`, `shadow`, `border`, `opacity`, `glass`
- **Text**: `font`, `bold`, `color`, `weight`, `lSpacing`, `lHeight`, `maxLines`

---

## 👋 Community & Support

- **Bugs/Features**: Open an issue on [GitHub](https://github.com/fluxy/fluxy/issues).
- **Discussions**: Join our developer community on Discord.

Fluxy is built for developers who care about **Performance** and **Velocity**. Join the revolution. 🚀
