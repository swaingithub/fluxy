# Implementation Plan - Fluxy v0.1.6+ (Stability & Architecture Shift)

This plan outlines the architectural improvements and bug fixes for Fluxy v0.1.6, focusing on "Attribute Accumulation" and resolving core DSL issues.

## Phase 1: Stability & Core Architecture (v0.1.6)

### 1. Refactor `FxStyle` (Naming Collisions)
- **Goal**: Prevent name collisions between `FxStyle` fields and DSL extension methods (e.g., `padding`, `margin`).
- **Action**: Rename colliding fields to private (e.g., `_padding`, `_margin`, `_borderRadius`) and expose them via getters.
- **File**: `lib/src/styles/style.dart`

### 2. Introduce `FxWidget` Base Class
- **Goal**: Enable "Attribute Accumulation" instead of recursive widget wrapping.
- **Action**: 
    - Create `FxWidget` as an abstract class or interface that all Fluxy widgets (`Box`, `FlexBox`, `TextBox`, etc.) implement.
    - `FxWidget` will hold `style`, `responsive`, `id`, `className`, and `child/children`.
    - `FxWidget` will provide a `copyWithStyle(FxStyle additionalStyle)` method.
- **File**: `lib/src/widgets/fx_widget.dart` (New)

### 3. Refactor DSL Modifiers (Accumulation Logic)
- **Goal**: Stop the "Widget Wrapping Explosion".
- **Action**:
    - Update `FluxyWidgetExtension` in `lib/src/dsl/modifiers.dart`.
    - If `this` is an `FxWidget`, call `copyWithStyle()`.
    - If `this` is a standard `Widget`, wrap it in a `Box` first, then subsequent calls will accumulate.
    - Fix the `shadow()` recursion by making it mutate style directly.
- **File**: `lib/src/dsl/modifiers.dart`

### 4. ParentData Propagation Fix
- **Goal**: Prevent loss of `Expanded`, `Positioned`, etc., when applying modifiers.
- **Action**:
    - Build "smart wrapping" logic that detects if the child needs to be wrapped in `Expanded` or `Positioned` based on the style accumulated.
    - Ensure `Flexible`, `Expanded`, and `Positioned` are applied at the very top of the built tree in each Fluxy widget's `build` method.
- **File**: `lib/src/widgets/box.dart` (and others)

### 5. DSL Consistency (Grid, etc.)
- **Goal**: Stable and predictable API.
- **Action**:
    - Support both `.cols(2)` and `columns: 2` in `Fx.grid`.
- **File**: `lib/src/dsl/fx.dart`

## Phase 2: Power DSL (v0.2)

### 1. Integrated Form DSL
- **Goal**: `form.input('email').required()`
- **Action**:
    - Implement `FxFormController` to manage state and validation.
    - Add `input` method to controller for easy field binding.

### 2. Unified Animation System
- **Goal**: `.stagger(100.ms)`, `.animate.fade.slide`
- **Action**:
    - Refactor `FxMotion` to be chainable and integrated into the style accumulation.

### 3. Fx.fetch & Fx.dialog enhancements
- **Goal**: Higher-level framework features.
- **Action**:
    - Expand `Fx.fetch` with better error handling and caching.
    - Enhance `Fx.dialog` with more layout options.

---

## Technical Details: Attribute Accumulation

Instead of:
`Box(style: Padding, child: Box(style: Bg, child: ...))`

We want:
`Box(style: FxStyle(padding: ..., bg: ...), child: ...)`

**Current Bug**:
```dart
Widget shadow() => FxShadowProxy(this); // Returns a proxy that might wrap again
```

**Proposed Fix**:
```dart
Widget shadow([FxShadow value = FxShadow.sm]) {
  return _applyGenericStyle(FxStyle(shadows: value));
}
```
If `_applyGenericStyle` detects an `FxWidget`, it just merges the style.
