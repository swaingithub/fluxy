# Fluxy: The Complete Developer Guide

Fluxy is a full-stack Flutter framework designed to make app development faster, cleaner, and more scalable. It unifies state management, UI styling, routing, and cloud tooling into a single engine.

---

## 🚀 1. Getting Started

### Installation
Activate the global Fluxy CLI:
```bash
dart pub global activate fluxy
```

### Creating a New Project
Run the `init` command to scaffold a production-ready app:
```bash
fluxy init my_awesome_app
cd my_awesome_app
fluxy run
```

This creates a project with:
- ✅ Pre-configured `pubspec.yaml`
- ✅ Optimized folder structure
- ✅ Sample counter app using Signals

---

## 🛠️ 2. Core Features

### ⚡ Reactive State (Signals)
Forget `setState`. Fluxy uses fine-grained reactivity.
```dart
final count = flux(0); // Create signal

// UI updates automatically
Fx.text(() => "Count: ${count.value}");

// Update value
count.value++;
```

### 🎨 Fluent UI (SDUI)
Build beautiful interfaces with chainable modifiers.
```dart
Fx.box()
  .size(100, 100)
  .bg(Colors.blue)
  .radius(16)
  .shadow()
  .center();
```

### 🛣️ Routing
Simple, declarative navigation.
```dart
// Define routes
routes: [
  FxRoute(path: '/', builder: (_, __) => Home()),
  FxRoute(path: '/details', builder: (_, args) => Details(id: args['id'])),
]

// Navigate
FluxyRouter.to('/details', arguments: {'id': 123});
```

---

## ☁️ 3. Cloud & OTA Tools

### 📦 Fluxy Cloud Build
Build your app in the cloud for free using GitHub Actions.
```bash
# Setup Android Build Workflow
fluxy cloud build android

# Setup iOS Build Workflow
fluxy cloud build ios
```
*Push to `main` to trigger a build!*

### 🔄 Over-The-Air (OTA) Updates
Push UI updates instantly without App Store review.
1. Host your app's JSON manifest (e.g., `https://api.myapp.com/manifest.json`).
2. Update the app remotely:
   ```dart
   Fluxy.update('https://api.myapp.com/manifest.json');
   ```
3. The app downloads the new UI and renders it instantly.

---

## 📱 4. Fluxy Play (Preview App)
Preview your app on a real device without compiling.
1. Run `fluxy_play` (the companion app).
2. Enter your manifest URL.
3. See changes live!

---

## 🐞 5. Debugging Tools

### In-App Inspector
Visualize your reactive graph and signal state.
```dart
void main() {
  FluxyDebug.init(); // Enable debugging
  runApp(Fluxy.debug(child: MyApp()));
}
```
**Features:**
- 🟢 **Live Signal Values**
- 🟣 **Computed Dependencies**
- ⏱️ **Update Timeline**
- 📉 **Performance Metrics**

### DevTools Extensions
Fluxy integrates with standard Dart DevTools.
- **Inspect Signals**: See all active signals in the "Fluxy" tab.
- **Modify State**: Change values at runtime to test edge cases.

---

## 📚 6. Architecture & Best Practices

### Logic Separation
Keep logic in `Controllers` or global signals. UI should be purely declarative.

### Reusable Components
Create custom widgets using `Fx.box`, `Fx.text`, etc., to maintain consistency.

### Performance
Fluxy automatically optimizes rebuilds. Only widgets reading a changed signal will rebuild. **Do not unnecessary convert Signal<T> to ValueNotifier.** Let Fluxy handle it.

---

**Build faster. Scale confidently.**
