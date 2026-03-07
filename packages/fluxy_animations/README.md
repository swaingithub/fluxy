# Fluxy Animations

### High-Performance, Declarative Motion Engine for the Fluxy Framework

Fluxy Animations provides a suite of advanced motion primitives and interactive physics designed to create premium user interfaces with minimal boilerplate.

---

## Features

### 1. Elite Animation Primitives
- **`FxMeshGradient`**: Ultra-modern fluid backgrounds with organic color movement.
- **`FxAnimatedBorder`**: Glowing light trails that follow container perimeters.
- **`FxSpotlight`**: Cinematic reveal mask that follows the pointer or touch input.
- **`FxGooey`**: Professional metaball merging effects for fluid-like transitions.
- **`FxConfetti`**: High-performance particle physics for celebratory interactions.

### 2. Interactive Physics
- **`FxMagnetic`**: Elements that attract to the pointer with spring physics.
- **`FxPerspective`**: 3D tilt and rotation effects based on interaction coordinates.
- **`FxJelly`**: Liquid-style elastic distortion for tactile feedback.

### 3. Liquid FX
- **`FxWave`**: Organic wave-based progress and loading animations.
- **`FxLiquidButton`**: Morphing geometry that simulates splitting liquid droplets.
- **`FxLiquidShimmer`**: High-end shader-based loading states for modern UIs.

---

## Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  fluxy: ^1.2.1
  fluxy_animations: ^1.2.1
```

## Quick Start

### 1. Animated Glow Border
```dart
FxAnimatedBorder(
  color: Fx.primary,
  width: 3,
  borderRadius: 24,
  child: Fx.box(
    style: FxStyle(padding: const EdgeInsets.all(24)),
    child: Fx.text("Premium Glow"),
  ),
)
```

### 2. Interactive Spotlight
```dart
FxSpotlight(
  radius: 120,
  child: Fx.box(
    style: const FxStyle(height: 200, alignment: Alignment.center),
    child: Fx.text("HIDDEN CONTENT"),
  ),
)
```

### 3. Mesh Gradient
```dart
const FxMeshGradient(
  colors: [Colors.blue, Colors.purple, Colors.pink],
  speed: 0.5,
)
```

---

## Architecture

Fluxy Animations is built on the **Fluxy Plugin Engine**. It registers itself automatically and integrates seamlessly with the Fluxy DSL. This module is designed for performance-first rendering using native Flutter painting and shader capabilities.

For full documentation and advanced guides, visit the official site: **[https://getfluxy.vercel.app/](https://getfluxy.vercel.app/)**
