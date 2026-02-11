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
      home: FluxyInspector(
        child: DashboardPage(
          isDarkMode: isDarkMode,
          onThemeToggle: () => setState(() => isDarkMode = !isDarkMode),
        ),
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
    final cardColor = isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: bgColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () => FluxyDebugConfig.toggleInspector(),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.bug_report, color: Colors.white),
      ),
      body: UI.row(
        style: const Style(width: double.infinity, height: double.infinity),
        children: [
          // 1. Sidebar (Visible on MD+)
          if (ResponsiveEngine.of(context).index >= Breakpoint.md.index)
            _buildSidebar(context, isDarkMode),

          // 2. Main Content
          UI.box(
            style: const Style(flex: 1),
            child: UI.column(
              children: [
                // Header
                _buildHeader(context, isDarkMode, onThemeToggle),

                // Scrollable Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: UI.column(
                      className: "gap-8",
                      children: [
                        // Welcome Text
                        UI.column(
                          className: "gap-1",
                          children: [
                            UI.text("Welcome back, Alex!", className: "text-2xl font-bold", style: Style(color: textColor)),
                            UI.text("Here's what's happening with your projects today.", className: "text-sm", style: Style(color: textColor.withOpacity(0.6))),
                          ],
                        ),

                        // Stats Grid (Responsive)
                        UI.grid(
                          responsive: const ResponsiveStyle(
                            xs: Style(crossAxisCount: 1, gap: 16),
                            sm: Style(crossAxisCount: 2),
                            lg: Style(crossAxisCount: 4),
                          ),
                          children: [
                            _buildStatCard("Total Revenue", "\$54,230", Icons.payments, Colors.green),
                            _buildStatCard("Active Users", "1,240", Icons.people, Colors.blue),
                            _buildStatCard("Conversion", "3.2%", Icons.trending_up, Colors.purple),
                            _buildStatCard("Pending Tasks", "12", Icons.assignment, Colors.orange),
                          ],
                        ),

                        // Main Content Sections
                        UI.flex(
                          direction: ResponsiveEngine.value(context, xs: Axis.vertical, lg: Axis.horizontal),
                          className: "gap-8",
                          children: [
                            // Main Chart area
                            UI.box(
                              responsive: const ResponsiveStyle(
                                xs: Style(flex: null),
                                lg: Style(flex: 2),
                              ),
                              style: Style(
                                backgroundColor: cardColor,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: textColor.withOpacity(0.05)),
                                padding: const EdgeInsets.all(24),
                                height: 400,
                              ),
                              child: UI.column(
                                children: [
                                  UI.row(
                                    className: "justify-between items-center mb-6",
                                    children: [
                                      UI.text("Revenue Analytics", style: Style(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
                                      UI.box(
                                        className: "px-3 py-1 bg-blue-500/10 rounded-full",
                                        child: UI.text("Last 30 Days", className: "text-blue-500 text-xs"),
                                      ),
                                    ],
                                  ),
                                  // Placeholder for Chart
                                  Expanded(
                                    child: UI.box(
                                      className: "w-full bg-slate-500/5 rounded-2xl border-2 border-dashed border-slate-500/20 items-center justify-center",
                                      child: UI.text("Interactive Chart Visualization", style: Style(color: textColor.withOpacity(0.3))),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Sidebar activity area
                            UI.box(
                              responsive: const ResponsiveStyle(
                                xs: Style(flex: null),
                                lg: Style(flex: 1),
                              ),
                              style: Style(
                                backgroundColor: cardColor,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: textColor.withOpacity(0.05)),
                                padding: const EdgeInsets.all(24),
                              ),
                              child: UI.column(
                                className: "gap-6",
                                children: [
                                  UI.text("Recent Activity", style: Style(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
                                  _buildActivityItem("Payment received from Google", "2m ago", Icons.check_circle, Colors.green),
                                  _buildActivityItem("New server instance started", "45m ago", Icons.dns, Colors.blue),
                                  _buildActivityItem("Low disk space warning", "2h ago", Icons.warning, Colors.red),
                                  _buildActivityItem("New user registered", "5h ago", Icons.person_add, Colors.purple),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Interactive Component Demo
                        UI.box(
                          className: "p-8 rounded-3xl",
                          style: const Style(
                            gradient: LinearGradient(colors: [Colors.blueAccent, Colors.purpleAccent]),
                          ),
                          child: UI.row(
                            className: "justify-between items-center",
                            children: [
                              UI.box(
                                style: const Style(flex: 1),
                                child: UI.column(
                                  className: "gap-2",
                                  children: [
                                    UI.text("Fluxy v1.0 🚀", className: "text-white text-xl font-bold"),
                                    UI.text("Fastest production-grade engine.", className: "text-white/80 text-sm"),
                                  ],
                                ),
                              ),
                              UI.box(
                                className: "bg-white px-6 py-3 rounded-xl",
                                style: const Style(
                                  transition: Duration(milliseconds: 200),
                                  hover: Style(backgroundColor: Colors.white70),
                                ),
                                child: UI.text("Get Started", className: "text-blue-600 font-bold"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, bool dark) {
    final textColor = dark ? Colors.white : const Color(0xFF1E293B);
    return UI.box(
      style: Style(
        width: 280,
        height: double.infinity,
        backgroundColor: dark ? Colors.black.withOpacity(0.2) : Colors.white,
        border: Border(right: BorderSide(color: textColor.withOpacity(0.05))),
        padding: const EdgeInsets.all(24),
      ),
      child: UI.column(
        className: "gap-8",
        children: [
          UI.row(
            className: "items-center gap-3",
            children: [
              UI.box(
                className: "w-10 h-10 bg-blue-600 rounded-xl items-center justify-center",
                child: const Icon(Icons.waves, color: Colors.white),
              ),
              UI.text("Fluxy Ocean", style: Style(fontWeight: FontWeight.w900, fontSize: 20, color: textColor)),
            ],
          ),
          UI.column(
            className: "gap-2",
            children: [
              _buildSidebarItem("Dashboard", Icons.dashboard, true, dark),
              _buildSidebarItem("Analytics", Icons.analytics, false, dark),
              _buildSidebarItem("Team", Icons.group, false, dark),
              _buildSidebarItem("Settings", Icons.settings, false, dark),
            ],
          ),
          const Spacer(),
          UI.box(
            className: "p-4 bg-blue-600/10 rounded-2xl",
            child: UI.column(
              className: "gap-2",
              children: [
                UI.text("Upgrade to Pro", style: Style(fontWeight: FontWeight.bold, color: Colors.blue)),
                UI.text("Get advanced layout features and grid components.", style: Style(fontSize: 12, color: Colors.blue.withOpacity(0.7))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(String label, IconData icon, bool active, bool dark) {
    final activeColor = Colors.blueAccent;
    final idleColor = dark ? Colors.white54 : const Color(0xFF64748B);
    
    return UI.box(
      className: "px-4 py-3 rounded-xl gap-3 flex-row items-center",
      style: Style(
        backgroundColor: active ? activeColor.withOpacity(0.1) : Colors.transparent,
        transition: const Duration(milliseconds: 200),
        hover: Style(backgroundColor: dark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02)),
      ),
      children: [
        Icon(icon, color: active ? activeColor : idleColor, size: 20),
        UI.box(
          style: const Style(flex: 1),
          child: UI.text(
            label, 
            style: Style(
              color: active ? activeColor : idleColor, 
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, bool dark, VoidCallback onToggle) {
    final textColor = dark ? Colors.white : const Color(0xFF1E293B);
    return UI.box(
      style: Style(
        height: 80,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        border: Border(bottom: BorderSide(color: textColor.withOpacity(0.05))),
        justifyContent: MainAxisAlignment.center,
      ),
      child: UI.row(
        className: "justify-between items-center",
        children: [
          UI.box(
            style: const Style(flex: 1),
            child: UI.box(
              className: "px-4 py-2 bg-slate-500/10 rounded-lg flex-row items-center gap-2",
              children: [
                const Icon(Icons.search, size: 18, color: Colors.grey),
                UI.text("Search...", className: "text-grey text-sm"),
              ],
            ),
          ),
          const SizedBox(width: 16),
          UI.row(
            className: "gap-4 items-center",
            children: [
              UI.box(
                onTap: onToggle,
                className: "w-10 h-10 items-center justify-center rounded-full bg-slate-500/10",
                child: Icon(dark ? Icons.light_mode : Icons.dark_mode, size: 20, color: textColor),
              ),
              UI.box(
                className: "w-10 h-10 bg-orange-500 rounded-full items-center justify-center border-2 border-white/20",
                child: UI.text("A", className: "text-white font-bold"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return UI.box(
      className: "p-6 rounded-3xl bg-slate-500/5 border border-slate-500/10",
      style: const Style(
        transition: Duration(milliseconds: 300),
        hover: Style(backgroundColor: Colors.blueAccent, shadows: [BoxShadow(color: Colors.blueAccent, blurRadius: 20, spreadRadius: -10)]),
      ),
      child: UI.column(
        className: "gap-4",
        children: [
          UI.row(
            className: "justify-between items-start",
            children: [
              UI.box(
                className: "w-12 h-12 rounded-2xl items-center justify-center",
                style: Style(backgroundColor: color.withOpacity(0.1)),
                child: Icon(icon, color: color),
              ),
              const Icon(Icons.more_horiz, color: Colors.grey),
            ],
          ),
          UI.column(
            className: "gap-1",
            children: [
              UI.text(label, className: "text-xs text-grey"),
              UI.text(value, className: "text-2xl font-black"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String label, String time, IconData icon, Color color) {
    return UI.row(
      className: "gap-4",
      children: [
        UI.box(
          className: "w-10 h-10 rounded-full items-center justify-center",
          style: Style(backgroundColor: color.withOpacity(0.1)),
          child: Icon(icon, color: color, size: 18),
        ),
        UI.column(
          className: "gap-1 flex-1",
          children: [
            UI.text(label, className: "text-sm font-medium", style: const Style(overflow: TextOverflow.ellipsis)),
            UI.text(time, className: "text-xs text-grey"),
          ],
        ),
      ],
    );
  }
}
