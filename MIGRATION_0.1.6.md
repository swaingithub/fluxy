# Fluxy 0.1.5 → 0.1.6 Migration Guide

Fluxy 0.1.6 is a "Trust & Stability" release focused on hardening the internal architecture while keeping the outward-facing DSL consistent. While most changes are internal, there are a few key refinements to be aware of.

## 🚀 Key Architectural Shift: Attribute Accumulation

Previously, Fluxy used a "Widget Wrapping" approach where每调用一次 modifier (like `.padding()`) would wrap the widget in another physical widget (like `Padding`).

In **0.1.6**, as suggested by modern UI framework best practices, Fluxy has transitioned to an **Attribute Accumulation** model. Modifiers now update a local `FxStyle` object within the source widget.

### Why this matters:
1. **Performance**: Your widget tree is now significantly flatter. Chaining 10 modifiers results in exactly **one** styled widget being rendered instead of 10 nested wrappers.
2. **Correctness**: Fixed the "Incorrect use of ParentDataWidget" error. Modifiers now correctly preserve `Expanded`, `Flexible`, and `Positioned` data.
3. **Consistency**: All core widgets now behave identically when styled.

---

## 🛠 Breaking Changes & Deprecations

### 1. Style Object Visibility
Many public fields in `FxStyle` have been made private (prefixed with `_`) to avoid naming collisions with DSL methods. 
* **If you were accessing raw fields**: Use the public getters instead.
* **Old**: `style.padding`
* **New**: `style.padding` (The getter name remains the same, but the internal field is now `_padding`).

### 2. Manual Widget Wrapping with `.bg()`, `.w()`, etc.
Previously, if you called `.bg()` on a non-Fluxy widget (like `Icon`), it would wrap it in a `Box`. This still happens, but if you call it on an `FxWidget` (like `Fx.text()`), it no longer wraps. It merges the style into the `Fx.text()` component.
* **Action**: If you were relying on finding a `Box` parent via `find.byType(Box)` in tests, you may need to update your selectors to the specific widget type.

### 3. Factory Method Signatures
The `Fx` factory methods have been updated to support the accumulation pattern natively.
* **Old**: `Fx.avatar(image: "...")`
* **New**: `Fx.avatar(image: "...", style: FxStyle(...), className: "...", responsive: ...)`

---

## ✅ Best Practices for 0.1.6

### Use ClassNames for Shared Styles
With the new engine, `className` is resolved **after** the inline `.style()` but **before** modifiers. This means modifiers will always override class-based styles, which is the expected behavior.

### Modifier Order No Longer Matters (Mostly)
Because styles are now accumulated into a single object before rendering, the order of modifiers like `.padding(10).bg(Colors.blue)` vs `.bg(Colors.blue).padding(10)` will result in the exact same UI. 

*Note: Position-dependent modifiers like `.offset()` still behave as transformations.*

---

## 🆘 Troubleshooting

**"My ParentData is still breaking!"**
Ensure you are using the latest `Fx` factories. If you are wrapping a native Flutter widget in `Expanded`, make sure the `Expanded` is the **outermost** element in your DSL chain if possible, or use the `.expand()` modifier directly.

**"Shadows look different!"**
We fixed a recursion bug where multiple shadows were stacking incorrectly. Your UI might look "cleaner" now. Adjust your shadow blur values if necessary.
