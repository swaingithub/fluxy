## 0.1.0

* **Dependency Modernization**: Upgraded all core dependencies to their latest stable versions, including a major upgrade to `flutter_secure_storage` (v10.0.0).
* **Code Quality Audit**: Performed a comprehensive linting sweep of the `FluxyDebug` module, ensuring strict adherence to `curly_braces_in_flow_control_structures` and other best practices.
* **Refined Tooling**: Optimized service extension registration in DevTools for better reliability.

## 0.0.9

* **Maintenance & Polish**: Conducted a full framework-wide analysis audit. Resolved all remaining lint warnings and strictly addressed Flutter 3.x deprecations.
* **Code Optimization**: Removed redundant imports and unused variables in the SDUI and Signal engines.
* **Analysis Integrity**: Achieved "No issues found" status for the main package and devtools.

## 0.0.8

* **Framework Stability**: Resolved a critical CLI execution failure on Windows systems by enabling `runInShell: true` for all process calls.
* **Internal CLI Sync**: Synchronized internal CLI versioning with the main package to ensure `fluxy doctor` accuracy.

## 0.0.7

* **Professional Documentation**: Complete rewrite of `README.md` and `DOCUMENTATION.md` for an engineering-first audience.
* **Lightweight Engine**: Significantly reduced the final app bundle footprint by removing the `http` package dependency.
* **Native Networking**: Rewrote the OTA engine to use built-in `dart:io` `HttpClient` for optimized, zero-dependency networking.
* **SDUI Optimization**: Implemented a "Fast Path" for string interpolation, bypassing Regex engines for static content.
* **Linting Audit**: Resolved several hidden lint warnings across the core rendering and reactive logic.

## 0.0.6

* **Fluxy Cloud**: Introduced `fluxy cloud` to automatically scaffold GitHub Actions for free Android/iOS builds and deployment.
* **Fluxy Play**: Launched the companion preview app (equivalent to Expo Go) for instant manifest-based development.
* **OTA Engine**: Implemented the Server-Driven UI (SDUI) renderer and OTA manifest management system.
* **Signal Registry**: Added a global signal registry with `WeakReference` support to enable advanced devtools and prevent memory leaks.

## 0.0.5

* **Production Protection**: Added global error boundaries to `FluxyApp` to prevent crashes in production.
* **CLI Power**: Introduced `fluxy` CLI for project initialization and module generation.
* **Enhanced DevTools**: Added Signal Graph Inspector and Timeline Logs for visual debugging.
* **Refined Inputs**: Rewrote input system for better memory management and two-way binding stability.

## 0.0.4

* **Motion Engine**: Implemented a fluent physics-based animation DSL (`.animate().spring()`).
* **Staggered Animations**: Added sequential entrance effects support.
* **Routing 2.0**: Added custom page transitions and nested navigation stacks.

## 0.0.3

* **High-Fidelity Reactive Engine**: Fine-grained reactivity graph with atomic micro-rebuilds.
* **Batched Updates**: Prevents redundant widget builds via microtask scheduling.
* **Design Showcase**: Replaced initial demo with a premium Fintech UI showcase.

## 0.0.2

* Refined the Signal API for better developer experience.
* Improved the Style Resolver for consistent utility application.

## 0.0.1

* Initial release of Fluxy Framework.
* Core reactive engine and fluent UI DSL implementation.
