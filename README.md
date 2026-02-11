# Fluxy 🌊

A production-grade, declarative UI DSL for Flutter that brings a web-style layout experience with native performance.

## 🏗 Architecture

Fluxy is built on a layered architecture:

1.  **DSL Layer**: A fluent, declarative API for building widgets.
2.  **Style System**: A CSS-inspired property system (`Style` class).
3.  **Layout Engine**: Modular engine that resolves CSS constraints into Flutter layout.
4.  **Responsive Layer**: Built-in breakpoint system for adaptive UIs.

## 🚀 Getting Started

### Installation

Add `fluxy` to your `pubspec.yaml`:

```yaml
dependencies:
  fluxy:
    path: ./ # during development
```

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Box(
          style: Style(
            backgroundColor: Colors.grey[200],
            padding: const EdgeInsets.all(20),
            justifyContent: MainAxisAlignment.center,
            alignItems: CrossAxisAlignment.center,
          ),
          children: [
            const Text("Welcome to Fluxy").styled(const Style(
              width: 200,
              backgroundColor: Colors.blue,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            )),
            Box(
              style: const Style(gap: 10),
              children: [
                const Text("Subheading"),
                const Text("Description goes here..."),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

## 🔧 Core Components

- **Box**: The fundamental building block (like `<div>`).
- **Style**: Define layout, spacing, and appearance.
- **FluxyResponsive**: Handle breakpoints with ease.

## 🧬 Principles

- **Maintainability**: Clear separation between styling and structure.
- **Performance**: Minimizes layout passes by leveraging Flutter's optimization.
- **Extensibility**: Easily add new layout rules to the engine.
