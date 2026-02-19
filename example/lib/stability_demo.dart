import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';

class StabilityDemo extends StatelessWidget {
  const StabilityDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🛡️ Fluxy Stability Kernel Demo"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          Fx.text("Use Debug FAB").font.xs().whiteText().px(12).center(),
        ],
      ),
      body: Fx.scroll(
        child: Fx.col(
          gap: 24,
          style: const FxStyle(padding: EdgeInsets.all(20)),
          children: [
            _header("Stability Control Center", "These scenarios would normally crash Flutter. Fluxy auto-repairs them in real-time."),
            
            _section(
              title: "1. Viewport Guard (Unbounded Height)",
              description: "Normally: 'Vertical viewport was given unbounded height'.\nFluxy: Automatically detects the missing constraint and clamps it to a safe viewport height.",
              child: Fx.box(
                style: const FxStyle(
                  backgroundColor: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  border: Border.fromBorderSide(BorderSide(color: Colors.blueGrey)),
                  padding: EdgeInsets.all(12),
                ),
                child: Fx.list(
                  shrinkWrap: false, // Fluxy will auto-correct this!
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5,
                  itemBuilder: (context, i) => ListTile(
                    leading: const Icon(Icons.check_circle, color: Colors.green),
                    title: Text("Auto-stabilized Item ${i + 1}"),
                  ),
                ),
              ),
            ),

            _section(
              title: "2. Render Guard (Dual Infinity)",
              description: "Normally: 'RenderFlex children have non-zero flex but incoming height constraints are unbounded'.\nFluxy: Solves the constraint conflict by normalizing the flex values.",
              child: Fx.box(
                style: const FxStyle(
                  height: 150,
                  backgroundColor: Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: Fx.col(
                  children: [
                    Fx.text("Fixed Header").bold(),
                    Fx.box(
                      style: const FxStyle(backgroundColor: Colors.blue),
                      child: Fx.text("Auto-fixed Expanded Content").whiteText().center(),
                    ).expand(), // Fx.expand() uses FxSafeExpansion which detects the scroll parent
                  ],
                ),
              ),
            ),

            _section(
              title: "3. Interaction Guard (Ghosting)",
              description: "Tapping 'Submit' rapidly would normally trigger the API 5 times.\nFluxy: Debounces the interaction automatically.",
              child: Fx.row(
                gap: 12,
                children: [
                  Fx.button("Safe Submit")
                    .primary
                    .onTapSafe(() {
                      _showSnack(context, "API Called once! (Spam prevented)");
                    }),
                  Fx.text("Spam this button fast!").font.xs().muted(),
                ],
              ),
            ),

            _section(
              title: "4. Data Resilience (Retry Logic)",
              description: "This simulates a failing API (Network Error).\nFluxy: Automatically retries with exponential backoff.",
              child: Fx.button(
                "Sync Failing Data",
                onTap: () async {
                  _showSnack(context, "Starting sync with retries...");
                  try {
                    await Fx.retry(() async {
                      debugPrint("Attempting failing call...");
                      throw Exception("Transient Network Failure");
                    }, retries: 3, label: "Demo Sync");
                  } catch (e) {
                    _showSnack(context, "Failed after 3 retries (Expected)");
                  }
                },
              ).outline,
            ),

            _section(
              title: "5. Animation Presets & Motion",
              description: "High-level presets that just work.",
              child: Fx.row(
                gap: 12,
                children: [
                  Fx.box().w(60).h(60).background(Colors.indigo).rounded(8)
                    .fadeIn(delay: 0.5)
                    .slideUp(offset: 40),
                  Fx.box().w(60).h(60).background(Colors.blue).rounded(8)
                    .zoomIn(delay: 0.8),
                  Fx.box().w(60).h(60).background(Colors.cyan).rounded(8)
                    .animate(rotate: 1.0, delay: 1.0),
                ],
              ),
            ),

            _section(
              title: "6. Device Guard (Safe Area)",
              description: "Normally: Content gets cut off by notches/home indicators.\nFluxy: The .safe() modifier automatically insets content for any device hardware.",
              child: Fx.box(
                style: const FxStyle(
                  backgroundColor: Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  padding: EdgeInsets.symmetric(vertical: 8),
                ),
                child: Fx.row(
                  justify: MainAxisAlignment.center,
                  children: [
                    Fx.icon(Icons.edgesensor_high, color: Colors.blueAccent),
                    Fx.gap(8),
                    Fx.text("Hardware Aware Layout").bold(),
                  ],
                ),
              ).safe(), // Demonstrating the safe area modifier
            ),

            const SizedBox(height: 40),
            Fx.text("Check the Stability Console for 'Saving' metrics!").center().bold().color(Colors.blue),
            Fx.button(
              "Print Summary to Console",
              onTap: () {
                Fluxy.printStabilitySummary();
              },
            ).ghost
              .center(),
          ],
        ),
      ),
    );
  }

  Widget _header(String title, String subtitle) {
    return Fx.col(
      items: CrossAxisAlignment.start,
      children: [
        Fx.text(title).font.h1(),
        Fx.text(subtitle).font.sm().muted().mt(4),
        Divider().mt(12),
      ],
    );
  }

  Widget _section({required String title, required String description, required Widget child}) {
    return Fx.col(
      items: CrossAxisAlignment.stretch,
      gap: 12,
      children: [
        Fx.col(
          items: CrossAxisAlignment.start,
          children: [
            Fx.text(title).bold().fontSize(16),
            Fx.text(description).font.xs().muted().mt(4),
          ],
        ),
        child,
      ],
    );
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 1)),
    );
  }
}
