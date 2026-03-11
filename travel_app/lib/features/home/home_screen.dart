import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';
import 'package:fluxy_animations/fluxy_animations.dart';
import '../../core/app_data.dart' as data;
import 'home_controller.dart';
import 'widgets/destination_card.dart';
import '../saved/saved_page.dart';
import '../tickets/tickets_page.dart';
import '../profile/profile_page.dart';

class TravelMainNavigation extends StatelessWidget {
  const TravelMainNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.find<HomeController>();

    return Fx(() {
      final body = IndexedStack(
        index: controller.navIndex.value,
        children: [
          const DiscoverPage(),
          const SavedPage(),
          const TicketsPage(),
          const ProfilePage(),
        ],
      );

      final navbar = FxBottomBar(
        currentIndex: controller.navIndex.value,
        onTap: (i) => controller.setNavIndex(i),
        activeColor: const Color(0xFF6366F1),
        items: const [
          FxBottomBarItem(icon: Icons.explore_rounded, label: 'Explore'),
          FxBottomBarItem(icon: Icons.favorite_rounded, label: 'Saved'),
          FxBottomBarItem(icon: Icons.confirmation_number_rounded, label: 'Tickets'),
          FxBottomBarItem(icon: Icons.person_rounded, label: 'Settings'),
        ],
      );

      // Map navIndex to Sidebar highlighted index
      final sidebarIndex = controller.navIndex.value >= 3 
          ? 5 // Profile Settings is index 5 in sidebar
          : controller.navIndex.value;

      final sidebar = FxSidebar(
        header: Fx.col(
          gap: 16,
          alignItems: CrossAxisAlignment.start,
          children: [
            Fx.text('ELITE').bold().fontSize(24).color(FxTheme.isDarkMode ? Colors.white : const Color(0xFF0F172A)).spacing(4),
            Fx.text('TRAVEL').bold().fontSize(12).color(const Color(0xFF6366F1)).spacing(2),
          ],
        ).p(24),
        backgroundColor: FxTheme.isDarkMode ? const Color(0xFF0F172A) : Colors.white,
        activeColor: const Color(0xFF6366F1),
        baseColor: FxTheme.isDarkMode ? Colors.white70 : Colors.black54,
        currentIndex: sidebarIndex,
        onTap: (i) {
          if (i == 0) controller.setNavIndex(0);
          if (i == 1) controller.setNavIndex(1);
          if (i == 2) controller.setNavIndex(2);
          if (i == 5) controller.setNavIndex(3);
          
          // Auto-close drawer on mobile
          final scaffold = Scaffold.maybeOf(context);
          if (scaffold?.isDrawerOpen ?? false) {
            Navigator.pop(context);
          }
        },
        items: [
          const FxSidebarItem(icon: Icons.explore_rounded, label: 'Discover'),
          const FxSidebarItem(icon: Icons.favorite_rounded, label: 'Saved Trips'),
          const FxSidebarItem(icon: Icons.confirmation_number_rounded, label: 'My Tickets'),
          FxSidebarItem(
            icon: Icons.book_rounded, 
            label: 'Travel Journal', 
            onTap: () => Fx.to('/journal'),
          ),
          const FxSidebarHeader(label: 'Account'),
          const FxSidebarItem(icon: Icons.person_rounded, label: 'Profile Settings'),
          FxSidebarItem(
            icon: FxTheme.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded, 
            label: 'Toggle Theme',
            onTap: () => FxTheme.toggle(),
          ),
        ],
      );

      return Fx.layout(
        mobile: Scaffold(
          drawer: Drawer(
            width: 280,
            backgroundColor: FxTheme.isDarkMode ? const Color(0xFF0F172A) : Colors.white,
            child: sidebar,
          ),
          body: body,
          bottomNavigationBar: navbar,
        ),
        desktop: Scaffold(
          body: Fx.row(
            children: [
              sidebar,
              Expanded(
                child: Fx.page(
                  child: body,
                ).p(24),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Fx(() {
      final controller = context.find<HomeController>();
      final isDark = FxTheme.isDarkMode;
      
      return Stack(
        children: [
          _buildBackground(isDark),
          Fx.safeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Fx.col(
                    alignItems: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, isDark),
                      Fx.gap(24),
                      _buildSearch(controller, isDark),
                      Fx.gap(32),
                      _buildSectionTitle('Categories', isDark),
                      Fx.gap(12),
                      _buildCategories(controller, isDark),
                      Fx.gap(32),
                      _buildSectionTitle('Recommended', isDark),
                      Fx.gap(16),
                    ],
                  ),
                ),
                _buildRecommendedGrid(controller),
                SliverToBoxAdapter(child: Fx.gap(100)),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildBackground(bool isDark) {
    return isDark
        ? const FxMeshGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF0F172A)],
            speed: 0.3,
          )
        : const FxMeshGradient(
            colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF), Color(0xFFC7D2FE), Color(0xFFEEF2FF)],
            speed: 0.3,
          );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Fx.row(
      justify: MainAxisAlignment.spaceBetween,
      children: [
        FxBoing(
          onTap: () {
            final scaffold = Scaffold.of(context);
            if (scaffold.hasDrawer) scaffold.openDrawer();
          },
          child: Fx.icon(Icons.menu_rounded, color: isDark ? Colors.white : Colors.black87, size: 28)
              .p(12)
              .bg.color(isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03))
              .rounded(14)
              .glass(isDark ? 10 : 0),
        ),
        Fx.gap(16),
        Expanded(
          child: Fx.col(
            alignItems: CrossAxisAlignment.start,
            children: [
              Fx.text('Elite Experience').color(isDark ? Colors.white54 : Colors.black45).textSm(),
              Fx.text('Discover the World').bold().fontSize(28).color(isDark ? Colors.white : Colors.black87).ellipsis(),
            ],
          ),
        ),
        Fx.avatar(image: 'https://i.pravatar.cc/150?u=a042581f4e29026704d'),
      ],
    ).px(24).pt(8);
  }

  Widget _buildSearch(HomeController controller, bool isDark) {
    return Fx.row(
      gap: 12,
      children: [
        Fx.box(
          style: FxStyle(
            backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(20),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            flex: 1,
            glass: isDark ? 10 : 0,
            border: isDark ? null : Border.all(color: Colors.black.withValues(alpha: 0.05)),
          ),
          child: Fx.row(
            children: [
              Icon(Icons.search_rounded, color: isDark ? Colors.white54 : Colors.black38),
              Fx.gap(16),
              Expanded(
                child: TextField(
                  onChanged: (v) => controller.setSearch(v),
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Search destinations...',
                    hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black45),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        Fx.icon(Icons.tune_rounded, color: Colors.white)
            .p(16)
            .bg.color(const Color(0xFF6366F1))
            .rounded(20)
            .shadow(color: const Color(0xFF6366F1).withValues(alpha: isDark ? 0.3 : 0.15), blur: 15),
      ],
    ).px(24);
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Fx.text(title).bold().fontSize(18).color(isDark ? Colors.white : Colors.black87).px(24);
  }

  Widget _buildCategories(HomeController controller, bool isDark) {
    return Fx.row(
      gap: 16,
      children: [
        Fx.gap(24 - 16), // Ensures exactly 24px from edge
        ...data.categories.map((cat) {
          return Fx(() {
            final isSelected = controller.selectedCategory.value == cat;
            return FxBoing(
              onTap: () => controller.setCategory(cat),
              child: Fx.row(
                gap: 8,
                children: [
                  Icon(data.categories.indexOf(cat) == 0 ? Icons.grid_view_rounded : Icons.category_rounded, 
                       size: 18, 
                       color: isSelected ? Colors.white : (isDark ? Colors.white54 : Colors.black45)),
                  Fx.text(cat)
                      .bold()
                      .fontSize(14)
                      .color(isSelected ? Colors.white : (isDark ? Colors.white54 : Colors.black45)),
                ],
              )
              .px(24).py(12)
              .bg.color(isSelected 
                  ? const Color(0xFF6366F1) 
                  : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03)))
              .rounded(20)
              .glass(isDark && !isSelected ? 10 : 0)
              .border(color: !isSelected && !isDark ? Colors.black.withValues(alpha: 0.05) : Colors.transparent),
            );
          });
        }),
        Fx.gap(8),
      ],
    ).scrollable(direction: Axis.horizontal);
  }

  Widget _buildRecommendedGrid(HomeController controller) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          childAspectRatio: 0.75,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => DestinationCard(data: controller.filteredDestinations[index]),
          childCount: controller.filteredDestinations.length,
        ),
      ),
    );
  }
}
