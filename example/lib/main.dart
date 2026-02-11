import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';

import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/projects_screen.dart';

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
      navigatorKey: FluxyRouter.navigatorKey,
      onGenerateRoute: FluxyRouter.onGenerateRoute,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => DashboardPage(
          isDarkMode: isDarkMode,
          onThemeToggle: () => setState(() => isDarkMode = !isDarkMode),
        ),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/projects': (context) => const ProjectsScreen(),
      },
      home: LoginScreen(), // Start with login
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

    final count = flux(0);

    return Scaffold(
      backgroundColor: bgColor,
      body: Fx.row(
        children: [
          // Sidebar
          Fx.responsive(
            mobile: const SizedBox.shrink(),
            tablet: _buildSidebar(context, isDarkMode),
          ),

          // Main Content
          Fx.column(
            children: [
              _buildHeader(context, isDarkMode, onThemeToggle),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Fx.column(
                    gap: 32,
                    children: [
                      Fx.column(
                        gap: 4,
                        children: [
                          Fx.text("Fluxy v1.0 💎").font(32).bold().color(textColor),
                          Fx.text("High-performance reactive engine for Flutter.").font(16).color(textColor.withOpacity(0.6)),
                        ],
                      ),

                      Fx.card(
                        child: Fx.column(
                          gap: 16,
                          children: [
                            Fx.text(() => "Reactive Count: ${count.value}").font(24).bold().center(),
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
                      ),

                      Fx.grid(
                        style: const FxStyle(gap: 16),
                        children: [
                          _buildStatCard("Revenue", "\$54,230", Icons.payments, Colors.green),
                          _buildStatCard("Active Users", "1,240", Icons.people, Colors.blue),
                          _buildStatCard("Conversion", "3.2%", Icons.trending_up, Colors.purple),
                          _buildStatCard("Tasks", "12", Icons.assignment, Colors.orange),
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
            Fx.box().size(40, 40).bg(Colors.blue).radius(12).center().copyWith(child: const Icon(Icons.bolt, color: Colors.white)),
            Fx.text("Fluxy App").font(20).bold(),
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
    .width(280).expanded().bg(dark ? Colors.black.withOpacity(0.2) : Colors.white)
    .pad(24).border(color: textColor.withOpacity(0.05));
  }

  Widget _buildSidebarItem(String label, IconData icon, bool active, bool dark) {
    return Fx.row(
      gap: 12,
      children: [
        Icon(icon, color: active ? Colors.blue : (dark ? Colors.white54 : Colors.black45), size: 20),
        Fx.text(label).expanded().color(active ? Colors.blue : (dark ? Colors.white54 : Colors.black45)),
      ],
    ).pad(12).radius(12).bg(active ? Colors.blue.withOpacity(0.1) : Colors.transparent);
  }

  Widget _buildHeader(BuildContext context, bool dark, VoidCallback onToggle) {
    return Fx.row(
      children: [
        Fx.text("Search...").color(Colors.grey).pad(12).bg(Colors.grey.withOpacity(0.1)).radius(8).expanded(),
        Fx.gap(16),
        Fx.button(
          onTap: onToggle,
          child: Icon(dark ? Icons.light_mode : Icons.dark_mode, size: 20),
        ).size(40, 40).bg(Colors.transparent).radius(20).center(),
      ],
    ).height(80).padX(24).border(color: (dark ? Colors.white : Colors.black).withOpacity(0.05));
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Fx.card(
      child: Fx.column(
        gap: 12,
        children: [
          Fx.box().size(48, 48).bg(color.withOpacity(0.1)).radius(12).center().copyWith(child: Icon(icon, color: color)),
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
