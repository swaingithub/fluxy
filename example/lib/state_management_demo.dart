import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';
import 'dart:async';

// 1. FluxyRepository Example (Mocking a real-world data layer)
class UserPreferencesRepository extends FluxyRepository {
  late final username = flux('Guest', 
    persistKey: userScope('uid_123', 'pref_username')
  );
  
  late final themeMode = flux('light');

  void init() {
    // Example of binding a stream to a flux
    bindStream(
      Stream.periodic(const Duration(seconds: 10), (i) => 'New Alert $i'),
      flux('No alerts'),
    );
  }
}

class StateManagementDemo extends StatefulWidget {
  const StateManagementDemo({super.key});

  @override
  State<StateManagementDemo> createState() => _StateManagementDemoState();
}

// 2. FluxyLocalMixin Example (Automatic Cleanup)
class _StateManagementDemoState extends State<StateManagementDemo> with FluxyLocalMixin {
  
  @override
  void initState() {
    super.initState();
    // 7. Global Middleware Example
    // This will log every single update in the entire app!
    Fluxy.addMiddleware(LoggerMiddleware());
  }

  // Local fluxes that will be disposed when this widget is disposed.
  late final counter = fluxLocal(0);
  
  // 3. fluxHistory Example (Undo/Redo)
  late final textHistory = fluxHistory('Hello Fluxy!');

  // 4. fluxSelector Example (Performance Optimization)
  // This computed only re-runs if the 'counter' value changes, 
  // not when any other global state changes.
  late final isEven = fluxSelector(counter, (val) => val % 2 == 0);

  // 5. fluxWorker Example (Background Computation)
  // This runs in a separate Isolate to keep the UI at 60 FPS
  late final heavyResult = fluxLocalWorker(_expensiveCalculation, 25);

  static int _expensiveCalculation(int n) {
    // This is a CPU-intensive recursive Fibonacci
    if (n <= 1) return n;
    return _expensiveCalculation(n - 1) + _expensiveCalculation(n - 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Fx.appBar(
        title: "Senior State Management",
        centerTitle: true,
      ),
      body: Fx.scroll(
        child: Fx.col(
          gap: 20,
          children: [
            _section("1. Branded Flux & Selector", [
              Fx.text("This widget only rebuilds when even/odd status changes.").muted(),
              Fx.box().h(20),
              Fx.row(
                justify: MainAxisAlignment.center,
                gap: 16,
                children: [
                  Fx.button("-", onTap: () => counter.value--),
                  Fx(() => Fx.text("${counter.value}").font.xxl().bold()),
                  Fx.button("+", onTap: () => counter.value++),
                ],
              ),
              Fx.box().h(20),
              Fx(() => Fx.text(isEven.value ? "Status: EVEN" : "Status: ODD")
                .font.lg().bold().color(isEven.value ? Colors.green : Colors.orange)),
            ]),

            _section("2. Undo/Redo (fluxHistory)", [
              Fx.text("Try typing something or clicking the buttons.").muted(),
              Fx.box().h(20),
              // Wrap the buttons in Fx so they rebuild when canUndo/canRedo changes
              Fx(() {
                final undoEnabled = textHistory.canUndo;
                final redoEnabled = textHistory.canRedo;
                return Fx.row(
                    justify: MainAxisAlignment.center,
                    gap: 12,
                    children: [
                      Fx.button("Undo",
                          onTap: undoEnabled ? () { 
                            debugPrint("Demo: Undo Clicked");
                            textHistory.undo(); 
                          } : null)
                          .applyStyle(undoEnabled ? FxStyle.none : const FxStyle(opacity: 0.3)),
                      Fx.button("Redo",
                          onTap: redoEnabled ? () { 
                             debugPrint("Demo: Redo Clicked");
                             textHistory.redo(); 
                          } : null)
                          .applyStyle(redoEnabled ? FxStyle.none : const FxStyle(opacity: 0.3)),
                    ],
                  );
              }),
              Fx.box().h(20),
              Fx.row(
                justify: MainAxisAlignment.center,
                gap: 10,
                children: [
                  "Fluxy".btn(onTap: () {
                    debugPrint("Demo: Value change to Fluxy");
                    textHistory.value = "Fluxy";
                  }),
                  "Rocks".btn(onTap: () {
                    debugPrint("Demo: Value change to Rocks");
                    textHistory.value = "Rocks";
                  }),
                  "Atomic".btn(onTap: () {
                    debugPrint("Demo: Value change to Atomic");
                    textHistory.value = "Atomic";
                  }),
                ],
              ),
              Fx.box().h(20),
              Fx.box()
                  .bg(Colors.grey[100]!)
                  .p(16)
                  .rounded(12)
                  .wFull()
                  .child(Fx(() => Fx.text("Current: ${textHistory.value}").font.lg().primary())),
              
              // 6. Extra optimization demo: Audit Trail
              Fx.box().h(10),
              Fx(() => Fx.text("Items in History: ${textHistory.canUndo ? 'Available' : 'None'}").font.xs().muted()),
            ]),

            _section("3. Background Worker (fluxWorker)", [
               Fx.text("Simulating a heavy calculation in a worker isolate.").muted(),
               Fx.box().h(20),
               Fx.async(
                 heavyResult,
                 loading: () => Fx.row(gap: 8, children: [
                   const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                   Fx.text("Processing..."),
                 ]),
                 error: (e) => Fx.text("Error: $e").color(Colors.red),
                 data: (val) => Fx.text("Result: $val").font.xl().bold().color(Colors.green),
               ),
               Fx.button("Recalculate", onTap: () => heavyResult.reload()),
            ]),

             _section("4. Global Middleware", [
               Fx.text("A LoggerMiddleware is currently active.").muted(),
               Fx.text("Check your console to see every state update logged in real-time.").font.sm(),
             ]),

             _section("5. State Hydration (Ultra-Scale)", [
               "Hydrate App".btn(onTap: () async {
                 await FluxyPersistence.hydrate();
                 Fx.toast.success("State Hydrated from Disk!");
               }),
               Fx.text("This restores all persistent states instantly.").font.xs().muted(),
             ]),

             _section("6. Local Lifecycle", [
               Fx.text("All fluxes in this screen are using FluxyLocalMixin.").muted(),
               Fx.text("They will be automatically cleared when you go back.").font.sm(),
             ]),

            const SizedBox(height: 40),
            "Finish Demo".primaryBtn(onTap: () => Fx.back()).wFull(),
          ],
        ).p(24),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Fx.box()
      .bg(Colors.white)
      .rounded(24)
      .p(24)
      .shadow.sm
      .children([
        Fx.text(title).font.lg().bold().primary(),
        const SizedBox(height: 16),
        ...children,
      ]);
  }
}

/// A simple middleware that logs all state changes in the console.
class LoggerMiddleware extends FluxyMiddleware {
  @override
  void onUpdate(Flux flux, dynamic oldValue, dynamic newValue) {
    debugPrint(
      "📦 [FLUX UPDATE] ${flux.label ?? flux.id} | $oldValue -> $newValue"
    );
  }
}
