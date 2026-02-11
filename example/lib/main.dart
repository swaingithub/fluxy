import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';

void main() {
  runApp(const FluxyDemo());
}

class FluxyDemo extends StatefulWidget {
  const FluxyDemo({super.key});

  @override
  State<FluxyDemo> createState() => _FluxyDemoState();
}

class _FluxyDemoState extends State<FluxyDemo> {
  bool isDarkMode = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      navigatorKey: FluxyRouter.navigatorKey, // Setup router
      onGenerateRoute: FluxyRouter.onGenerateRoute,
      home: DashboardPage(
        isDarkMode: isDarkMode,
        onThemeToggle: () => setState(() => isDarkMode = !isDarkMode),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const DashboardPage({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1E293B);

    final count = flux(0); // Reactive state

    return Scaffold(
      backgroundColor: bgColor,
      body: Fx.row(
        children: [
          // 1. Sidebar (Visible on MD+)
          Fx.responsive(
            mobile: const SizedBox.shrink(),
            tablet: _buildSidebar(context, isDarkMode),
          ),

          // 2. Main Content
          Fx.column(
            children: [
              // Header
              _buildHeader(context, isDarkMode, onThemeToggle),

              // Scrollable Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Fx.column(
                    gap: 32,
                    children: [
                      // Welcome Text
                      Fx.column(
                        gap: 4,
                        children: [
                          Fx.text("Fluxy Framework v1.0 💎")
                            .font(28)
                            .bold()
                            .color(textColor),
                          Fx.text("The SwiftUI + Tailwind equivalent for Flutter.")
                            .font(14)
                            .color(textColor.withOpacity(0.6)),
                        ],
                      ),

                      // Fluent Modifier Demo
                      Fx.card(
                        child: Fx.column(
                          gap: 16,
                          children: [
                            Fx.text(() => "Reactive Count: ${count.value}")
                              .font(24)
                              .bold()
                              .center(),
                            Fx.row(
                              gap: 12,
                              children: [
                                Fx.button(
                                  onTap: () => count.value--,
                                  child: "Decrease",
                                ).expanded(),
                                Fx.button(
                                  onTap: () => count.value++,
                                  child: "Increase",
                                ).bg(Colors.indigoAccent).expanded(),
                              ],
                            ),
                          ],
                        ),
                      ).pad(8),

                      // Stats Grid
                      Fx.grid(
                        style: const Style(gap: 16),
                        children: [
                          _buildStatCard("Revenue", "\$54K", Icons.payments, Colors.green),
                          _buildStatCard("Users", "1.2K", Icons.people, Colors.blue),
                          _buildStatCard("Tasks", "12", Icons.assignment, Colors.orange),
                          _buildStatCard("Uptime", "99.9%", Icons.dns, Colors.purple),
                        ],
                      ).fit(FlexFit.loose),
                    ],
                  ),
                ),
              ),
            ],
          ).expanded(),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, bool dark) {
    final textColor = dark ? Colors.white : const Color(0xFF1E293B);
    return Fx.column(
      gap: 32,
      children: [
        Fx.row(
          gap: 12,
          children: [
            Fx.box()
              .size(40, 40)
              .bg(Colors.blue)
              .radius(12)
              .center()
              .copyWith(child: const Icon(Icons.bolt, color: Colors.white)),
            Fx.text("Fluxy App").font(20).bold().color(textColor),
          ],
        ),
        Fx.column(
          gap: 8,
          children: [
            _buildSidebarItem("Dashboard", Icons.dashboard, true, dark),
            _buildSidebarItem("Signals", Icons.sensors, false, dark),
            _buildSidebarItem("Layouts", Icons.grid_view, false, dark),
            _buildSidebarItem("Settings", Icons.settings, false, dark),
          ],
        ),
      ],
    )
    .width(280)
    .expanded()
    .bg(dark ? Colors.black.withOpacity(0.2) : Colors.white)
    .pad(24)
    .border(color: textColor.withOpacity(0.05), width: 1);
  }

  Widget _buildSidebarItem(String label, IconData icon, bool active, bool dark) {
    final activeColor = Colors.blueAccent;
    final idleColor = dark ? Colors.white54 : const Color(0xFF64748B);
    
    return Fx.row(
      gap: 12,
      children: [
        Icon(icon, color: active ? activeColor : idleColor, size: 20),
        Fx.text(label).color(active ? activeColor : idleColor).expanded(),
      ],
    )
    .pad(12)
    .radius(12)
    .bg(active ? activeColor.withOpacity(0.1) : Colors.transparent);
  }

  Widget _buildHeader(BuildContext context, bool dark, VoidCallback onToggle) {
    final textColor = dark ? Colors.white : const Color(0xFF1E293B);
    return Fx.row(
      children: [
        Fx.text("Search...").color(Colors.grey).pad(12).bg(Colors.grey.withOpacity(0.1)).radius(8).expanded(),
        Fx.gap(16),
        Fx.button(
          onTap: onToggle,
          child: Icon(dark ? Icons.light_mode : Icons.dark_mode, size: 20, color: textColor),
        ).size(40, 40).bg(Colors.transparent).radius(20).center(),
      ],
    )
    .height(80)
    .padX(24)
    .border(color: textColor.withOpacity(0.05));
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Fx.card(
      child: Fx.column(
        gap: 12,
        children: [
          Fx.box().size(48, 48).bg(color.withOpacity(0.1)).radius(12).center()
            .copyWith(child: Icon(icon, color: color)),
          Fx.column(
            children: [
              Fx.text(label).font(12).color(Colors.grey),
              Fx.text(value).font(24).bold(),
            ],
          ),
        ],
      ),
    );
  }
}
