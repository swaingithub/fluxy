## 0.0.5

* **Production Protection**: Added global error boundaries to `FluxyApp` to prevent crashes in production.
* **CLI Power**: Introduced `fluxy` CLI for project initialization and module generation (Next.js style).
* **Enhanced DevTools**: Added Signal Graph Inspector and Timeline Logs for visual debugging.
* **Refined Inputs**: Rewrote `FxTextField` for better memory management and two-way binding stability.
* **Stability Audit**: Resolved several potential null-safety issues and navigation edge cases.

## 0.0.4

* **Motion Engine**: Implemented a fluent physics-based animation DSL (`.animate().spring()`).
* **Staggered Animations**: Added `Fx.stagger()` for easy sequential entrance effects.
* **Tab Navigation Stacks**: Introduced `FxTabScaffold` and `FxNestedStack` for independent navigation histories.
* **Router 2.0**: Added custom page transitions (fade, slide, zoom) and route grouping.
* **Fluent Extensions**: Added `.obs` support for Lists, Maps, and primitive types.

## 0.0.3

* **High-Fidelity Reactive Engine**: Implemented a fine-grained reactivity graph with atomic micro-rebuilds and transparent dependency tracking.
* **Optimized Scheduling**: Added batched state updates via microtasks to prevent redundant widget builds and ensure zero frame drops.
* **Computed & Effects**: Full support for `computed()` signals and `effect()` listeners for automated state synchronization.
* **Fintech Design Hub**: Replaced the initial demo with a premium, high-fidelity Fintech UI showcase including ₹ (Rupee) integration.
* **UI DSL Refinements**: Optimized fluent modifiers and resolved RenderFlex overflow issues for better responsiveness.
* **Professional Documentation**: Complete overhaul of project documentation with focus on developer adoption and architectural clarity.

## 0.0.2

* Refined the Signal API for better developer experience.
* Improved the Style Resolver for more consistent Tailwind-like utility application.

## 0.0.1

* Initial release of Fluxy Framework.
* Core reactive engine with basic signals.
* Initial Fx DSL implementation.
