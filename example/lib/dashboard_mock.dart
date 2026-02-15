import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';

class DashboardMock extends StatelessWidget {
  const DashboardMock({super.key});

  @override
  Widget build(BuildContext context) {
    return Fx.dashboard(
      sidebar: const DashboardSidebar(),
      navbar: const DashboardNavbar(),
      body: const DashboardBody(),
    );
  }
}

// ============================================================================
// NAVBAR WIDGET - Handles hamburger menu and responsive search
// ============================================================================
class DashboardNavbar extends StatelessWidget {
  const DashboardNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Fx.navbar(
      logo: const _NavbarLogo(),
      actions: [
        const _NavbarSearch(),
        Fx.gap(8), // Simplified gap
        const _NavbarNotification(),
        Fx.gap(8),
        const _NavbarProfile(),
      ],
      style: FxStyle(
        backgroundColor: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.blueGrey.shade100)),
      ),
    );
  }
}

class _NavbarLogo extends StatelessWidget {
  const _NavbarLogo();

  @override
  Widget build(BuildContext context) {
    return Fx.row(
      children: [
        const _HamburgerMenu().hideOn(desktop: true),
        Fx.gap(12).hideOn(desktop: true),
        Fx.text("Overview").font.h2(),
      ],
    );
  }
}

class _HamburgerMenu extends StatelessWidget {
  const _HamburgerMenu();

  @override
  Widget build(BuildContext context) {
    return Fx.box(
      style: FxStyle(
        padding: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.menu, size: 24, color: Colors.blueGrey.shade700),
    ).onHover((s) => s.bg(Colors.blueGrey.shade50)).onTap(() {
      Scaffold.of(context).openDrawer();
    }).pointer();
  }
}

class _NavbarSearch extends StatelessWidget {
  const _NavbarSearch();

  @override
  Widget build(BuildContext context) {
    return Fx.layout(
      mobile: _buildMobileSearch(context),
      desktop: _buildDesktopSearch(),
    );
  }

  Widget _buildDesktopSearch() {
    return Fx.box(
      style: FxStyle(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        borderRadius: BorderRadius.circular(20),
        backgroundColor: Colors.blueGrey.shade50,
      ),
      child: Fx.row(
        children: [
          const Icon(Icons.search, size: 18, color: Colors.blueGrey),
          Fx.gap(8),
          Fx.text("Search...").font.sm().muted(),
        ],
      ),
    ).w(200);
  }

  Widget _buildMobileSearch(BuildContext context) {
    return Fx.box(
      style: FxStyle(
        padding: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.search, size: 20, color: Colors.blueGrey),
    ).onHover((s) => s.bg(Colors.blueGrey.shade50)).onTap(() {
      showDialog(
        context: context,
        builder: (context) => const _SearchDialog(),
      );
    }).pointer();
  }
}

// Search Dialog Widget
class _SearchDialog extends StatefulWidget {
  const _SearchDialog();

  @override
  State<_SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<_SearchDialog> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Fx.box(
        style: FxStyle(
          padding: const EdgeInsets.all(20),
          borderRadius: BorderRadius.circular(16),
          backgroundColor: Colors.white,
          shadows: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Fx.col(
          size: MainAxisSize.min,
          children: [
            // Header
            Fx.row(
              justify: MainAxisAlignment.spaceBetween,
              children: [
                Fx.text("Search").font.h3(),
                Fx.box(
                  style: FxStyle(
                    padding: const EdgeInsets.all(4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.close, size: 20),
                ).onHover((s) => s.bg(Colors.blueGrey.shade50)).onTap(() {
                  Navigator.of(context).pop();
                }).pointer(),
              ],
            ),
            Fx.gap(16),
            
            // Search Input
            Fx.box(
              style: FxStyle(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                borderRadius: BorderRadius.circular(12),
                backgroundColor: Colors.blueGrey.shade50,
                border: Border.all(color: Colors.blueGrey.shade200),
              ),
              child: Fx.row(
                children: [
                  const Icon(Icons.search, size: 20, color: Colors.blueGrey),
                  Fx.gap(12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Search for anything...',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(fontSize: 16),
                      onSubmitted: (value) {
                        // Handle search
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
            Fx.gap(16),
            
            // Quick Actions / Recent Searches
            Fx.col(
              items: CrossAxisAlignment.start,
              children: [
                Fx.text("Recent Searches").font.sm().muted(),
                Fx.gap(12),
                _searchSuggestion("Dashboard Analytics", Icons.analytics_outlined),
                _searchSuggestion("Customer Reports", Icons.people_outline),
                _searchSuggestion("Product Inventory", Icons.inventory_2_outlined),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchSuggestion(String text, IconData icon) {
    return Fx.box(
      style: FxStyle(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Fx.row(
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey.shade600),
          Fx.gap(12),
          Fx.text(text).font.sm(),
        ],
      ),
    ).onHover((s) => s.bg(Colors.blueGrey.shade50)).onTap(() {
      Navigator.of(context).pop();
      // Handle search with this suggestion
    }).pointer();
  }
}

class _NavbarNotification extends StatelessWidget {
  const _NavbarNotification();

  @override
  Widget build(BuildContext context) {
    return Fx.box(
      style: FxStyle(
        padding: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.notifications_none_outlined, size: 22, color: Colors.blueGrey.shade600),
    ).onHover((s) => s.bg(Colors.blueGrey.shade50)).onTap(() {}).pointer();
  }
}

class _NavbarProfile extends StatelessWidget {
  const _NavbarProfile();

  @override
  Widget build(BuildContext context) {
    return Fx.avatar(
      fallback: "JD",
    )
    .background(Colors.blue)
    .size(Fx.on(context, mobile: 32.0, desktop: 36.0))
    .roundedFull()
    .fontSize(11, md: 12)
    .color(Colors.white);
  }
}

// ============================================================================
// SIDEBAR WIDGET - Clean sidebar with items
// ============================================================================
class DashboardSidebar extends StatelessWidget {
  const DashboardSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Fx.sidebar(
      header: const _SidebarHeader(),
      items: const [
        _SidebarItem(icon: Icons.dashboard_outlined, label: "Dashboard", active: true),
        _SidebarItem(icon: Icons.analytics_outlined, label: "Analytics"),
        _SidebarItem(icon: Icons.people_outline, label: "Customers"),
        _SidebarItem(icon: Icons.inventory_2_outlined, label: "Products"),
        _SidebarItem(icon: Icons.settings_outlined, label: "Settings"),
      ],
      footer: const _SidebarFooter(),
      style: const FxStyle(backgroundColor: Color(0xFFF8FAFC)),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader();

  @override
  Widget build(BuildContext context) {
    return Fx.row(
      children: [
        Fx.box(
          style: FxStyle(
            width: 40,
            height: 40,
            borderRadius: BorderRadius.circular(8),
            backgroundColor: Colors.blue.shade600,
          ),
          child: const Icon(Icons.bolt, color: Colors.white),
        ),
        Fx.gap(12),
        Fx.text("Fluxy Pro").font.h3(),
      ],
    ).p(16);
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _SidebarItem({
    required this.icon,
    required this.label,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Box(
      style: FxStyle(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        borderRadius: BorderRadius.circular(8),
        backgroundColor: active ? Colors.blue.shade50 : Colors.transparent,
        direction: Axis.horizontal,
        alignItems: CrossAxisAlignment.center,
      ),
      children: [
        Icon(icon, size: 20, color: active ? Colors.blue.shade700 : Colors.blueGrey.shade600),
        Fx.gap(12),
        Fx.text(label)
            .font.sm()
            .fontWeight(active ? FontWeight.w600 : FontWeight.w500)
            .color(active ? Colors.blue.shade700 : Colors.blueGrey.shade700),
      ],
    ).onHover((s) => s.bg(active ? Colors.blue.shade100 : Colors.blueGrey.shade100)).onTap(() {}).pointer();
  }
}

class _SidebarFooter extends StatelessWidget {
  const _SidebarFooter();

  @override
  Widget build(BuildContext context) {
    return Fx.col(
      children: [
        Fx.box(
          style: FxStyle(
            padding: const EdgeInsets.all(12),
            borderRadius: BorderRadius.circular(12),
            backgroundColor: Colors.blue.shade50,
          ),
          child: Fx.col(
            children: [
              Fx.text("Upgrade to Pro").font.sm().bold().primary(),
              Fx.text("Get unlimited access").font.xs().muted().mt(4),
            ],
          ),
        ).onTap(() {}),
        Fx.gap(12),
        const _SidebarItem(icon: Icons.logout, label: "Logout"),
      ],
    ).p(16);
  }
}

// ============================================================================
// BODY WIDGET - Main dashboard content
// ============================================================================
class DashboardBody extends StatelessWidget {
  const DashboardBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Fx.scroll(
      child: Fx.box()
        .px(16, md: 24, lg: 48) // INCREASED RESPONSIVE PADDING
        .py(16)
        .children([
          const SizedBox(height: 16),
          const _WelcomeHeader(),
          const SizedBox(height: 20),
          const _StatCardsGrid(),
          const SizedBox(height: 24),
          const _MainContentSection(),
          const SizedBox(height: 40),
        ]),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    return Fx.col(
      items: CrossAxisAlignment.start,
      children: [
        Fx.text("Welcome back, John!").font.h3(),
        Fx.text("Here's what's happening with your projects today.").font.sm().muted().mt(4),
      ],
    );
  }
}

// ============================================================================
// STAT CARDS - Responsive grid of statistics
// ============================================================================
class _StatCardsGrid extends StatelessWidget {
  const _StatCardsGrid();

  @override
  Widget build(BuildContext context) {
    return FxGrid.responsive(
      gap: 16,
      xs: 1, // 1 column on mobile
      sm: 2, // 2 columns on tablet
      lg: 4, // 4 columns on desktop
      childAspectRatio: 2.0, // Adjusted for better fit
      shrinkWrap: true, // IMPORTANT for scrollable parents
      physics: const NeverScrollableScrollPhysics(), // Let Fx.scroll handle it
      children: const [
        _StatCard(
          label: "Total Revenue",
          value: "\$45,231.89",
          subtitle: "+20.1%",
          icon: Icons.attach_money,
          color: Colors.green,
        ),
        _StatCard(
          label: "Subscriptions",
          value: "+2350",
          subtitle: "+180.1%",
          icon: Icons.people_outline,
          color: Colors.blue,
        ),
        _StatCard(
          label: "Active Sales",
          value: "+12,234",
          subtitle: "+19%",
          icon: Icons.credit_card,
          color: Colors.orange,
        ),
        _StatCard(
          label: "Active Now",
          value: "+573",
          subtitle: "+201 since last hour",
          icon: Icons.radar,
          color: Colors.purple,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Fx.box(
      style: FxStyle(
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        backgroundColor: Colors.white,
        shadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Fx.col(
        items: CrossAxisAlignment.start,
        size: MainAxisSize.min,
        children: [
          Fx.row(
            justify: MainAxisAlignment.spaceBetween,
            items: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Fx.text(label).font.xs().muted().fontWeight(FontWeight.w600),
              ),
              Fx.gap(8),
              Icon(icon, size: 16, color: Colors.blueGrey.shade400),
            ],
          ),
          Fx.gap(8),
          Fx.text(value).fontSize(20).bold(),
          Fx.gap(4),
          Fx.text(subtitle).font.xs().color(color),
        ],
      ),
    ).onHover((s) => s.scale(1.02)).pointer();
  }
}

// ============================================================================
// MAIN CONTENT SECTION - Recent Activity & Active Projects
// ============================================================================
class _MainContentSection extends StatelessWidget {
  const _MainContentSection();

  @override
  Widget build(BuildContext context) {
    // Only expand horizontally when in a Row (Desktop/Tablet)
    final isExpanded = Fx.on(context, mobile: false, tablet: true);

    return Fx.row(
      responsive: true,
      items: CrossAxisAlignment.start,
      gap: 24,
      children: [
        const _RecentActivityCard().then((w) => isExpanded ? w.expand(flex: 2) : w),
        const _ActiveProjectsCard().then((w) => isExpanded ? w.expand(flex: 1) : w),
      ],
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard();

  @override
  Widget build(BuildContext context) {
    return Fx.box(
      style: FxStyle(
        padding: const EdgeInsets.all(20),
        borderRadius: BorderRadius.circular(12),
        backgroundColor: Colors.white,
        shadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Fx.col(
        items: CrossAxisAlignment.start,
        children: [
          Fx.row(
            justify: MainAxisAlignment.spaceBetween,
            children: [
              Fx.text("Recent Activity").font.h1().textLg(),
              Fx.text("View All").font.sm().primary().onTap(() {}).pointer(),
            ],
          ),
          Fx.gap(16),
          const _RecentActivityTable(),
        ],
      ),
    );
  }
}

class _RecentActivityTable extends StatelessWidget {
  const _RecentActivityTable();

  @override
  Widget build(BuildContext context) {
    final data = [
      {"name": "Invoice #1234", "user": "Alen Watts", "amount": "\$2,500", "status": "Paid"},
      {"name": "Invoice #1235", "user": "Sarah Doe", "amount": "\$1,200", "status": "Pending"},
      {"name": "Invoice #1236", "user": "Mike Ross", "amount": "\$800", "status": "Paid"},
      {"name": "Invoice #1237", "user": "Emma Stone", "amount": "\$3,100", "status": "Cancelled"},
    ];

    return Fx.table<Map<String, String>>(
      data: data,
      columns: [
        FxTableColumn<Map<String, String>>(
          header: "Description",
          cellBuilder: (d) => Fx.text(d['name']!).font.sm().medium(),
        ),
        FxTableColumn<Map<String, String>>(
          header: "User",
          cellBuilder: (d) => Fx.text(d['user']!).font.sm(),
        ),
        FxTableColumn<Map<String, String>>(
          header: "Amount",
          cellBuilder: (d) => Fx.text(d['amount']!).font.sm().bold(),
        ),
        FxTableColumn<Map<String, String>>(
          header: "Status",
          cellBuilder: (d) => _StatusBadge(status: d['status']!),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == "Paid"
        ? Colors.green
        : (status == "Pending" ? Colors.orange : Colors.red);

    return Fx.box(
      style: FxStyle(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        borderRadius: BorderRadius.circular(12),
        backgroundColor: color.withValues(alpha: 0.1),
      ),
      child: Fx.text(status).font.xs().bold().color(color),
    ).center(); // Forces it to be compact instead of stretching
  }
}

class _ActiveProjectsCard extends StatelessWidget {
  const _ActiveProjectsCard();

  @override
  Widget build(BuildContext context) {
    return Fx.box(
      style: FxStyle(
        padding: const EdgeInsets.all(20),
        borderRadius: BorderRadius.circular(12),
        backgroundColor: Colors.white,
        shadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Fx.col(
        items: CrossAxisAlignment.stretch,
        children: [
          Fx.text("Active Projects").font.h1().textLg(),
          Fx.gap(16),
          const _ProjectItem(name: "Fluxy UI Kit", type: "Design System", progress: 75),
          const _ProjectItem(name: "Analytics Dashboard", type: "Web App", progress: 40),
          const _ProjectItem(name: "Mobile Refactor", type: "App", progress: 90),
          Fx.gap(12),
          "New Project".primaryBtn().wFull(),
        ],
      ),
    );
  }
}

class _ProjectItem extends StatelessWidget {
  final String name;
  final String type;
  final int progress;

  const _ProjectItem({
    required this.name,
    required this.type,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Fx.col(
      items: CrossAxisAlignment.stretch, // Forces children to take full width
      children: [
        Fx.row(
          justify: MainAxisAlignment.spaceBetween,
          children: [
            Fx.col(
              items: CrossAxisAlignment.start,
              children: [
                Fx.text(name).font.sm().bold(),
                Fx.text(type).font.xs().muted(),
              ],
            ),
            Fx.text("$progress%").font.xs().bold(),
          ],
        ),
        Fx.gap(8),
        // Simplified Progress Bar using Stack (Very Stable)
        Fx.stack(
          children: [
            // Background
            Fx.box().h(6).bg(Colors.blueGrey.shade50).rounded(3).wFull(),
            // Progress
            Fx.box()
              .h(6)
              .bg(Colors.blue)
              .rounded(3)
              .then((w) => FractionallySizedBox(widthFactor: progress / 100, child: w)),
          ],
        ),
        Fx.gap(16),
      ],
    );
  }
}
