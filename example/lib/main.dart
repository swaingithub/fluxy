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
                Fx.col(
                  gap: 4,
                  children: [
                    Fx.text("Welcome back,").font.sm().muted().semiBold(),
                    Fx.text("Alex Riviera").font.xxl().bold().primary(),
                  ],
                ).expanded(),
                Fx.avatar(
                  fallback: "AR",
                  size: FxAvatarSize.lg,
                  onTap: () => Fx.toast("Profile tapped"),
                ).shadow.md,
              ],
            ),
            const SizedBox(height: 36),

            // Main Balance Card
            Fx.box()
                .bg(const Color(0xFF1E293B))
                .rounded(32)
                .p(24)
                .shadow
                .lg
                .children([
                  Fx.row(
                    children: [
                      Fx.text("AVAILABLE BALANCE").font
                          .xs()
                          .bold()
                          .color(const Color(0xFF94A3B8))
                          .spacing(1.5),
                      const Spacer(),
                      Fx.icon(
                        Icons.nfc_rounded,
                        color: Colors.white,
                        size: 20,
                      ).p(8).bg(Colors.white.withOpacity(0.1)).rounded(10),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Fx.text(() => "₹ ${balance.value.toStringAsFixed(2)}")
                      .font
                      .xxl()
                      .bold()
                      .whiteText()
                      .animate(fade: 0, slide: const Offset(0, 10)),
                  const SizedBox(height: 24),
                  Fx.row(
                    gap: 20,
                    children: [
                      _miniStat(
                        "Income",
                        "₹ ${income.value.toInt()}",
                        FxTokens.colors.success,
                      ),
                      _miniStat(
                        "Expense",
                        "₹ ${expense.value.toInt()}",
                        FxTokens.colors.error,
                      ),
                    ],
                  ),
                ]),

            const SizedBox(height: 36),

            // Quick Actions
            Fx.row(
              justify: MainAxisAlignment.spaceBetween,
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
            ).stagger(0.1),

            const SizedBox(height: 24),
            "Add New Card".primaryBtn().wFull().shadow.md,

            const SizedBox(height: 48),

            // Transactions Header with Dropdown
            Fx.row(
              justify: MainAxisAlignment.spaceBetween,
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
              justify: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton(
                  Icons.notifications_active_outlined,
                  "Toast",
                  () => Fx.toast("Fluxy toast message!"),
                  badgeCount: 3,
                ).animate(fade: 0, scale: 0.8),
                _actionButton(
                  Icons.window_outlined,
                  "Modal",
                  () => Fx.modal(
                    context,
                    child: Fx.box()
                        .p(24)
                        .backgroundWhite()
                        .rounded(24)
                        .w(300)
                        .children([
                          Fx.col(
                            children: [
                              Fx.text("Fluxy Modal").bold().font.xl(),
                              const SizedBox(height: 12),
                              Fx.text("Declarative & Simple.").center().muted(),
                              const SizedBox(height: 24),
                              "Close"
                                  .primaryBtn(
                                    onTap: () => Navigator.pop(context),
                                  )
                                  .wFull(),
                            ],
                          ),
                        ]),
                  ),
                ).animate(fade: 0, scale: 0.8, delay: 0.1),
                _actionButton(
                  Icons.vertical_align_bottom_outlined,
                  "Sheet",
                  () => Fx.bottomSheet(
                    context,
                    child: Fx.box().p(24).h(300).wFull().children([
                      Fx.col(
                        children: [
                          Fx.box().w(40).h(4).bg(Colors.grey[300]!).circle(),
                          const SizedBox(height: 24),
                          Fx.text("Bottom Sheet").bold().font.xxl(),
                          const SizedBox(height: 12),
                          Fx.text("Swipe down to close.").muted(),
                          const SizedBox(height: 40),
                          "Got it"
                              .primaryBtn(onTap: () => Navigator.pop(context))
                              .wFull(),
                        ],
                      ),
                    ]),
                  ),
                ).animate(fade: 0, scale: 0.8, delay: 0.2),
              ],
            ).p(16).bg(Colors.white).rounded(24).shadow.sm,

            Fx.gap(32),
            "View Full Layout Demo"
                .secondaryBtn(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LayoutShowcase()),
                  ),
                )
                .wFull(),

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
    // 1. Create the base icon widget with the circular background
    Widget buttonContent = Fx.icon(icon, size: 28, color: const Color(0xFF2563EB))
        .p(12)
        .bg(const Color(0xFFEFF6FF))
        .circle();

    // 2. Add badge if needed relative to the circle
    if (badgeCount != null && badgeCount > 0) {
      buttonContent = Fx.badge(
        child: buttonContent,
        label: badgeCount.toString(),
        color: Colors.red,
        offset: const Offset(4, -4), // Adjusted for circular offset
      );
    }

    return Fx.box().onTap(onTap).children([
      buttonContent,
      const SizedBox(height: 8),
      Fx.text(label).font.xs().semiBold().muted(),
    ]);
  }

  Widget _miniStat(String label, String value, Color col) {
    return Fx.col(
      gap: 6,
      children: [
        Fx.text(label).font.xs().muted().bold(),
        Fx.text(value).font.md().bold().color(col),
      ],
    );
  }

  Widget _actionCircle(IconData icon, String label, Color color) {
    return Fx.col(
      gap: 12,
      children: [
        Fx.box()
            .size(68)
            .bg(color.withOpacity(0.1))
            .circle()
            .center()
            .child(Icon(icon, color: color, size: 28))
            .onHover((s) => s.scale(1.15).bg(color.withOpacity(0.15)))
            .transition(300.ms),
        Fx.text(label).font.sm().bold().color(const Color(0xFF1E293B)),
      ],
    ).expanded();
  }

  Widget _transactionTile(
    String title,
    String subtitle,
    double amount,
    IconData icon,
    Color col,
  ) {
    final isNegative = amount < 0;
    return Fx.box()
        .bg(Colors.white)
        .rounded(28)
        .p(18)
        .shadow
        .sm
        .mb(12)
        .child(
          Fx.row(
            children: [
              Fx.icon(
                icon,
                color: col,
                size: 26,
              ).p(14).bg(col.withOpacity(0.12)).rounded(18),
              const SizedBox(width: 18),
              Fx.col(
                gap: 4,
                children: [
                  Fx.text(title).font.md().bold().primary(),
                  Fx.text(subtitle).font.xs().muted().semiBold(),
                ],
              ).expanded(),
              Fx.text(
                "${isNegative ? '' : '+'}${isNegative ? '-' : ''} ₹ ${amount.abs().toStringAsFixed(2)}",
              ).font.md().bold().color(
                isNegative ? const Color(0xFF0F172A) : FxTokens.colors.success,
              ),
            ],
          ),
        );
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
        child: Fx.col(
          children: [
            Fx.box()
                .h(200)
                .bg(const Color(0xFF1E293B))
                .wFull()
                .center()
                .child(
                  Fx.col(
                    children: [
                      Fx.icon(
                        Icons.person,
                        size: 64,
                        color: Colors.white,
                      ).p(16).bg(Colors.white24).circle(),
                      const SizedBox(height: 16),
                      Fx.text("Fluxy User").whiteText().bold().font.xl(),
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
          justify: MainAxisAlignment.center,
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
            Fx.text("Market Insights").font.xxxl().bold().primary(),
            const SizedBox(height: 48),

            // Dynamic Chart Card
            Fx.box()
                .height(280)
                .bg(Colors.white)
                .rounded(36)
                .p(28)
                .shadow
                .sm
                .children([
                  Fx.text(
                    "PORTFOLIO PERFORMANCE",
                  ).font.xs().bold().muted().spacing(1.5),
                  const SizedBox(height: 12),
                  Fx.row(
                    children: [
                      Fx.text("+ ₹ 12,400.00").font.xl().bold().success(),
                      const SizedBox(width: 12),
                      Fx.box()
                          .bg(FxTokens.colors.success.withOpacity(0.1))
                          .rounded(8)
                          .px(8)
                          .py(4)
                          .child(Fx.text("↑ 14.2%").font.xs().bold().success()),
                    ],
                  ),
                  const Spacer(),
                  Fx.row(
                    gap: 8,
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
                ]),

            const SizedBox(height: 40),

            // Reactive Signal Adjustment Control
            Fx.box().bg(const Color(0xFFF1F5F9)).rounded(36).p(32).children([
              Fx.col(
                children: [
                  Fx.text("Live Budget Control").font.lg().bold().primary(),
                  const SizedBox(height: 8),
                  Fx.text(
                    "Simulate instant financial adjustments",
                  ).font.sm().muted(),
                  const SizedBox(height: 32),
                  Fx.row(
                    gap: 24,
                    children: [
                      Fx.box()
                          .onTap(() => balance.value -= 500)
                          .bg(const Color(0xFF1E293B))
                          .size(56)
                          .rounded(18)
                          .shadow
                          .md
                          .center()
                          .child(
                            const Icon(
                              Icons.remove_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),

                      Fx.text(
                        () => "₹ ${balance.value.toInt()}",
                      ).font.xxl().bold().primary(),

                      Fx.box()
                          .onTap(() => balance.value += 500)
                          .bg(const Color(0xFF6366F1))
                          .size(56)
                          .rounded(18)
                          .shadow
                          .md
                          .center()
                          .child(
                            const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                    ],
                  ).center(),
                ],
              ),
            ]),

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
    return Fx.box()
        .height(height)
        .bg(FxTokens.colors.primary.withOpacity(0.1))
        .rounded(8)
        .expanded()
        .child(
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimBar(height: height),
          ),
        );
  }

  Widget _fancyCard(String title, IconData icon, String detail, Color accent) {
    return Fx.box()
        .bg(Colors.white)
        .rounded(28)
        .p(24)
        .shadow
        .sm
        .child(
          Fx.row(
            children: [
              Fx.icon(
                icon,
                color: accent,
                size: 28,
              ).p(11).bg(accent.withOpacity(0.1)).rounded(16),
              const SizedBox(width: 20),
              Fx.col(
                gap: 4,
                children: [
                  Fx.text(title).font.md().bold().primary(),
                  Fx.text(detail).font.xs().muted().semiBold(),
                ],
              ).expanded(),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFCBD5E1),
                size: 30,
              ),
            ],
          ),
        );
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
