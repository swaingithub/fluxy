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
    'color': const Color(0xFFFF9900)
  },
  {
    'title': 'HDFC Salary Deposit',
    'subtitle': 'Monthly Payout',
    'amount': 85000.00,
    'icon': Icons.account_balance_wallet_rounded,
    'color': const Color(0xFF10B981)
  },
  {
    'title': 'Zomato UX',
    'subtitle': 'Dining & Delivery',
    'amount': -840.50,
    'icon': Icons.fastfood_rounded,
    'color': const Color(0xFFEF4444)
  },
  {
    'title': 'Netflix Premium',
    'subtitle': 'Entertainment',
    'amount': -649.00,
    'icon': Icons.play_circle_fill,
    'color': const Color(0xFFE50914)
  },
]);

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FluxyFintechApp(),
    ));

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
    return Fx.box()
        .height(100)
        .bg(Colors.white)
        .shadow(color: Colors.black.withOpacity(0.04), blur: 40)
        .child(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _navItem(Icons.grid_view_rounded, 0),
              _navItem(Icons.auto_graph_rounded, 1),
              _navItem(Icons.account_balance_wallet_rounded, 2),
              _navItem(Icons.person_rounded, 3),
            ],
          ),
        );
  }

  Widget _navItem(IconData icon, int index) {
    final active = _activePage == index;
    return GestureDetector(
      onTap: () => setState(() => _activePage = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutQuart,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF6366F1).withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(
          icon, 
          color: active ? const Color(0xFF6366F1) : const Color(0xFF94A3B8), 
          size: 26
        ),
      ),
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
                    Fx.text("Welcome back,").font(14).color(const Color(0xFF64748B)).weight(FontWeight.w500),
                    Fx.text("Alex Riviera").font(26).bold().color(const Color(0xFF0F172A)),
                  ],
                ).expanded(),
                Fx.box().size(56, 56).bg(const Color(0xFF6366F1)).radius(18).center().shadow(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  blur: 20
                ).child(
                  const Icon(Icons.person_outline_rounded, color: Colors.white, size: 28)
                ),
              ],
            ),
            const SizedBox(height: 36),

            // Main Balance Gradient Card
            Fx.box()
                .bg(const Color(0xFF1E293B))
                .radius(36)
                .pad(24) // Reduced from 32
                .shadow(color: const Color(0xFF000000).withOpacity(0.15), blur: 40)
                .child(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Fx.row(
                        children: [
                          const Text("AVAILABLE BALANCE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Color(0xFF94A3B8))),
                          const Spacer(),
                          Fx.box().size(36, 36).bg(Colors.white.withOpacity(0.1)).radius(10).center().child(
                            const Icon(Icons.nfc_rounded, color: Colors.white, size: 20)
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Fx.text(() => "₹ ${balance.value.toStringAsFixed(2)}")
                          .font(38) // Reduced from 44
                          .bold()
                          .color(Colors.white),
                      const SizedBox(height: 24),
                      Fx.row(
                        gap: 20, // Reduced from 24
                        children: [
                          _miniStat("Income", "₹ ${income.value.toInt()}", const Color(0xFF10B981)),
                          _miniStat("Expense", "₹ ${expense.value.toInt()}", const Color(0xFFEF4444)),
                        ],
                      ),
                    ],
                  ),
                ),
            
            const SizedBox(height: 36),

            // Quick Actions Grid-like row
            Fx.row(
              style: const FxStyle(justifyContent: MainAxisAlignment.spaceBetween),
              children: [
                _actionCircle(Icons.send_rounded, "Send", const Color(0xFF6366F1)),
                _actionCircle(Icons.qr_code_scanner_rounded, "Scan", const Color(0xFFF59E0B)),
                _actionCircle(Icons.account_balance_rounded, "Bank", const Color(0xFF10B981)),
                _actionCircle(Icons.more_horiz_rounded, "More", const Color(0xFF64748B)),
              ],
            ),

            const SizedBox(height: 48),

            // Transactions Header
            Fx.row(
              children: [
                Fx.text("Recent Transactions").font(20).bold().color(const Color(0xFF0F172A)).expanded(),
                Fx.text("See all").font(14).bold().color(const Color(0xFF6366F1)).pointer(),
              ],
            ),
            const SizedBox(height: 24),
            
            Fx.column(
              gap: 16,
              children: transactions.value.map((tx) => 
                _transactionTile(tx['title'], tx['subtitle'], tx['amount'], tx['icon'], tx['color'])
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value, Color col) {
    return Fx.column(
      gap: 6,
      children: [
        Fx.text(label).font(11).color(const Color(0xFF94A3B8)).weight(FontWeight.w600),
        Fx.text(value).font(17).bold().color(col),
      ],
    );
  }

  Widget _actionCircle(IconData icon, String label, Color color) {
    return Fx.column(
      gap: 10,
      children: [
        Fx.box().size(68, 68).bg(Colors.white).radius(22).shadow(color: Colors.black.withOpacity(0.03), blur: 15).center().child(
          Icon(icon, color: color, size: 28)
        ).pointer(),
        Fx.text(label).font(13).bold().color(const Color(0xFF64748B)),
      ],
    ).expanded();
  }

  Widget _transactionTile(String title, String subtitle, double amount, IconData icon, Color col) {
    final isNegative = amount < 0;
    return Fx.box()
        .bg(Colors.white)
        .radius(28)
        .pad(18)
        .shadow(color: Colors.black.withOpacity(0.02), blur: 10)
        .child(
          Fx.row(
            children: [
              Fx.box().size(54, 54).bg(col.withOpacity(0.12)).radius(18).center().child(
                Icon(icon, color: col, size: 26)
              ),
              const SizedBox(width: 18),
              Fx.column(
                gap: 4,
                children: [
                  Fx.text(title).font(16).bold().color(const Color(0xFF0F172A)),
                  Fx.text(subtitle).font(12).color(const Color(0xFF94A3B8)).weight(FontWeight.w500),
                ],
              ).expanded(),
              Fx.text("${isNegative ? '' : '+'}${isNegative ? '-' : ''} ₹ ${amount.abs().toStringAsFixed(2)}")
                  .font(16)
                  .bold()
                  .color(isNegative ? const Color(0xFF0F172A) : const Color(0xFF10B981)),
            ],
          ),
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
            Fx.text("Market Insights").font(30).bold().color(const Color(0xFF0F172A)),
            const SizedBox(height: 48),

            // Dynamic Chart Card
            Fx.box()
                .height(280)
                .bg(Colors.white)
                .radius(36)
                .pad(28)
                .shadow(color: Colors.black.withOpacity(0.04), blur: 30)
                .child(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("PORTFOLIO PERFORMANCE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Color(0xFF94A3B8))),
                      const SizedBox(height: 12),
                      Fx.row(
                        children: [
                          Fx.text("+ ₹ 12,400.00").font(28).bold().color(const Color(0xFF10B981)),
                          const SizedBox(width: 12),
                          Fx.box().bg(const Color(0xFF10B981).withOpacity(0.1)).radius(8).padX(8).padY(4).child(
                            Fx.text("↑ 14.2%").color(const Color(0xFF10B981)).font(12).bold()
                          ),
                        ],
                      ),
                      const Spacer(),
                      Fx.row(
                        gap: 8, // Reduced from 12
                        children: [
                          _chartBar(60), _chartBar(90), _chartBar(70), _chartBar(130), 
                          _chartBar(110), _chartBar(80), _chartBar(120), _chartBar(105),
                        ],
                      ).center(),
                    ],
                  ),
                ),

            const SizedBox(height: 40),

            // Reactive Signal Adjustment Control
            Fx.box()
                .bg(const Color(0xFFF1F5F9))
                .radius(36)
                .pad(32)
                .child(
                  Column(
                    children: [
                      Fx.text("Live Budget Control").font(18).bold().color(const Color(0xFF1E293B)),
                      const SizedBox(height: 8),
                      Fx.text("Simulate instant financial adjustments").font(13).color(const Color(0xFF64748B)),
                      const SizedBox(height: 32),
                      Fx.row(
                        gap: 24, // Reduced from 40
                        children: [
                          Fx.button(
                            onTap: () => balance.value -= 500,
                            child: const Icon(Icons.remove_rounded, color: Colors.white, size: 28),
                          ).bg(const Color(0xFF1E293B)).size(56, 56).radius(18).shadow(color: Colors.black.withOpacity(0.2), blur: 15),
                          
                          Fx.text(() => "₹ ${balance.value.toInt()}").font(28).bold().color(const Color(0xFF0F172A)),
                          
                          Fx.button(
                            onTap: () => balance.value += 500,
                            child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
                          ).bg(const Color(0xFF6366F1)).size(56, 56).radius(18).shadow(color: const Color(0xFF6366F1).withOpacity(0.4), blur: 20),
                        ],
                      ).center(),
                    ],
                  ),
                ),

            const SizedBox(height: 40),

            _fancyCard("Mutual Fund SIP", Icons.trending_up_rounded, "Active • ₹ 5,000/mo", const Color(0xFF6366F1)),
            const SizedBox(height: 18),
            _fancyCard("Crypto Assets", Icons.currency_bitcoin_rounded, "Balanced Portfolio", const Color(0xFFF59E0B)),
          ],
        ),
      ),
    );
  }

  Widget _chartBar(double height) {
    return Fx.box()
        .height(height)
        .bg(const Color(0xFF6366F1).withOpacity(0.1))
        .radius(8)
        .child(
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimBar(height: height),
          ),
        ).expanded();
  }

  Widget _fancyCard(String title, IconData icon, String detail, Color accent) {
    return Fx.box()
        .bg(Colors.white)
        .radius(28)
        .pad(24)
        .shadow(color: Colors.black.withOpacity(0.03), blur: 20)
        .child(
          Fx.row(
            children: [
              Fx.box().size(50, 50).bg(accent.withOpacity(0.1)).radius(16).center().child(
                Icon(icon, color: accent, size: 28)
              ),
              const SizedBox(width: 20),
              Fx.column(
                gap: 4,
                children: [
                  Fx.text(title).bold().font(17).color(const Color(0xFF0F172A)),
                  Fx.text(detail).font(13).color(const Color(0xFF64748B)).weight(FontWeight.w500),
                ],
              ).expanded(),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1), size: 30),
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
          colors: [
            const Color(0xFF818CF8),
            const Color(0xFF6366F1),
          ],
        ),
      ),
    );
  }
}
