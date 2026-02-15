import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';

/// This demo showcases the "Single Line Responsive" syntax inspired by Tailwind CSS.
/// It solves the problem of writing verbose boilerplate for different layouts.
class ResponsiveDemo extends StatelessWidget {
  const ResponsiveDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Fx.scroll(
        child: Fx.col(
          children: [
            _buildNavbar(context),
            _buildHero(context),
            _buildGrid(context),
            _buildStructuralDemo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildNavbar(BuildContext context) {
    return Fx.navbar(
      style: const FxStyle(backgroundColor: Colors.white),
      logo: Fx.row(
        gap: 8,
        children: [
          Fx.box().size(32).bg(Colors.blue).rounded(8),
          Fx.text("Fluxy").bold().fontSize(20),
        ],
      ),
      actions: [
        // Hidden on mobile, shown on desktop
        Fx.text("Documentation").hideOn(mobile: true),
        Fx.text("Pricing").hideOn(mobile: true),
        Fx.primaryButton("Get Started"),
      ],
    );
  }

  Widget _buildHero(BuildContext context) {
    return Fx.box(
      style: FxStyle(
        // Responsively change padding in one line!
        // xs: 24, md: 48, lg: 80
        padding: Fx.on(context, mobile: const EdgeInsets.all(24), tablet: const EdgeInsets.all(48), desktop: const EdgeInsets.all(80)),
        gradient: LinearGradient(colors: [Colors.blue.shade600, Colors.indigo.shade800]),
      ),
      child: Fx.row(
        responsive: true, // AUTO-SWITCHES TO COLUMN ON MOBILE!
        gap: 40,
        children: [
          Fx.col(
            items: CrossAxisAlignment.start,
            gap: 20,
            children: [
              Fx.text("Single Codebase.\nUnified Syntax.")
                  .bold()
                  .color(Colors.white)
                  // Change font size responsively in one line!
                  .fontSize(32, md: 48, lg: 64), 
              
              Fx.text("Build for Web, Tablet, and Mobile with 80% less code.")
                  .color(Colors.white.withOpacity(0.8))
                  .fontSize(16, md: 18, lg: 20),

              Fx.row(
                gap: 16,
                children: [
                   Fx.primaryButton("Download SDK"),
                   Fx.outlineButton("Read Docs"),
                ],
              ),
            ],
          ).expand(flex: 2),

          // Hide image on very small mobile, show on tablet+
          Fx.box()
              .size(200, md: 300, lg: 400)
              .bg(Colors.white.withOpacity(0.1))
              .rounded(20)
              .hideOn(mobile: true)
              .expand(flex: 1),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    return Fx.container(
      child: Fx.col(
        gap: 40,
        children: [
          Fx.text("Responsive Grid").bold().fontSize(32).center(),
          
          // Responsive Grid: 1 col on mobile, 2 on tablet, 3 on desktop
          FxGrid.responsive(
            gap: 24,
            xs: 1,
            md: 2,
            lg: 3,
            children: List.generate(6, (i) => _featureCard(i)),
          ),
        ],
      ),
    ).py(60);
  }

  Widget _featureCard(int i) {
    return Fx.box()
        .p(24)
        .bg(Colors.white)
        .rounded(16)
        .border(color: Colors.grey.shade200)
        .shadow(color: Colors.black.withOpacity(0.05), blur: 20)
        .children([
          Fx.box().size(48).bg(Colors.blue.shade50).rounded(12).child(Icon(Icons.bolt, color: Colors.blue.shade600)),
          const SizedBox(height: 16),
          Fx.text("Feature ${i + 1}").bold().fontSize(20),
          const SizedBox(height: 8),
          Fx.text("Automatically adjusting layout across all platforms with zero boilerplate.").color(Colors.grey),
        ]);
  }

  Widget _buildStructuralDemo(BuildContext context) {
    return Fx.container(
      child: Fx.col(
        gap: 24,
        children: [
           Fx.text("Structural Responsiveness").bold().fontSize(28).center(),
           
           // Use Fx.mobile / Fx.tablet / Fx.desktop for large structural chunks
           Fx.mobile([
             _statusBox("Mobile View Active", Colors.orange),
             const SizedBox(height: 12),
             Fx.text("You are seeing the mobile-optimized compact interface."),
           ]),

           Fx.tablet([
             _statusBox("Tablet View Active", Colors.green),
             const SizedBox(height: 12),
             Fx.text("Layout expanded for larger screens, using row/col mix."),
           ]),

           Fx.desktop([
             _statusBox("Desktop View Active", Colors.blue),
             const SizedBox(height: 12),
             Fx.text("Full feature set revealed. High-density data grid enabled."),
           ]),
        ],
      ),
    ).paddingOnly(bottom: 100);
  }

  Widget _statusBox(String text, Color color) {
    return Fx.box()
        .p(16)
        .bg(color.withOpacity(0.1))
        .rounded(12)
        .border(color: color.withOpacity(0.3))
        .child(Fx.text(text).bold().color(color).center());
  }
}
