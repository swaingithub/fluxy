# Fluxy Documentation (v0.0.5)

This guide provides a detailed look at how to use Fluxy's highly efficient development engine.

---

## 1. CLI & Project Setup 🚀 (New in v0.0.5)

Fluxy now includes a powerful CLI to scaffold projects and generate modules instantly, similar to Next.js or Expo.

### Activation
```bash
dart pub global activate fluxy
```

### Commands
- **Initialize Project**: Sets up a scalable folder structure (routes, modules, data, theme).
  ```bash
  fluxy init
  ```

- **Generate Page**: Creates a reactive page and registers it automatically.
  ```bash
  fluxy gen:page Home
  ```
  *(Creates `lib/app/modules/home/home_page.dart` and `home_controller.dart`)*

- **Generate Controller**: Creates a standalone reactive controller with lifecycle hooks.
  ```bash
  fluxy gen:controller Auth
  ```

---

## 2. Core UI Components

Fluxy simplifies Flutter widgets into a clean API called `Fx`.

### Fx.box()
The base container, similar to a `div` in HTML.
- **Usage**: Use it for single items that need specific styling or positioning.
- **Key Modifiers**: `.width()`, `.height()`, `.bg()`, `.radius()`.

### Fx.column() & Fx.row()
Used for laying out multiple items vertically or horizontally.
- **`gap`**: The most important property. It sets equal spacing between all children automatically.
- **Example**:
  ```dart
  Fx.column(
    gap: 20,
    children: [
      Fx.text("Header"),
      Fx.text("Subheader"),
    ],
  )
  ```

### Fx.grid()
For building responsive grids.
- **`crossAxisCount`**: How many columns you want.
- **`minColumnWidth`**: If you set this (e.g., 200), Fluxy will automatically choose the number of columns that fit the screen.

### Fx.stack() & Fx.positioned()
For absolute positioning. Use `.top()`, `.left()` modifiers on children.

---

## 3. Reactive UI (Signals)

Fluxy makes your UI "smart" using **Signals**. When a signal changes, **only the specific widget using it rebuilds**.

### Creating State
```dart
final count = flux(0); // Atomic integer signal
final user = flux(User(name: "Alice")); // Complex object signal
```

### Displaying State
Wrap your data access in `Fx()` or `Fx.text()` to track it automatically.
```dart
Fx.text(() => "Count is: ${count.value}")
```

### Updating State
```dart
Fx.button(
  onTap: () => count.value++, // UI updates instantly!
  child: "Increment",
)
```

---

## 4. Fluxy DevTools 🛠️ (New in v0.0.5)

Inspect your state changes in real-time with the built-in debugger.

### Enable DevTools
Wrap your app root:
```dart
void main() {
  runApp(
    Fluxy.debug(
      child: MyApp(),
    ),
  );
}
```

### Features
- **Signal Graph**: Visualize all active signals and their values.
- **Timeline Logs**: See a history of state changes as they happen.
- **Floating Inspector**: Toggle the overlay with a floating button.

---

## 5. Production Stability (New in v0.0.5)

### Global Error Boundary
FluxyApp now automatically catches exceptions in the widget tree to prevent "Red Screen of Death" crashes in production.

```dart
FluxyApp(
  home: HomePage(),
  // In release mode, users see a polished error screen.
  // In debug mode, you see the full stack trace.
);
```

### Input Safety
`FxTextField` has been rewritten for robustness. It now correctly disposes of controllers and supports two-way binding.

```dart
final email = flux("");

FxTextField(
  signal: email,
  placeholder: "Enter email",
)
```

---

## 6. The Modifier System (Styling)

Modifiers are chainable methods that style your widget. They replace complex wrappers.

- **`.pad(20)`**: Adds padding.
- **`.center()`**: Centers the child.
- **`.bg(Colors.blue)`**: Sets background.
- **`.radius(15)`**: Rounds corners.
- **`.shadow(blur: 10)`**: Adds shadow.
- **`.animate()`**: Adds motion effects (fade, slide, scale).

---

## 7. Navigation & D.I.

### Navigation
Navigate without context.
- `Fx.go('/home')`
- `Fx.back()`
- `FluxyRouter.to('/details', arguments: {'id': 1})`

### Dependency Injection
- `Fluxy.put(MyController())`
- `Fluxy.find<MyController>()`

---

© 2026 Fluxy Framework. Build fast. Build beautiful.
