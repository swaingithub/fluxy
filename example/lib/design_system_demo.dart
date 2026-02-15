import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';

class DesignSystemDemo extends StatelessWidget {
  const DesignSystemDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Fx.scaffold(
      appBar: Fx.appBar(title: "Fluxy Design System"),
      body: Fx.scroll(
        child: Fx.col(
          gap: 24,
          style: FxStyle(padding: EdgeInsets.all(Fx.space.lg)),
          children: [
            // Typography Section
            section("Typography Tokens", [
              Fx.text("This is H1 Heading").h1(),
              Fx.text("This is H2 Heading").h2(),
              Fx.text("This is H3 Heading").h3(),
              Fx.text("This is a standard body text").body(),
              Fx.text("This is a caption or muted text").caption(),
            ]),

            // Themed Colors Section
            section("Themed Color Shortcuts", [
              Fx.row(gap: 8, children: [
                colorBox("Primary", FxTokens.colors.primary),
                colorBox("Secondary", FxTokens.colors.secondary),
                colorBox("Success", FxTokens.colors.success),
                colorBox("Error", FxTokens.colors.error),
              ]),
              Fx.gap(12),
              Fx.text("Primary Text").primary().bold(),
              Fx.text("Secondary Text").secondary(),
              Fx.text("Error Text").error(),
              Fx.text("Success Text").success(),
            ]),

            // Responsive Visibility Section
            section("Responsive Visibility", [
              Fx.text("This text hides on small screens").hideSm().primary(),
              Fx.text("This text hides on medium+ screens").hideMd().secondary(),
              Fx.text("Visible on all screens").success(),
            ]),

            // ==========================================
            // NEW: BUTTON DSL 2.0 & CENTERING FIXES
            // ==========================================
            section("Button DSL 2.0 (New!)", [
              Fx.text("1. String Extensions (Zero Boilerplate)").font.sm().bold().mb(8),
              Fx.row(gap: 12, children: [
                "Primary".primaryBtn(),
                "Danger".dangerBtn(),
                "Ghost".ghostBtn(),
              ]),
              
              Fx.gap(20),
              Fx.text("2. Full-Width Centering Fix").font.sm().bold().mb(8),
              "Centered Full-Width Button".successBtn().wFull(),
              
              Fx.gap(20),
              Fx.text("3. Raw Interaction Layer (Fx.btn)").font.sm().bold().mb(8),
              Fx.btn(
                onTap: () => Fx.toast("Raw button clicked"),
                child: Fx.box()
                  .bg(Colors.amber.shade100)
                  .p(12)
                  .rounded(8)
                  .border(color: Colors.amber)
                  .children([
                    Fx.icon(Icons.auto_awesome, color: Colors.amber.shade800),
                    Fx.gap(8),
                    Fx.text("Completely Custom UI").color(Colors.amber.shade900).bold(),
                  ]),
              ),

              Fx.gap(20),
              Fx.text("4. Widget Buttonizers").font.sm().bold().mb(8),
              Fx.row(gap: 12, children: [
                Fx.icon(Icons.favorite, color: Colors.red).secondaryBtn(),
                Fx.avatar().primaryBtn(),
              ]),
            ]),

            // ==========================================
            // NEW: ADVANCED IMAGE API
            // ==========================================
            section("Advanced Image API", [
              Fx.text("1. Smart Source & Shimmer").font.sm().bold().mb(8),
              Fx.row(gap: 12, children: [
                // Network image with shimmer and cover
                Fx.image("https://picsum.photos/seed/fluxy/400/400")
                    .w(120).h(120)
                    .cover()
                    .rounded(16)
                    .imgLoading(Fx.loader.shimmer()),
                
                // Circle cropped network image
                Fx.image("https://picsum.photos/seed/dev/400/400")
                    .w(120).h(120)
                    .circle()
                    .border(color: FxTokens.colors.primary, width: 2)
                    .imgLoading(Fx.loader.shimmer()),
              ]),

              Fx.gap(20),
              Fx.text("2. Filters (Blur & Grayscale)").font.sm().bold().mb(8),
              Fx.row(gap: 12, children: [
                Fx.image("https://picsum.photos/seed/blur/400/400")
                    .w(120).h(120)
                    .cover()
                    .rounded(16)
                    .blur(3),
                
                Fx.image("https://picsum.photos/seed/gray/400/400")
                    .w(120).h(120)
                    .cover()
                    .rounded(16)
                    .grayscale(),
              ]),
            ]),

            // ==========================================
            // NEW: VISUAL EFFECTS & MOTION
            // ==========================================
            section("Visual Effects & Advanced Motion", [
              Fx.text("1. Advanced Borders & Gradients").font.sm().bold().mb(8),
              Fx.box()
                .wFull().h(80)
                .gradient(LinearGradient(colors: [Colors.blue, Colors.purple]))
                .rounded(12)
                .border(color: Colors.white.withOpacity(0.5), width: 2)
                .center()
                .child(Fx.text("Glassy Gradient").color(Colors.white).bold()),

              Fx.gap(20),
              Fx.text("2. Repeat & Reverse Motion").font.sm().bold().mb(8),
              Fx.row(gap: 20, children: [
                // Pulse effect
                Fx.box()
                    .w(60).h(60)
                    .bg(FxTokens.colors.error)
                    .circle()
                    .animate(
                      scale: 0.8,
                      duration: 800.ms,
                      repeat: true,
                      reverse: true,
                    ),
                
                Fx.text("Pulse Animation").muted(),
              ]),

              Fx.gap(20),
              Fx.text("3. High-Performance Scale & Rotate").font.sm().bold().mb(8),
              Fx.row(gap: 12, children: [
                Fx.box()
                  .w(100).h(60)
                  .bg(FxTokens.colors.primary)
                  .rounded(8)
                  .center()
                  .child(Fx.text("Hover Me").font.xs().whiteText())
                  .onHover((s) => s.scale(1.2).rotate(0.1))
                  .transition(300.ms),
                
                Fx.box()
                  .w(100).h(60)
                  .bg(FxTokens.colors.secondary)
                  .rounded(8)
                  .center()
                  .child(Fx.text("Hover Me").font.xs().whiteText())
                  .onHover((s) => s.rotate(-0.2).scale(0.9))
                  .transition(300.ms),
              ]),
            ]),

            // Chained Logic
            section("Chained Themed Styles", [
              Fx.box(
                child: Fx.text("Styled Box").color(Colors.white).bold(),
              )
              .primary() // Themed background
              .p(16)
              .rounded(12)
              .shadow.md
              .onHover((s) => s.scale(1.1)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget section(String title, List<Widget> children) {
    return Fx.col(
      items: CrossAxisAlignment.start,
      gap: 12,
      children: [
        Fx.text(title).h3().muted(),
        Fx.box(
          style: FxStyle(
            padding: const EdgeInsets.all(16),
            backgroundColor: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          children: children,
        ),
      ],
    );
  }

  Widget colorBox(String label, Color color) {
    return Fx.col(
      children: [
        Fx.box(
          style: FxStyle(
            width: 60,
            height: 60,
            backgroundColor: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        Fx.gap(4),
        Fx.text(label).textXs(),
      ],
    );
  }
}
