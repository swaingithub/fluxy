// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';

// --- Global Reactive State (Fintech Design Hub) ---
final balance = flux(42840.50);
final income = flux(15400.00);
final expense = flux(6200.00);

final transactions = flux(<Map<String, dynamic>>[
  {
    'title': 'Amazon India',
    'subtitle': 'Electronics & Gadgets',
    'amount': -12499.00,
    'icon': Icons.shopping_bag_rounded,
    'color': const Color(0xFFFF9900),
  },
  {
    'title': 'HDFC Salary Deposit',
    'subtitle': 'Monthly Payout',
    'amount': 85000.00,
    'icon': Icons.account_balance_wallet_rounded,
    'color': const Color(0xFF10B981),
  },
  {
    'title': 'Zomato UX',
    'subtitle': 'Dining & Delivery',
    'amount': -840.50,
    'icon': Icons.fastfood_rounded,
    'color': const Color(0xFFEF4444),
  },
  {
    'title': 'Netflix Premium',
    'subtitle': 'Entertainment',
    'amount': -649.00,
    'icon': Icons.play_circle_fill,
    'color': const Color(0xFFE50914),
  },
]);

final filter = flux("All");

void main() => runApp(
  MaterialApp(
    navigatorKey: FluxyRouter.navigatorKey,
    debugShowCheckedModeBanner: false,
    home: const FluxyFintechApp(),
  ),
);

class FluxyFintechApp extends StatefulWidget {
  const FluxyFintechApp({super.key});

  @override
  State<FluxyFintechApp> createState() => _FluxyFintechAppState();
}

class _FluxyFintechAppState extends State<FluxyFintechApp> {
  int _activePage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _buildPage(),
      bottomNavigationBar: _buildPremiumNav(),
    );
  }

  Widget _buildPage() {
    switch (_activePage) {
      case 0:
        return const WalletDashboard();
      case 1:
        return const PortfolioStats();
      default:
        return const WalletDashboard();
    }
  }

  Widget _buildPremiumNav() {
    return FxBottomBar(
      currentIndex: _activePage,
      onTap: (i) => setState(() => _activePage = i),
      activeColor: const Color(0xFF6366F1),
      baseColor: const Color(0xFF94A3B8),
      items: const [
        FxBottomBarItem(icon: Icons.grid_view_rounded, label: "Home"),
        FxBottomBarItem(icon: Icons.auto_graph_rounded, label: "Stats"),
        FxBottomBarItem(
          icon: Icons.account_balance_wallet_rounded,
          label: "Wallet",
        ),
        FxBottomBarItem(icon: Icons.person_rounded, label: "Profile"),
      ],
    );
  }
}

// --- SCREEN 1: WALLET DASHBOARD ---
class WalletDashboard extends StatelessWidget {
  const WalletDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            // Branding & Profile Header
            Fx.row(
              children: [
                Fx.column(
                  gap: 4,
                  children: [
                    Fx.text("Welcome back,")
                        .fontSize(14)
                        .color(const Color(0xFF64748B))
                        .weight(FontWeight.w500),
                    Fx.text(
                      "Alex Riviera",
                    ).fontSize(26).bold().color(const Color(0xFF0F172A)),
                  ],
                ).expand(),
                Fx.avatar(
                  fallback: "AR",
                  size: FxAvatarSize.lg,
                  shape: FxAvatarShape.rounded,
                  onTap: () => Fx.toast("Profile tapped"),
                ).shadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                  blur: 20,
                ),
              ],
            ),
            const SizedBox(height: 36),

            // Main Balance Gradient Card
            Fx.box(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Fx.row(
                        children: [
                          const Text(
                            "AVAILABLE BALANCE",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          const Spacer(),
                          Fx.box(
                                child: const Icon(
                                  Icons.nfc_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              )
                              .size(36, 36)
                              .background(Colors.white.withValues(alpha: 0.1))
                              .borderRadius(10)
                              .center(),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Fx.text(() => "₹ ${balance.value.toStringAsFixed(2)}")
                          .fontSize(38) // Reduced from 44
                          .bold()
                          .color(Colors.white),
                      const SizedBox(height: 24),
                      Fx.row(
                        gap: 20, // Reduced from 24
                        children: [
                          _miniStat(
                            "Income",
                            "₹ ${income.value.toInt()}",
                            const Color(0xFF10B981),
                          ),
                          _miniStat(
                            "Expense",
                            "₹ ${expense.value.toInt()}",
                            const Color(0xFFEF4444),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
                .background(const Color(0xFF1E293B))
                .borderRadius(36)
                .padding(24) // Reduced from 32
                .shadow(
                  color: const Color(0xFF000000).withValues(alpha: 0.15),
                  blur: 40,
                ),

            const SizedBox(height: 36),

            // Quick Actions Grid-like row
            Fx.row(
              style: const FxStyle(
                justifyContent: MainAxisAlignment.spaceBetween,
              ),
              children: [
                _actionCircle(
                  Icons.send_rounded,
                  "Send",
                  const Color(0xFF6366F1),
                ),
                _actionCircle(
                  Icons.qr_code_scanner_rounded,
                  "Scan",
                  const Color(0xFFF59E0B),
                ),
                _actionCircle(
                  Icons.account_balance_rounded,
                  "Bank",
                  const Color(0xFF10B981),
                ),
                _actionCircle(
                  Icons.more_horiz_rounded,
                  "More",
                  const Color(0xFF64748B),
                ),
              ],
            ),

            const SizedBox(height: 24),
            // Example Button as requested
            Fx.button(
              "Add New Card",
              onTap: () {},
            ).fullWidth().sizeLg().shadowMedium(),

            const SizedBox(height: 48),

            // Transactions Header with Dropdown
            Fx.row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Fx.text(
                  "Recent Transactions",
                ).fontSize(20).bold().color(const Color(0xFF0F172A)),
                // Reactive Dropdown: Automatically updates 'filter' signal
                Fx.dropdown<String>(
                  signal: filter, // Pass the signal directly
                  items: ["All", "Credit", "Debit"],
                  itemLabel: (s) => s,
                ).w(100),
              ],
            ),
            const SizedBox(height: 24),

            Fx.column(
              gap: 16,
              children: transactions.value
                  .map(
                    (tx) => _transactionTile(
                      tx['title'],
                      tx['subtitle'],
                      tx['amount'],
                      tx['icon'],
                      tx['color'],
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 48),
            Fx.text(
              "Quick Actions",
            ).fontSize(18).bold().color(Colors.grey[800]!),
            const SizedBox(height: 16),

            // Redesigned Action Row
            Fx.row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton(
                  Icons.notifications_active_outlined,
                  "Toast",
                  () => Fx.toast("Fluxy toast message!"),
                  badgeCount: 3,
                ),
                _actionButton(
                  Icons.window_outlined,
                  "Modal",
                  () => Fx.modal(
                    context,
                    child: Fx.box(
                      child: Fx.column(
                        children: [
                          Fx.text("Fluxy Modal").bold().fontSize(18),
                          const SizedBox(height: 12),
                          Fx.text(
                            "Declarative & Simple.",
                          ).textCenter().color(Colors.grey),
                          const SizedBox(height: 24),
                          Fx.button(
                            "Close",
                            onTap: () => Navigator.pop(context),
                          ).fullWidth(),
                        ],
                      ).pack(),
                    ).p(24).backgroundWhite().rounded(24).w(300),
                  ),
                ),
                _actionButton(
                  Icons.vertical_align_bottom_outlined,
                  "Sheet",
                  () => Fx.bottomSheet(
                    context,
                    child: Fx.box(
                      child: Fx.column(
                        children: [
                          Fx.box()
                              .w(40)
                              .h(4)
                              .bg(Colors.grey[300]!)
                              .roundedFull(),
                          const SizedBox(height: 24),
                          Fx.text("Bottom Sheet").bold().fontSize(20),
                          const SizedBox(height: 12),
                          Fx.text("Swipe down to close.").color(Colors.grey),
                          const SizedBox(height: 40),
                          Fx.button(
                            "Got it",
                            onTap: () => Navigator.pop(context),
                          ).fullWidth(),
                        ],
                      ).pack(),
                    ).p(24).h(300).wFull(),
                  ),
                ),
              ],
            ).p(16).bg(Colors.white).rounded(20).shadowMedium(),

            const SizedBox(height: 32),
            Fx.button(
              "View Full Layout Demo",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LayoutShowcase()),
              ),
            ).secondary.fullWidth(),

            const SizedBox(height: 100), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _actionButton(
    IconData icon,
    String label,
    VoidCallback onTap, {
    int? badgeCount,
  }) {
    Widget iconWidget = Fx.icon(icon, size: 28, color: const Color(0xFF2563EB));

    if (badgeCount != null && badgeCount > 0) {
      iconWidget = Fx.badge(
        child: iconWidget,
        label: badgeCount.toString(),
        color: Colors.red,
        offset: const Offset(6, -6),
      );
    }

    return Fx.box(
      onTap: onTap,
      child: Fx.column(
        children: [
          iconWidget.p(12).bg(const Color(0xFFEFF6FF)).roundedFull(),
          const SizedBox(height: 8),
          Fx.text(label).fontSize(12).semiBold().color(Colors.grey[700]!),
        ],
      ),
    ).pointer();
  }

  Widget _miniStat(String label, String value, Color col) {
    return Fx.column(
      gap: 6,
      children: [
        Fx.text(
          label,
        ).fontSize(11).color(const Color(0xFF94A3B8)).weight(FontWeight.w600),
        Fx.text(value).fontSize(17).bold().color(col),
      ],
    );
  }

  Widget _actionCircle(IconData icon, String label, Color color) {
    return Fx.column(
      gap: 10,
      children: [
        Fx.box(child: Icon(icon, color: color, size: 28))
            .size(68, 68)
            .background(Colors.white)
            .borderRadius(22)
            .shadow(color: Colors.black.withValues(alpha: 0.03), blur: 15)
            .center()
            .pointer(),
        Fx.text(label).fontSize(13).bold().color(const Color(0xFF64748B)),
      ],
    ).expand();
  }

  Widget _transactionTile(
    String title,
    String subtitle,
    double amount,
    IconData icon,
    Color col,
  ) {
    final isNegative = amount < 0;
    return Fx.box(
          child: Fx.row(
            children: [
              Fx.box(child: Icon(icon, color: col, size: 26))
                  .size(54, 54)
                  .background(col.withValues(alpha: 0.12))
                  .borderRadius(18)
                  .center(),
              const SizedBox(width: 18),
              Fx.column(
                gap: 4,
                children: [
                  Fx.text(
                    title,
                  ).fontSize(16).bold().color(const Color(0xFF0F172A)),
                  Fx.text(subtitle)
                      .fontSize(12)
                      .color(const Color(0xFF94A3B8))
                      .weight(FontWeight.w500),
                ],
              ).expand(),
              Fx.text(
                    "${isNegative ? '' : '+'}${isNegative ? '-' : ''} ₹ ${amount.abs().toStringAsFixed(2)}",
                  )
                  .fontSize(16)
                  .bold()
                  .color(
                    isNegative
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF10B981),
                  ),
            ],
          ),
        )
        .background(Colors.white)
        .borderRadius(28)
        .padding(18)
        .shadow(color: Colors.black.withValues(alpha: 0.02), blur: 10)
        .mb(12);
  }
}

class LayoutShowcase extends StatefulWidget {
  const LayoutShowcase({super.key});

  @override
  State<LayoutShowcase> createState() => _LayoutShowcaseState();
}

class _LayoutShowcaseState extends State<LayoutShowcase> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Fx.appBar(
        title: "Fluxy Layouts",
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      drawer: Fx.drawer(
        width: 280,
        child: Fx.column(
          children: [
            Fx.box()
                .h(200)
                .bg(const Color(0xFF1E293B))
                .wFull()
                .child(
                  Fx.column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Fx.icon(
                        Icons.person,
                        size: 64,
                        color: Colors.white,
                      ).p(16).bg(Colors.white24).roundedFull(),
                      const SizedBox(height: 16),
                      Fx.text(
                        "Fluxy User",
                      ).color(Colors.white).bold().fontSize(18),
                    ],
                  ),
                ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {},
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      body: splitLayout(),
      bottomNavigationBar: Fx.bottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: "Explore",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget splitLayout() {
    return Fx.row(
      children: [
        Fx.column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Fx.text("Page $_index Content").bold().fontSize(24),
            const SizedBox(height: 16),
            Fx.text("Try opening the sidebar!").color(Colors.grey),
          ],
        ).expand(),
      ],
    );
  }
}

// --- SCREEN 2: PORTFOLIO STATS ---
class PortfolioStats extends StatelessWidget {
  const PortfolioStats({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Fx.text(
              "Market Insights",
            ).fontSize(30).bold().color(const Color(0xFF0F172A)),
            const SizedBox(height: 48),

            // Dynamic Chart Card
            Fx.box(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "PORTFOLIO PERFORMANCE",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Fx.row(
                        children: [
                          Fx.text(
                            "+ ₹ 12,400.00",
                          ).fontSize(28).bold().color(const Color(0xFF10B981)),
                          const SizedBox(width: 12),
                          Fx.box(
                                child: Fx.text("↑ 14.2%")
                                    .color(const Color(0xFF10B981))
                                    .fontSize(12)
                                    .bold(),
                              )
                              .background(
                                const Color(0xFF10B981).withValues(alpha: 0.1),
                              )
                              .borderRadius(8)
                              .paddingX(8)
                              .paddingY(4),
                        ],
                      ),
                      const Spacer(),
                      Fx.row(
                        gap: 8, // Reduced from 12
                        children: [
                          _chartBar(60),
                          _chartBar(90),
                          _chartBar(70),
                          _chartBar(130),
                          _chartBar(110),
                          _chartBar(80),
                          _chartBar(120),
                          _chartBar(105),
                        ],
                      ).center(),
                    ],
                  ),
                )
                .height(280)
                .background(Colors.white)
                .borderRadius(36)
                .padding(28)
                .shadow(color: Colors.black.withValues(alpha: 0.04), blur: 30),

            const SizedBox(height: 40),

            // Reactive Signal Adjustment Control
            Fx.box(
              child: Column(
                children: [
                  Fx.text(
                    "Live Budget Control",
                  ).fontSize(18).bold().color(const Color(0xFF1E293B)),
                  const SizedBox(height: 8),
                  Fx.text(
                    "Simulate instant financial adjustments",
                  ).fontSize(13).color(const Color(0xFF64748B)),
                  const SizedBox(height: 32),
                  Fx.row(
                    gap: 24, // Reduced from 40
                    children: [
                      Fx.box(
                            onTap: () => balance.value -= 500,
                            child: const Icon(
                              Icons.remove_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          )
                          .background(const Color(0xFF1E293B))
                          .size(56, 56)
                          .borderRadius(18)
                          .shadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blur: 15,
                          )
                          .pointer(),

                      Fx.text(
                        () => "₹ ${balance.value.toInt()}",
                      ).fontSize(28).bold().color(const Color(0xFF0F172A)),

                      Fx.box(
                            onTap: () => balance.value += 500,
                            child: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          )
                          .background(const Color(0xFF6366F1))
                          .size(56, 56)
                          .borderRadius(18)
                          .shadow(
                            color: const Color(
                              0xFF6366F1,
                            ).withValues(alpha: 0.4),
                            blur: 20,
                          )
                          .pointer(),
                    ],
                  ).center(),
                ],
              ),
            ).background(const Color(0xFFF1F5F9)).borderRadius(36).padding(32),

            const SizedBox(height: 40),

            _fancyCard(
              "Mutual Fund SIP",
              Icons.trending_up_rounded,
              "Active • ₹ 5,000/mo",
              const Color(0xFF6366F1),
            ),
            const SizedBox(height: 18),
            _fancyCard(
              "Crypto Assets",
              Icons.currency_bitcoin_rounded,
              "Balanced Portfolio",
              const Color(0xFFF59E0B),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chartBar(double height) {
    return Fx.box(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AnimBar(height: height),
          ),
        )
        .height(height)
        .background(const Color(0xFF6366F1).withValues(alpha: 0.1))
        .borderRadius(8)
        .expand();
  }

  Widget _fancyCard(String title, IconData icon, String detail, Color accent) {
    return Fx.box(
          child: Fx.row(
            children: [
              Fx.box(child: Icon(icon, color: accent, size: 28))
                  .size(50, 50)
                  .background(accent.withValues(alpha: 0.1))
                  .borderRadius(16)
                  .center(),
              const SizedBox(width: 20),
              Fx.column(
                gap: 4,
                children: [
                  Fx.text(
                    title,
                  ).bold().fontSize(17).color(const Color(0xFF0F172A)),
                  Fx.text(detail)
                      .fontSize(13)
                      .color(const Color(0xFF64748B))
                      .weight(FontWeight.w500),
                ],
              ).expand(),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFCBD5E1),
                size: 30,
              ),
            ],
          ),
        )
        .background(Colors.white)
        .borderRadius(28)
        .padding(24)
        .shadow(color: Colors.black.withValues(alpha: 0.03), blur: 20);
  }
}

class AnimBar extends StatefulWidget {
  final double height;
  const AnimBar({super.key, required this.height});

  @override
  State<AnimBar> createState() => _AnimBarState();
}

class _AnimBarState extends State<AnimBar> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      curve: Curves.elasticOut,
      height: widget.height * 0.7,
      width: 30,
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1),
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFF818CF8), const Color(0xFF6366F1)],
        ),
      ),
    );
  }
}
