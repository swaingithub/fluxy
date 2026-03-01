# fluxy_logger

[PLATFORM] Official Industrial Logging module for the Fluxy framework. Standardizes semantic audit trails for production monitoring and debugging.

## [INSTALL] Installation

### Via CLI (Recommended)
```bash
fluxy module add logger
```

### Manual pubspec.yaml
```yaml
dependencies:
  fluxy_logger: ^1.1.0
```

---

## [USAGE] Implementation Paradigms

Access the logging engine via the unified `Fx.platform.logger` gateway.

### Semantic Auditing

```dart
// Log a system operation
Fx.platform.logger.sys('Initializing kernel sequence', tag: 'KERNEL');

// Log a data/state operation
Fx.platform.logger.data('User profile hydration complete', tag: 'DB');

// Log a critical failure
Fx.platform.logger.fatal('Database connection lost', error: e, stack: s);
```

### Log Levels
Use the `level` signal to filter output during session execution.

```dart
Fx.platform.logger.level.value = LogLevel.warn;
```

---

## [API] Reference

### Properties (How to Add and Use)
Fluxy Logger uses high-performance signals to track the audit trail.

| Property | Type | Instruction |
| :--- | :--- | :--- |
| `logs` | `Signal<List<String>>` | **Use**: `Fx.platform.logger.logs.value`. Contains the last 1000 formatted strings. |
| `level` | `Signal<LogLevel>` | **Use**: `Fx.platform.logger.level.value`. Sets the threshold for console output. |

---

## [RULES] Industrial Standard vs. Outdated Style

| Feature | [WRONG] The Outdated Way | [RIGHT] The Fluxy Standard |
| :--- | :--- | :--- |
| **Plugin Access** | `print()` or `debugPrint()` | `Fx.platform.logger.sys()` |
| **Audit Trail** | Manually saving logs to files | Reactive `logs` signal for debug overlays |
| **Formatting** | Random string output | Standard `[TIME] [TYPE] [TAG] MSG` format |

---

## [PITFALLS] Common Pitfalls & Fixes

### 1. "Logs are missing in release mode"
*   **The Cause**: Fluxy Logger defaults to `kDebugMode` for console output to protect security.
*   **The Fix**: To ship logs to a remote server, listen to the `logs` signal: `Fx.platform.logger.logs.listen((list) => ship(list.last))`.

## License

This package is licensed under the MIT License. See the LICENSE file for details.
