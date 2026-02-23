import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';
import 'stability_demo.dart';


void main() async {
  await Fluxy.init(); // Setup Hydration & Middleware
  runApp(
    MaterialApp(
    navigatorKey: FluxyRouter.navigatorKey,
    debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      home: const FluxyShowcase(),
    ),
  );
}

class FluxyShowcase extends StatelessWidget {
  const FluxyShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Core State with History & Persistence
    final count = fluxHistory(0, persistKey: 'counter_v1');
    final isDoubleDigit = fluxComputed(() => count.value.abs() >= 10);

    return Fx.scaffold(
      body: Fx.stack(
        children: [
          // Background Layer
          Fx.box().wFull().hFull().background(const Color(0xFF0F172A)),
          
          // Abstract Decorative Orbs (Fluxy Positioned DSL)
          _blurOrb(
            200,
            Colors.indigo.withValues(alpha: 0.3),
          ).positioned(top: -100, right: -50),
          _blurOrb(
            250,
            Colors.purple.withValues(alpha: 0.2),
          ).positioned(bottom: -50, left: -50),
          
          // Content Layer (Fluxy Center DSL)
          Fx.col(
            gap: 40,
            children: [
              // Premium Reactive Header
              Fx.col(
                gap: 8,
                children: [
                  Fx.text(
                    "FLUXY ENGINE",
                  ).fontSize(10).bold().spacing(4).color(Colors.white38),
                  Fx.text(
                    "Reactive Canvas",
                  ).fontSize(32).bold().color(Colors.white),
                ],
              ).animate(fade: 0.0, slide: const Offset(0, -0.2)),

              // The "Pulse" Card: Showcasing Atomic Reactivity
              Fx.box()
                  .w(320)
                  .h(200)
                  .glass(20)
                  .rounded(40)
                  .p(32)
                  .background(Colors.white.withValues(alpha: 0.03))
                  .border(color: Colors.white12, width: 0.5)
                  .shadow
                  .lg
                  .child(
                    Fx.col(
                      justify: MainAxisAlignment.center,
                    children: [
                        Fx(
                          () => Fx.text("${count.value}")
                              .fontSize(80)
                              .bold()
                              .color(Colors.white)
                              .animate(scale: 0.8, spring: Spring.bouncy),
                        ),
                        Fx(
                          () =>
                              Fx.text(
                                    isDoubleDigit.value
                                        ? "MILESTONE REACHED"
                                        : "EVOLVING STATE",
                                  )
                                  .fontSize(12)
                                  .bold()
                                  .color(
                                    isDoubleDigit.value
                                        ? Colors.cyanAccent
                                        : Colors.white24,
                                  ),
                        ),
                    ],
                    ),
                  ),

              // Futuristic Control Hub
              Fx.row(
                justify: MainAxisAlignment.center,
                gap: 12,
                children: [
                  _controlBtn(Icons.remove, () => count.value--),
                  _controlBtn(Icons.add, () => count.value++, isPrimary: true),
                  // Reactive Undo with Disabled State
                  Fx(
                    () => _controlBtn(
                      Icons.undo,
                      count.canUndo ? count.undo : null,
                      color: count.canUndo
                          ? Colors.amberAccent
                          : Colors.white10,
                    ),
                  ),
                ],
              ).animate(fade: 0.0, slide: const Offset(0, 0.2), delay: 0.2),

              Fx.row(
                justify: MainAxisAlignment.center,
                gap: 12,
                children: [
                  Fx.button(
                    "DEPLOY WORKER",
                    onTap: () async {
                      Fx.loader.show(label: "Processing State...");
                      await Future.delayed(const Duration(seconds: 1));
                      Fx.loader.hide();
                      Fx.toast.success("Worker successfully handled the load!");
                    },
                  ).primary.rounded
                  .sizeLg(),
                  
                  Fx.button(
                    "STABILITY LAB",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StabilityDemo()),
                    ),
                  ).ghost
                  .sizeLg()
                  .textColor(Colors.cyanAccent),
                ],
              ).animate(fade: 0.0, delay: 0.4),
            ],
          ).center(), // Fluxy Center Redirection
        ],
      ).wFull().hFull(),
    );
  }

  Widget _blurOrb(double size, Color color) =>
      Fx.box().w(size).h(size).background(color).circle().glass(80);

  Widget _controlBtn(
    IconData icon,
    VoidCallback? onTap, {
    bool isPrimary = false,
    Color? color,
  }) {
    return Fx.box(onTap: onTap)
        .w(64)
        .h(64)
        .background(
          isPrimary
              ? Colors.indigoAccent
              : (color ?? Colors.white.withValues(alpha: 0.05)),
        )
        .rounded(20)
        .child(
          Icon(
            icon,
            color: onTap == null
                ? Colors.white10
                : (isPrimary ? Colors.white : Colors.white70),
          ),
        );
  }
}
