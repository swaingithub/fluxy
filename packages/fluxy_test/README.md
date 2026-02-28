# fluxy_test

[PLATFORM] Official Testing Utilities module for the Fluxy framework. Provides high-integrity abstractions for industrial Flutter testing.

## [INSTALL] Installation

### Via CLI (Recommended)
```bash
fluxy module add test
```

### Manual pubspec.yaml
```yaml
dev_dependencies:
  fluxy_test: ^1.0.0
```

---

## [USAGE] Implementation Paradigms

Access the testing suite via the unified `FluxyTest` gateway.

### High-Fidelity Widget Testing

```dart
void main() {
  testWidgets('Fluxy App Boot Test', (tester) async {
    // 1. Initialize Minimal Framework
    await Fluxy.init();

    // 2. Build App
    await tester.pumpWidget(
      const FluxyApp(
        title: 'Test App',
        routes: [],
      ),
    );

    // 3. Verify Boot
    expect(find.byType(FluxyApp), findsOneWidget);
  });
}
```

---

## [RULES] Industrial Standard vs. Outdated Style

| Feature | [WRONG] The Outdated Way | [RIGHT] The Fluxy Standard |
| :--- | :--- | :--- |
| **Setup** | Manual DI mock setup | `Fluxy.init()` in `testWidgets` |
| **Logic** | Redundant pump/settle calls | Automatic reactive observation |
| **Cleanup** | Manually clearing signals | Auto-reset during Fluxy boot |

---

## [PITFALLS] Common Pitfalls & Fixes

### 1. "Test fails with Overflow"
*   **The Cause**: Running tests with small default viewports.
*   **The Fix**: Use `tester.view.physicalSize` to set an industrial resolution (e.g., 1080x1920) for the test run.

## License

This package is licensed under the MIT License. See the LICENSE file for details.
