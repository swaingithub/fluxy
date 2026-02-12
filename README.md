# Fluxy — The Full-Stack Flutter Framework

**The "Expo" for Flutter. One Engine. Infinite Possibilities.**

Fluxy is a complete development platform that unifies **reactive state**, **declarative UI**, **cloud builds**, **OTA updates**, and **developer tooling** into a single cohesive engine.

[![Pub Version](https://img.shields.io/pub/v/fluxy?color=blue)](https://pub.dev/packages/fluxy)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## 🚀 Why Fluxy?

Fluxy dramatically speeds up Flutter development by providing the missing pieces of the ecosystem right out of the box:

| Feature | Standard Flutter | Fluxy |
| :--- | :--- | :--- |
| **Development** | Native compilation required | **Fluxy Play (Instant Preview)** |
| **State** | Provider / BLoC / Riverpod | **Signals (Zero Boilerplate)** |
| **UI Syntax** | Nested Trees | **Fluent Chainable DSL** |
| **CI/CD** | Manual / Codemagic (Paid) | **Fluxy Cloud (Free GitHub Actions)** |
| **Updates** | App Store Review | **OTA Server-Driven Updates** |
| **Debugging** | DevTools | **In-App Signal Inspector** |

---

## 🛠️ The Tookit

### 1. Fluxy CLI
Scaffold, build, and deploy with a single command.

```bash
fluxy init my_app
fluxy run
fluxy cloud build android  # Free cloud build via GitHub Actions
```

### 2. Reactive UI & State
Write less code. Do more.

```dart
final count = flux(0);

Fx.column(
  Fx.text(() => "Count: ${count.value}").font(32).bold(),
  Fx.button("Increment", onTap: () => count.value++).bg(Colors.blue).pad(16)
).center();
```

### 3. Fluxy Cloud & OTA
Push updates instantly without waiting for App Store review using our Server-Driven UI engine.

```dart
// Load entire screens from the cloud
FxRemoteView(path: 'https://api.myapp.com/home.json');

// Trigger update
Fluxy.update('https://api.myapp.com/manifest.json');
```

### 4. Fluxy Play
Preview your apps on real devices without compiling native code. Just scan a QR code or enter a URL.

---

## 📦 Installation

```yaml
dependencies:
  fluxy: ^0.8.0
```

## ⚡ Quick Start

### Create a new project
```bash
# Install CLI
dart pub global activate fluxy

# Create App
fluxy init super_app
cd super_app
fluxy run
```

### Debugging
Enable the powerful in-app inspector:
```dart
void main() {
  FluxyDebug.init();
  runApp(Fluxy.debug(child: MyApp()));
}
```

---

## 🗺️ Roadmap Status

*   ✅ **Signals & State** (Completed)
*   ✅ **Fluent DSL** (Completed)
*   ✅ **Motion Engine** (Completed)
*   ✅ **CLI Tooling** (Completed)
*   ✅ **OTA Updates** (Completed)
*   ✅ **DevTools** (Completed)
*   ✅ **Cloud Builds** (Completed)
*   ✅ **Playground App** (Completed)

---

## Community & Support

*   **Documentation**: [Read the Docs](https://fluxy-doc.vercel.app/)
*   **GitHub**: [swaingithub/fluxy](https://github.com/swaingithub/fluxy)

---

**Build faster. Write cleaner. Scale confidently.**
