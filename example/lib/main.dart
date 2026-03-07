import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';
import 'package:fluxy_animations/fluxy_animations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Fluxy.autoRegister();
  await Fluxy.init();
  runApp(Fluxy.debug(child: const FluxyOrderHistoryApp()));
}

class FluxyOrderHistoryApp extends StatelessWidget {
  const FluxyOrderHistoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluxyApp(
      title: 'Fluxy Order History',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: const FluxyErrorBoundary(child: FluxyMainNavigation()),
    );
  }
}

// --- FLUXY REACTIVE STATE ---
final appCurrentIndex = flux(1);

final selectedTabIndex = flux(0);
final tabsList = ['All', 'Active', 'Completed', 'Cancelled'];

final allOrders = fluxList<Map<String, dynamic>>([
  {
    'orderId': '#FLX-8472',
    'date': 'Oct 24, 2026',
    'status': 'Delivered',
    'statusColor': Colors.greenAccent,
    'items': '2x Fluxy Earbuds Pro\n1x Fluxy Charger',
    'amount': '\$249.00',
    'isActive': false,
    'tab': 'Completed',
  },
  {
    'orderId': '#FLX-8473',
    'date': 'Oct 22, 2026',
    'status': 'In Transit',
    'statusColor': Colors.blueAccent,
    'items': '1x Fluxy Smart Watch',
    'amount': '\$199.50',
    'isActive': true,
    'tab': 'Active',
  },
  {
    'orderId': '#FLX-8411',
    'date': 'Oct 15, 2026',
    'status': 'Cancelled',
    'statusColor': Colors.redAccent,
    'items': '1x Fluxy Phone Case',
    'amount': '\$29.99',
    'isActive': false,
    'tab': 'Cancelled',
  },
]);

final GlobalKey<ScaffoldState> fluxyAppScaffoldKey = GlobalKey<ScaffoldState>();

class FluxyMainNavigation extends StatelessWidget {
  const FluxyMainNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Fx(() {
      final isDark = FxTheme.isDarkMode;

      final body = IndexedStack(
        index: appCurrentIndex.value,
        children: const [
          ECommerceShopPage(),
          OrderHistoryPage(),
          CartAndCheckoutPage(),
          UserProfilePage(),
          MotionShowcasePage(),
        ],
      );

      final navbar = Theme(
        // Ensure correct theme context for native fallback
        data: isDark ? ThemeData.dark() : ThemeData.light(),
        child: FxBottomBar(
          currentIndex: appCurrentIndex.value,
          onTap: (i) => appCurrentIndex.value = i,
          activeColor: Fx.primary,
          baseColor: isDark ? Colors.white54 : Colors.black45,
          containerStyle: FxStyle(
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            shadows: isDark
                ? [
                    BoxShadow(
                      color: Fx.primary.withValues(alpha: 0.15),
                      blurRadius: 30,
                      offset: const Offset(0, -5),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Fx.primary.withValues(alpha: 0.1),
                      blurRadius: 40,
                      offset: const Offset(0, -10),
                    ),
                  ],
          ),
          items: const [
            FxBottomBarItem(icon: Icons.storefront_rounded, label: 'Shop'),
            FxBottomBarItem(icon: Icons.receipt_long_rounded, label: 'Orders'),
            FxBottomBarItem(icon: Icons.shopping_bag_rounded, label: 'Cart'),
            FxBottomBarItem(icon: Icons.person_rounded, label: 'Profile'),
            FxBottomBarItem(icon: Icons.auto_awesome_rounded, label: 'Motion'),
          ],
        ),
      );

      final sidebar = FxSidebar(
        style: FxStyle(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        ),
        header: Fx.col(
          gap: 20,
          alignItems: CrossAxisAlignment.start,
          style: const FxStyle(
            padding: EdgeInsets.only(left: 16, right: 16, top: 32, bottom: 16),
          ),
          children: [
            Fx.row(
              gap: 12,
              alignItems: CrossAxisAlignment.center,
              children: [
                Fx.box(
                  style: FxStyle(
                    backgroundColor: Fx.primary.withValues(alpha: 0.15),
                    padding: const EdgeInsets.all(12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Fx.icon(
                    Icons.bubble_chart_rounded,
                    color: Fx.primary,
                    size: 32,
                  ),
                ),
                Fx.col(
                  alignItems: CrossAxisAlignment.start,
                  children: [
                    Fx.text('Fluxy UI').style(
                      FxStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Fx.text('v2.0.0 Pro').style(
                      FxStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Fx.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            // User profile mini
            Fx.box(
              style: FxStyle(
                backgroundColor: isDark
                    ? const Color(0xFF334155)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                padding: const EdgeInsets.all(12),
              ),
              child: Fx.row(
                gap: 12,
                children: [
                  const FxAvatar(
                    image: 'https://i.pravatar.cc/150?img=11',
                    fallback: 'JS',
                    size: FxAvatarSize.md,
                  ),
                  Expanded(
                    child: Fx.col(
                      alignItems: CrossAxisAlignment.start,
                      children: [
                        Fx.text('Jane Smith').style(
                          FxStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Fx.text('Pro Member').style(
                          FxStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Fx.icon(
                    Icons.unfold_more_rounded,
                    color: isDark ? Colors.white54 : Colors.black54,
                    size: 18,
                  ),
                ],
              ),
            ),
          ],
        ),
        currentIndex: appCurrentIndex.value,
        onTap: (index) {
          if (index < 4) {
            appCurrentIndex.value = index;
          } else {
            Fx.toast.info('Feature unavailable');
          }
        },
        items: [
          const FxSidebarItem(icon: Icons.storefront_rounded, label: 'Shop Explore'),
          FxSidebarItem(
              icon: Icons.receipt_long_rounded, 
              label: 'Order History',
              trailing: FxPulsar(
                child: Fx.box(
                  style: FxStyle(
                    backgroundColor: Fx.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Fx.text('3').style(const FxStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
          ),
          const FxSidebarItem(icon: Icons.shopping_bag_rounded, label: 'My Cart'),
          const FxSidebarItem(icon: Icons.person_rounded, label: 'Profile'),
          const FxSidebarItem(icon: Icons.auto_awesome_rounded, label: 'Motion'),
          const FxSidebarItem(label: 'Preferences', isHeader: true),
          const FxSidebarItem(icon: Icons.settings_suggest_rounded, label: 'Advanced Settings'),
        ],
        footer: Fx.col(
          gap: 16,
          style: const FxStyle(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          ),
          children: [
            Fx.box(
              style: FxStyle(
                padding: const EdgeInsets.all(16),
                borderRadius: BorderRadius.circular(16),
                backgroundColor: isDark
                    ? Fx.primary.withValues(alpha: 0.1)
                    : Fx.primary.withValues(alpha: 0.05),
                border: Border.all(color: Fx.primary.withValues(alpha: 0.2)),
              ),
              child: Fx.col(
                gap: 12,
                alignItems: CrossAxisAlignment.start,
                children: [
                  Fx.icon(Icons.auto_awesome_rounded, color: Fx.primary),
                  Fx.text(
                    'Unlock Premium features & advanced analytics.',
                  ).style(
                    FxStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  FxBoing(
                    onTap: () {
                      Fx.toast.info('Upgrading to Pro...');
                    },
                    child: Fx.box(
                      style: FxStyle(
                        backgroundColor: Fx.primary,
                        borderRadius: BorderRadius.circular(8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        width: double.infinity,
                        alignment: Alignment.center,
                      ),
                      child: Fx.text('Upgrade Now').style(
                        const FxStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Fx.toast.info('Logged out');
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Icon(Icons.exit_to_app_rounded, color: isDark ? Colors.white70 : Colors.black87),
                      const SizedBox(width: 14),
                      Text(
                        'Log Out', 
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );

      // Demonstrating standalone Sidebar execution without specialized widgets.
      // Utilize Fx.layout to decide structural positioning manually.
      return Fx.layout(
        mobile: Scaffold(
          key: fluxyAppScaffoldKey,
          drawer: Drawer(child: sidebar),
          body: Fx.page(
            // Fx.page acts as a container for our view to hook in the bottom nav bar correctly
            bottomNavigationBar: navbar,
            child: body,
          ),
        ),
        desktop: Scaffold(
          key: fluxyAppScaffoldKey,
          body: Fx.row(
            children: [
               sidebar,
               Expanded(
                 child: Fx.page(
                   bottomNavigationBar: navbar,
                 child: body,
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Fx(() {
      final isDark = FxTheme.isDarkMode;

      return Fx.safe(
        Scaffold(
          backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Fx.text('Order History').style(
              FxStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            centerTitle: false,
            actions: [
              GestureDetector(
                onTap: () {
                  FxTheme.toggle();
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Fx.icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: isDark ? Colors.amber : Colors.indigo,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: FxAvatar(
                  image: 'https://i.pravatar.cc/150?img=11',
                  fallback: 'U',
                  size: FxAvatarSize.sm,
                ),
              )
            ],
          ),
          body: Fx.col(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Native Fluxy Tab Bar (Switches index signal)
              FxTabBar(currentIndex: selectedTabIndex, tabs: tabsList),

              Divider(
                color: isDark ? Colors.white12 : Colors.black12,
                height: 1,
              ),

              // Native Fluxy Tab View (Responds to index signal and gestures)
              Expanded(
                child: FxTabView(
                  currentIndex: selectedTabIndex,
                  children: [
                    _buildTabContent('All'),
                    _buildTabContent('Active'),
                    _buildTabContent('Completed'),
                    _buildTabContent('Cancelled'),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTabContent(String tabName) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Fx(() {
        final filteredOrders = allOrders.where((order) {
          if (tabName == 'All') return true;
          return order['tab'] == tabName;
        }).toList();

        final isDark = FxTheme.isDarkMode;

        if (filteredOrders.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Fx.text(
                'No ${tabName.toLowerCase()} orders found.',
              ).style(FxStyle(color: isDark ? Colors.white54 : Colors.black54)),
            ),
          );
        }

        return FxStaggeredReveal(
          interval: const Duration(milliseconds: 100),
          children: filteredOrders.map((order) {
            return FxEntrance(
              delay: Duration(milliseconds: (filteredOrders.indexOf(order) * 50)),
              slideOffset: const Offset(0, 40),
              child: _buildOrderCard(
                orderId: order['orderId'],
                date: order['date'],
                status: order['status'],
                statusColor: order['statusColor'],
                items: order['items'],
                amount: order['amount'],
                isActive: order['isActive'],
                isDark: isDark,
              ),
            );
          }).toList(),
        );
      }),
    );
  }

  Widget _buildOrderCard({
    required String orderId,
    required String date,
    required String status,
    required Color statusColor,
    required String items,
    required String amount,
    required bool isActive,
    required bool isDark,
  }) {
    return Fx.box(
      style: FxStyle(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        padding: const EdgeInsets.all(20),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
        shadows: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Fx.col(
        gap: 16,
        alignItems: CrossAxisAlignment.start,
        children: [
          // Header: Order ID & Status
          Fx.row(
            justify: MainAxisAlignment.spaceBetween,
            alignItems: CrossAxisAlignment.center,
            children: [
              Fx.col(
                alignItems: CrossAxisAlignment.start,
                gap: 4,
                children: [
                  Fx.text(orderId).style(
                    FxStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Fx.text(date).style(
                    FxStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
              Fx.box(
                style: FxStyle(
                  backgroundColor: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                ),
                child: Fx.text(status).style(
                  FxStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          
          Divider(color: isDark ? Colors.white12 : Colors.black12, height: 1),

          // Items & Amount
          Fx.row(
            justify: MainAxisAlignment.spaceBetween,
            alignItems: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Fx.text(items).style(
                  FxStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
              Fx.text(amount).style(
                FxStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          
          // Actions
          Fx.row(
            gap: 12,
            children: [
              Expanded(
                child: Fx.outlineButton(
                  'Remove',
                  onTap: () {
                    // Reactive mutation
                    allOrders.removeWhere(
                      (o) => o['orderId'] == orderId,
                    ); // removes and if using removeWhere natively it works, but let's batch manually to notify
                    // Or safely via internal remove matching:
                    final toRemove = allOrders.firstWhere(
                      (o) => o['orderId'] == orderId,
                    );
                    allOrders.remove(toRemove);
                    Fx.toast.info('Removed $orderId');
                  },
                ),
              ),
              if (isActive)
                Expanded(
                  child: Fx.primaryButton(
                    'Cancel Order', // Update to show reactive change
                    onTap: () {
                      // Uses fluxList's reactive updater
                      allOrders.updateWhere(
                        (item) => item['orderId'] == orderId,
                        (current) => {
                          ...current,
                          'status': 'Cancelled',
                          'statusColor': Colors.redAccent,
                          'tab': 'Cancelled',
                          'isActive': false,
                        },
                      );
                      Fx.toast.success('Cancelled $orderId');
                    },
                  ),
                )
              else if (status != 'Cancelled')
                Expanded(
                  child: Fx.secondaryButton(
                    'Reorder',
                    onTap: () {
                      Fx.toast.success(
                        'Successfully Reordered items from $orderId',
                      );
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Fx(() {
      final isDark = FxTheme.isDarkMode;

      return Fx.safe(
        Scaffold(
          backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Fx.text('Profile').style(
              FxStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            centerTitle: false,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Fx.icon(
                  Icons.settings_rounded,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Fx.col(
              gap: 24,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Header
                Fx.col(
                  gap: 12,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FxAvatar(
                      image: 'https://i.pravatar.cc/150?img=11',
                      fallback: 'JS',
                      size: FxAvatarSize.xl,
                    ),
                    Fx.text('Jane Smith').style(
                      FxStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Fx.text('jane.smith@fluxyui.com').style(
                      FxStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Settings Card
                Fx.box(
                  style: FxStyle(
                    backgroundColor: isDark
                        ? const Color(0xFF1E293B)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                    shadows: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Fx.col(
                    children: [
                      _buildSettingsTile(
                        icon: Icons.person_outline_rounded,
                        title: 'Personal Information',
                        isDark: isDark,
                      ),
                      Divider(
                        color: isDark ? Colors.white12 : Colors.black12,
                        height: 1,
                      ),
                      _buildSettingsTile(
                        icon: Icons.shield_outlined,
                        title: 'Privacy & Security',
                        isDark: isDark,
                      ),
                      Divider(
                        color: isDark ? Colors.white12 : Colors.black12,
                        height: 1,
                      ),
                      _buildSettingsTile(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notifications',
                        isDark: isDark,
                      ),
                      Divider(
                        color: isDark ? Colors.white12 : Colors.black12,
                        height: 1,
                      ),
                      GestureDetector(
                        onTap: () {
                          FxTheme.toggle();
                        },
                        child: _buildSettingsTile(
                          icon: isDark
                              ? Icons.light_mode_outlined
                              : Icons.dark_mode_outlined,
                          title: 'Toggle Theme',
                          isDark: isDark,
                          showArrow: false,
                        ),
                      ),
                    ],
                  ),
                ),

                // Logout Button
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: Fx.outlineButton(
                    'Log Out',
                    onTap: () {
                      Fx.toast.info('Logged out successfully');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required bool isDark,
    bool showArrow = true,
  }) {
    return Fx.box(
      style: const FxStyle(padding: EdgeInsets.all(16)),
      child: Fx.row(
        justify: MainAxisAlignment.spaceBetween,
        children: [
          Fx.row(
            gap: 16,
            children: [
              Fx.icon(icon, color: isDark ? Colors.white70 : Colors.black54),
              Fx.text(title).style(
                FxStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          if (showArrow)
            Fx.icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.white30 : Colors.black38,
            ),
        ],
      ),
    );
  }
}

class ECommerceShopPage extends StatelessWidget {
  const ECommerceShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Fx(() {
      final isDark = FxTheme.isDarkMode;
      
      return Fx.safe(
        Scaffold(
          backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
          appBar: _buildAppBar(isDark),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Fx.col(
              gap: 24,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search Bar
                FxTextField(
                  signal: flux(''),
                  placeholder: 'Search for products...',
                  icon: Icons.search_rounded,
                  style: FxStyle(
                    backgroundColor: isDark
                        ? const Color(0xFF1E293B)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                    shadows: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                ),

                // Categories (Horizontal Scroll)
                Fx.col(
                  gap: 12,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Fx.row(
                      justify: MainAxisAlignment.spaceBetween,
                      children: [
                        Fx.text('Categories').style(
                          FxStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Fx.text('View All').style(
                          FxStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Fx.primary,
                          ),
                        ),
                      ],
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Fx.row(
                        gap: 12,
                        children: [
                          _buildCategoryChip('All', true, isDark),
                          _buildCategoryChip('Electronics', false, isDark),
                          _buildCategoryChip('Wearables', false, isDark),
                          _buildCategoryChip('Audio', false, isDark),
                          _buildCategoryChip('Accessories', false, isDark),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Popular Products Row 1
                Fx.row(
                  gap: 16,
                  children: [
                    Expanded(
                      child: _buildProductCard(
                        'Fluxy Earbuds Pro',
                        '\$199.00',
                        'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=400&q=80',
                        isDark,
                      ),
                    ),
                    Expanded(
                      child: _buildProductCard(
                        'Smart Watch Elite',
                        '\$299.00',
                        'https://images.unsplash.com/photo-1546868871-7041f2a55e12?w=400&q=80',
                        isDark,
                      ),
                    ),
                  ],
                ),

                // Popular Products Row 2
                Fx.row(
                  gap: 16,
                  children: [
                    Expanded(
                      child: _buildProductCard(
                        'Magnetic Charger',
                        '\$49.00',
                        'https://images.unsplash.com/photo-1585338107529-13afc5f02586?w=400&q=80',
                        isDark,
                      ),
                    ),
                    Expanded(
                      child: _buildProductCard(
                        'Mechanical Keyboard',
                        '\$129.00',
                        'https://images.unsplash.com/photo-1595225476474-87563907a212?w=400&q=80',
                        isDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Fx.icon(
          Icons.menu_rounded,
          color: isDark ? Colors.white : Colors.black87,
        ),
        onPressed: () {
          // Open the root drawer guaranteed via the global key
          fluxyAppScaffoldKey.currentState?.openDrawer();
        },
      ),
      title: Fx.text('Fluxy Store').style(
        FxStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      centerTitle: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: FxBadge(
            color: Colors.redAccent,
            label: '3',
            offset: const Offset(4, 4),
            child: Fx.icon(
              Icons.shopping_bag_outlined,
              color: isDark ? Fx.primary : Colors.indigo,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: FxAvatar(
            image: 'https://i.pravatar.cc/150?img=11',
            fallback: 'JS',
            size: FxAvatarSize.sm,
          ),
        )
      ],
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected, bool isDark) {
    return Fx.box(
      style: FxStyle(
        backgroundColor: isSelected
            ? Fx.primary
            : (isDark
                  ? const Color(0xFF1E293B)
                  : Fx.primary.withValues(alpha: 0.05)),
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        border: Border.all(
          color: isSelected
              ? Fx.primary
              : (isDark ? Colors.white12 : Fx.primary.withValues(alpha: 0.15)),
        ),
      ),
      child: Fx.text(label).style(
        FxStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          color: isSelected
              ? Colors.white
              : (isDark ? Colors.white70 : Fx.primary),
        )
      ),
    );
  }

  Widget _buildProductCard(
    String title,
    String price,
    String imgUrl,
    bool isDark,
  ) {
    return Fx.box(
      style: FxStyle(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Fx.primary.withValues(alpha: 0.1),
        ),
        shadows: isDark
            ? []
            : [
                BoxShadow(
                  color: Fx.primary.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Fx.col(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Product Image area
          Box(
            style: FxStyle(
              height: 140,
              backgroundColor: isDark ? Colors.black26 : Colors.grey[100],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
            ),
            child: Image.network(
              imgUrl,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) =>
                  Center(child: Fx.icon(Icons.image_not_supported_outlined)),
            ),
          ),
          
          // Product Details
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Fx.col(
              gap: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Fx.text(title).style(
                  FxStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Fx.text(price).style(
                  FxStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Fx.primary,
                  ),
                ),

                const SizedBox(height: 4),
                // Add to Cart Button
                SizedBox(
                  width: double.infinity,
                  child: Fx.primaryButton(
                    'Add',
                    onTap: () {
                      Fx.toast.success('Added $title to cart!');
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Simple state for the checkout form
final promoCodeSignal = flux('');
final saveCardSignal = flux(true);

class CartAndCheckoutPage extends StatelessWidget {
  const CartAndCheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Fx(() {
      final isDark = FxTheme.isDarkMode;

      return Fx.safe(
        Scaffold(
          backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Fx.text('Checkout').style(
              FxStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            centerTitle: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Fx.col(
              gap: 24,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Order Summary Card
                Fx.box(
                  style: FxStyle(
                    backgroundColor: isDark
                        ? const Color(0xFF1E293B)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    padding: const EdgeInsets.all(20),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                    shadows: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Fx.col(
                    gap: 16,
                    children: [
                      Fx.text('Order Summary').style(
                        FxStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      _buildCartItem('Fluxy Earbuds Pro', '\$199.00', isDark),
                      _buildCartItem('Magnetic Charger', '\$49.00', isDark),
                      Divider(
                        color: isDark ? Colors.white12 : Colors.black12,
                        height: 1,
                      ),
                      Fx.row(
                        justify: MainAxisAlignment.spaceBetween,
                        children: [
                          Fx.text('Total').style(
                            FxStyle(
                              fontSize: 16,
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                          ),
                          Fx.text('\$248.00').style(
                            FxStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Fx.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Payment Info
                Fx.text('Payment Information').style(
                  FxStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Fx.box(
                  style: FxStyle(
                    backgroundColor: isDark
                        ? const Color(0xFF1E293B)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    padding: const EdgeInsets.all(20),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                  ),
                  child: Fx.col(
                    gap: 16,
                    children: [
                      // Using Fluxy's Reactive inputs!
                      FxTextField(
                        signal: flux(''), // placeholder signal
                        label: 'Card Number',
                        placeholder: '0000 0000 0000 0000',
                        icon: Icons.credit_card_rounded,
                        keyboardType: TextInputType.number,
                        style: FxStyle(
                          backgroundColor: isDark
                              ? const Color(0xFF0F172A)
                              : Colors.grey[50]!,
                          borderRadius: BorderRadius.circular(12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          border: Border.all(
                            color: isDark ? Colors.white12 : Colors.black12,
                          ),
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Fx.row(
                        gap: 16,
                        children: [
                          Expanded(
                            child: FxTextField(
                              signal: flux(''),
                              label: 'Expiry',
                              placeholder: 'MM/YY',
                              style: FxStyle(
                                backgroundColor: isDark
                                    ? const Color(0xFF0F172A)
                                    : Colors.grey[50]!,
                                borderRadius: BorderRadius.circular(12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white12
                                      : Colors.black12,
                                ),
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          Expanded(
                            child: FxTextField(
                              signal: flux(''),
                              label: 'CVC',
                              placeholder: '123',
                              obscureText: true,
                              keyboardType: TextInputType.number,
                              style: FxStyle(
                                backgroundColor: isDark
                                    ? const Color(0xFF0F172A)
                                    : Colors.grey[50]!,
                                borderRadius: BorderRadius.circular(12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white12
                                      : Colors.black12,
                                ),
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      // Reactive Checkbox
                      Fx.row(
                        gap: 12,
                        children: [
                          FxCheckbox(
                            signal: saveCardSignal,
                            activeColor: Fx.primary,
                          ),
                          Fx.text('Save card information later').style(
                            FxStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Promo code
                Fx.row(
                  gap: 12,
                  children: [
                    Expanded(
                      child: FxTextField(
                        signal: promoCodeSignal,
                        placeholder: 'Enter Promo Code',
                        style: FxStyle(
                          backgroundColor: isDark
                              ? const Color(0xFF1E293B)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          border: Border.all(
                            color: isDark ? Colors.white12 : Colors.black12,
                          ),
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    Fx.outlineButton(
                      'Apply',
                      onTap: () {
                        if (promoCodeSignal.value.isNotEmpty) {
                          Fx.toast.success('Promo code applied!');
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Checkout large button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: Fx.primaryButton(
                    'Pay \$248.00',
                    onTap: () {
                      Fx.loader.show();
                      // Simulate network request
                      Future.delayed(const Duration(seconds: 2), () {
                        Fx.loader.hide();
                        Fx.toast.success('Payment successful!');
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildCartItem(String name, String price, bool isDark) {
    return Fx.row(
      justify: MainAxisAlignment.spaceBetween,
      children: [
        Fx.text(name).style(
          FxStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        Fx.text(price).style(
          FxStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }
}

class MotionShowcasePage extends StatelessWidget {
  const MotionShowcasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Fx(() {
      final isDark = FxTheme.isDarkMode;

      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Fx.text('Motion Lab').style(
            FxStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Fx.col(
            gap: 32,
            children: [
              // 1. MAGNETIC PHYSICS
              _buildSection(
                title: "Magnetic Physics",
                description: "Interactive widgets that stick to your touch and snap back with elite spring physics.",
                isDark: isDark,
                child: Center(
                  child: FxMagnetic(
                    reach: 120,
                    intensity: 0.5,
                    child: Fx.box(
                      style: FxStyle(
                        width: 200,
                        padding: const EdgeInsets.all(24),
                        backgroundColor: Fx.primary,
                        borderRadius: BorderRadius.circular(20),
                        shadows: [
                          BoxShadow(
                            color: Fx.primary.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: Fx.col(
                        gap: 8,
                        children: [
                          const Icon(Icons.touch_app, color: Colors.white, size: 32),
                          Fx.text("Touch Me").style(const FxStyle(color: Colors.white, fontWeight: FontWeight.bold)).center(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 2. CHOREOGRAPHY
              _buildSection(
                title: "Timeline Choreography",
                description: "Chained animations (Scale -> Rotate -> Pulse) without nesting boilerplate.",
                isDark: isDark,
                child: Center(
                  child: FxChoreography(
                    repeat: true,
                    steps: [
                      FxStep(
                        duration: const Duration(milliseconds: 600),
                        scale: Tween(begin: 1.0, end: 1.4),
                        curve: Curves.elasticOut,
                      ),
                      FxStep(
                        duration: const Duration(milliseconds: 400),
                        rotate: Tween(begin: 0.0, end: 3.14 / 4), // 45 deg
                        curve: Curves.easeInOutBack,
                      ),
                      FxStep(
                        duration: const Duration(milliseconds: 600),
                        fade: Tween(begin: 1.0, end: 0.5),
                        scale: Tween(begin: 1.4, end: 1.0),
                      ),
                      FxStep(
                        duration: const Duration(milliseconds: 400),
                        fade: Tween(begin: 0.5, end: 1.0),
                        rotate: Tween(begin: 3.14 / 4, end: 0.0),
                      ),
                    ],
                    child: Fx.box(
                      style: FxStyle(
                        width: 80,
                        height: 80,
                        backgroundColor: Colors.amber,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 40),
                    ),
                  ),
                ),
              ),

              // 3. LIQUID SHIMMER
              _buildSection(
                title: "Liquid Shimmer",
                description: "Elite shader-based loading states that feel smooth and organic.",
                isDark: isDark,
                child: FxLiquidShimmer(
                  child: Fx.col(
                    gap: 16,
                    children: [
                      Fx.row(
                        gap: 12,
                        children: [
                          Fx.box(style: FxStyle(width: 50, height: 50, borderRadius: BorderRadius.circular(25), backgroundColor: isDark ? Colors.white10 : Colors.black12)),
                          Expanded(
                            child: Fx.col(
                              gap: 8,
                              children: [
                                Fx.box(style: FxStyle(height: 12, borderRadius: BorderRadius.circular(6), backgroundColor: isDark ? Colors.white10 : Colors.black12)),
                                Fx.box(style: FxStyle(width: 100, height: 12, borderRadius: BorderRadius.circular(6), backgroundColor: isDark ? Colors.white10 : Colors.black12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 4. 3D PERSPECTIVE Tilt
              _buildSection(
                title: "3D Perspective Tilt",
                description: "Cards that tilt and rotate in 3D space based on your touch location.",
                isDark: isDark,
                child: Center(
                  child: FxPerspective(
                    intensity: 0.3,
                    child: Fx.box(
                      style: FxStyle(
                        width: 200,
                        height: 120,
                        backgroundColor: isDark ? Colors.indigo[900]! : Colors.indigo[50]!,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.indigo.withOpacity(0.3)),
                        alignment: Alignment.center,
                      ),
                      child: Fx.col(
                        gap: 8,
                        children: [
                          Icon(Icons.layers_rounded, color: isDark ? Colors.indigo[200] : Colors.indigo[800], size: 32),
                          Fx.text("3D Perspective").style(FxStyle(color: isDark ? Colors.indigo[200] : Colors.indigo[800], fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 5. ELASTIC JELLY
              _buildSection(
                title: "Elastic Jelly Wobble",
                description: "Physical distortion that makes widgets feel like they are made of jelly.",
                isDark: isDark,
                child: Center(
                  child: FxJelly(
                    child: Fx.box(
                      style: FxStyle(
                        width: 100,
                        height: 100,
                        backgroundColor: Colors.pink,
                        borderRadius: BorderRadius.circular(50),
                        alignment: Alignment.center,
                      ),
                      child: const Icon(Icons.favorite, color: Colors.white, size: 40),
                    ),
                  ),
                ),
              ),

              // 6. ORGANIC WAVE FILL
              _buildSection(
                title: "Organic Wave Fill",
                description: "Realistic liquid dynamics for progress and loading states.",
                isDark: isDark,
                child: Center(
                  child: Fx.box(
                    style: FxStyle(
                      width: 120,
                      height: 120,
                      borderRadius: BorderRadius.circular(60),
                      border: Border.all(color: Fx.primary, width: 3),
                      backgroundColor: Colors.transparent,
                      clipBehavior: Clip.antiAlias,
                    ),
                    child: FxWave(
                      progress: 0.6,
                      color: Fx.primary.withOpacity(0.5),
                      waveHeight: 6,
                      child: Center(
                        child: Fx.text("60%").style(FxStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                      ),
                    ),
                  ),
                ),
              ),

              // 7. METABALL LIQUID BUTTON
              _buildSection(
                title: "Metaball Liquid Button",
                description: "Morphing geometry that makes buttons feel like splitting liquid drops.",
                isDark: isDark,
                child: Center(
                  child: FxLiquidButton(
                    child: Fx.box(
                      style: FxStyle(
                        width: 160,
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Fx.primary,
                        borderRadius: BorderRadius.circular(30),
                        alignment: Alignment.center,
                      ),
                      child: Fx.text("Launch").style(const FxStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
              // 8. INTERACTIVE SPOTLIGHT
              _buildSection(
                title: "Interactive Spotlight",
                description: "A movie-screen reveal effect that follows the cursor.",
                isDark: isDark,
                child: FxSpotlight(
                  radius: 100,
                  overlayColor: isDark ? Colors.black : Colors.black87,
                  child: Fx.box(
                    style: const FxStyle(height: 150, alignment: Alignment.center),
                    child: Fx.text("TOP SECRET REVEAL").style(const FxStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
                  ),
                ),
              ),

              // 9. LIQUID GOOEY MERGE
              _buildSection(
                title: "Gooey Liquid Merge",
                description: "Objects that physically 'melt' into each other using metaball filters.",
                isDark: isDark,
                child: Center(
                  child: FxGooey(
                    intensity: 25,
                    children: [
                      // Moving Blobs
                      _AnimatedBlob(color: Fx.primary, offset: const Offset(-25, 0)),
                      _AnimatedBlob(color: Colors.purple, offset: const Offset(25, 0)),
                      _AnimatedBlob(color: Colors.blue, offset: const Offset(0, 0)),
                    ],
                  ),
                ),
              ),

              // 10. ORGANIC CONFETTI
              _buildSection(
                title: "Organic Confetti",
                description: "High-performance celebratory particles. Tap to celebrate!",
                isDark: isDark,
                child: Center(
                  child: FxConfetti(
                    count: 40,
                    child: Fx.box(
                      style: FxStyle(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        backgroundColor: Colors.amber,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Fx.text("TAP TO WIN!").style(const FxStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),

              // 11. MESH GRADIENT (ULTRA-MODERN)
              _buildSection(
                title: "Mesh Gradient",
                description: "Fluid, organic background movement. The hallmark of elite 2024 design.",
                isDark: isDark,
                child: Fx.box(
                  style: FxStyle(
                    height: 200,
                    borderRadius: BorderRadius.circular(24),
                    clipBehavior: Clip.antiAlias,
                  ),
                  child: Stack(
                    children: [
                      const FxMeshGradient(
                        colors: [Colors.blue, Colors.purple, Colors.pink, Colors.orange],
                        speed: 0.5,
                      ),
                      Center(
                        child: Fx.text("FLUID MOTION").style(const FxStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          shadows: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                        )),
                      ),
                    ],
                  ),
                ),
              ),

              // 12. ANIMATED GLOW BORDER
              _buildSection(
                title: "Animated Glow Border",
                description: "A premium light trail that travels around the perimeter of any widget.",
                isDark: isDark,
                child: Center(
                  child: FxAnimatedBorder(
                    color: Fx.primary,
                    width: 3,
                    borderRadius: 24,
                    child: Fx.box(
                      style: FxStyle(
                        width: 250,
                        padding: const EdgeInsets.all(24),
                        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Fx.col(
                        gap: 8,
                        children: [
                          Fx.text("Premium Card").style(const FxStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          Fx.text("Notice the glowing light traveling along the edge.").style(const FxStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSection({required String title, required String description, required Widget child, required bool isDark}) {
    return Fx.col(
      gap: 16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Fx.col(
          gap: 4,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Fx.text(title).style(FxStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
            Fx.text(description).style(FxStyle(fontSize: 14, color: isDark ? Colors.white54 : Colors.black54)),
          ],
        ),
        Fx.box(
          style: FxStyle(
            padding: const EdgeInsets.all(32),
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _AnimatedBlob extends StatefulWidget {
  final Color color;
  final Offset offset;

  const _AnimatedBlob({required this.color, required this.offset});

  @override
  State<_AnimatedBlob> createState() => _AnimatedBlobState();
}

class _AnimatedBlobState extends State<_AnimatedBlob> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double dist = 30 * math.sin(_controller.value * 2 * math.pi);
        return Transform.translate(
          offset: widget.offset + Offset(dist, dist * 0.5),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
