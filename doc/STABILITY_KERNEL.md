# Fluxy Stability Kernel Architecture

The Fluxy Stability Kernel acts as a "Safety OS" on top of the Flutter Engine. It intercepts potential crashes, validates render tree integrity, and ensures state consistency before errors can propagate to the framework level.

## 🏗️ The Stability Stack

```
            Flutter Framework / UI DSL
                     │
    ┌────────────────┴────────────────┐
    │     Fluxy Stability Kernel      │
    │                                 │
    │  ┌───────────────────────────┐  │
    │  │   Viewport Stabilization  │  │ (Detects & Clamps Infinite Scroll)
    │  └─────────────┬─────────────┘  │
    │  ┌─────────────┴─────────────┐  │
    │  │    Render Tree Guard      │  │ (Pre-frame constraint validation)
    │  └─────────────┬─────────────┘  │
    │  ┌─────────────┴─────────────┐  │
    │  │    Constraint Solver      │  │ (Mini-CSS Engine for Auto-repair)
    │  └─────────────┬─────────────┘  │
    │  ┌─────────────┴─────────────┐  │
    │  │  State Consistency Guard  │  │ (Rebuild Loop & Signal Sanitizer)
    │  └─────────────┬─────────────┘  │
    │  ┌─────────────┴─────────────┐  │
    │  │    Async Safety Layer     │  │ (Lifecycle-aware Futures/Streams)
    │  └─────────────┬─────────────┘  │
    │  ┌─────────────┴─────────────┐  │
    │  │    Data Resilience Guard  │  │ (Auto-retry & SWR Data Sync)
    │  └─────────────┬─────────────┘  │
    │  ┌─────────────┴─────────────┐  │
    │  │    Interaction Guard      │  │ (Debounce & Haptic Feedback)
    │  └─────────────┬─────────────┘  │
    └────────────────┬────────────────┘
                     │
              Flutter Engine
```

## 🛡️ Core Components

### 1. Viewport Guard (`FluxyViewportGuard`)
*   **Role:** Prevents the dreaded "Vertical viewport was given unbounded height" error.
*   **Status:** ✅ Implemented.
*   **Action:** Detects if a scrollable is being placed in an unbounded parent. In **Relaxed Mode**, it automatically wraps the child in a `ConstrainedBox` with a safe max dimension (e.g., screen height).

### 2. Render Guard (`FluxyRenderGuard`)
*   **Role:** Pre-flight checks for the Render Tree.
*   **Status:** ✅ Implemented.
*   **Action:** Runs a validation pass before each frame to ensure no `double.infinity` values are leaking into illegal parent-child relationships (like Flex inside Scroll). Uses `FluxyConstraintSolver` to auto-fix minor constraint issues.

### 3. Constraint Solver (`FluxyConstraintSolver`)
*   **Role:** Intelligent layout resolution.
*   **Status:** ✅ Implemented.
*   **Action:** If a layout is mathematically impossible (e.g., min > max), it "solves" it by normalizing dimensions instead of crashing.

### 4. State Consistency Guard (`FluxyStateGuard`)
*   **Role:** Prevents "setState() or markNeedsBuild() called during build".
*   **Status:** ✅ Implemented.
*   **Action:** Detects dirty rebuild loops by tracking rebuild frequency per widget. If a widget rebuilds more than 25 times per second, it triggers a violation.

### 5. Async Safety Layer (`FluxyAsyncGuard`)
*   **Role:** Protects the UI from the "Async Dispose Race".
*   **Status:** ✅ Implemented.
*   **Action:** Provides `fxSafeFuture` and `fxSafeStream`. It automatically tracks the lifecycle of the `BuildContext` and cancels or ignores callbacks if the widget is unmounted.
### 6. Interaction Guard (`FluxyInteractionGuard`)
*   **Role:** Prevents "Double Tap Ghosting".
*   **Status:** ✅ Implemented.
*   **Action:** Debounces user taps automatically. Ensures that rapid repeated clicks don't trigger duplicate API calls or double-navigation crashes.

### 7. Data Resilience Guard (`FluxyDataGuard`)
*   **Role:** Protects the UI from transient network/data failures.
*   **Status:** ✅ Implemented.
*   **Action:** Provides built-in `.retry()` and `.swr()` patterns. Automatically handles transient failures with exponential backoff and background synchronization.

---

## 🚦 Execution Modes

### Strict Mode (Development)
*   **Behavior:** Immediate crashes with "Full-Knowledge" error messages.
*   **Goal:** Tell the developer exactly what went wrong and how to fix it with code snippets.

### Relaxed Mode (Production)
*   **Behavior:** Silent auto-repair.
*   **Goal:** Keep the app running at all costs. If a layout is broken, patch it visually so the user can still interact.
