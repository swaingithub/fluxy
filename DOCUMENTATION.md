# Fluxy Documentation

This guide provides a detailed look at how to use Fluxy's UI components, state management, and styling systems.

---

## 1. Core UI Components

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

### Fx.stack()
For placing items on top of each other. Use it with `.top()`, `.bottom()`, `.left()`, and `.right()` mods on children for absolute positioning.

---

## 2. Reactive UI (Signals)

Fluxy makes your UI "smart" using **Signals**. When a signal changes, **only the specific widget using it rebuilds**.

### Creating State
```dart
final count = flux(0); // A signal holding an integer
final name = flux("Alice"); // A signal holding a string
```

### Displaying State
Wrap your data access in an anonymous function `() =>` so Fluxy can track it.
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

## 3. The Modifier System (Styling)

Modifiers are chainable methods that style your widget. They replace the complex `BoxDecoration` and `Padding` widgets.

### Most Common Modifiers:

#### Spacing & Alignment
- **`.pad(20)`**: Adds 20px padding on all sides.
- **`.padX(10)`**: Adds 10px padding to left and right only.
- **`.center()`**: Centers the widget child.
- **`.align(Alignment.topRight)`**: Positions the child at the top right.

#### Visuals
- **`.bg(Colors.blue)`**: Sets the background color.
- **`.radius(15)`**: Rounds the corners.
- **`.border(color: Colors.black, width: 2)`**: Adds a stroke.
- **`.shadow()`**: Adds a soft shadow effect.
- **`.glass(10)`**: Adds a modern blur effect (Glassmorphism).

#### Text Styling
- **`.font(18)`**: Sets the font size.
- **`.bold()`**: Makes text bold.
- **`.color(Colors.white)`**: Sets text color.
- **`.maxLines(1)`**: Limits text to one line and adds "..." if it overflows.

---

## 4. Responsive Design

Fluxy handles screen sizes automatically using a **mobile-first** approach. Use `FxResponsiveStyle` to change how a widget looks on different devices.

- **`xs`**: Phone (Default)
- **`sm`**: Tablet Portrait
- **`md`**: Tablet Landscape
- **`lg`**: Desktop
- **`xl`**: Large Monitor

**Example**:
```dart
Fx.box(
  responsive: FxResponsiveStyle(
    xs: FxStyle(width: 100), // Small on phone
    md: FxStyle(width: 500), // Huge on tablet
  ),
  child: myContent,
)
```

---

## 5. Navigation & D.I.

### Navigation
Navigate between screens without needing `context`.
- `Fx.go('/route')`: Go to a new screen.
- `Fx.back()`: Go back to the previous screen.
- `Fx.offAll('/route')`: Close all screens and open a new one (useful for Logout).

### Dependency Injection (D.I.)
Store your services and controllers globally.
- `Fluxy.put(MyController())`: Register your service.
- `Fluxy.find<MyController>()`: Get your service anywhere in the app.

---

## 6. Full Example (One Page)

```dart
class MyPage extends StatelessWidget {
  final name = flux("User");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Fx.column(
        gap: 20,
        children: [
          // A styled card
          Fx.card(
            child: Fx.row(
              gap: 12,
              children: [
                Fx.box().size(50, 50).bg(Colors.blue).radius(25).center()
                  .child(const Icon(Icons.person, color: Colors.white)),
                Fx.column(
                  children: [
                    Fx.text(() => "Hello, ${name.value}").bold().font(18),
                    Fx.text("Welcome back to Fluxy!").color(Colors.grey),
                  ],
                ),
              ],
            ),
          ).pad(16),

          // An interactive button
          Fx.button(
            onTap: () => name.value = "Super User",
            child: "Become Admin",
          ).marginX(16),
        ],
      ).center(),
    );
  }
}
```

---

© 2026 Fluxy Framework. Build fast. Build beautiful.
