import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';
import '../home/home.controller.dart';

class WebNavbar extends StatelessWidget {
  const WebNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = FxWeb.isLargeScreen(context) == false;
    HomeController? homeController;
    try {
      homeController = Fluxy.find<HomeController>();
    } catch (_) {}

    return FxWeb.navbar(
      brand: Fx.box(
        onTap: () => FluxyRouter.to('/home'),
        style: const FxStyle(cursor: SystemMouseCursors.click),
        child: Fx.row(
          children: [
            Fx.box(
              style: FxStyle(
                backgroundColor: const Color(0xFF0F172A),
                padding: const EdgeInsets.all(8),
                borderRadius: BorderRadius.circular(12),
                shadows: FxTokens.shadow.sm,
                transition: const Duration(milliseconds: 200),
                hover: const FxStyle(transformScale: 1.05),
              ),
              child: Fx.icon(Icons.flash_on, color: Colors.white, size: 22),
            ),
            if (!mobile) ...[
              Fx.gap(12),
              Fx.text('FLUXY.').tw('text-2xl font-extrabold text-slate-900 tracking-tight'),
            ]
          ],
        ),
      ),
      desktopMenu: Fx.row(
        children: [
          _navLink('Shop'),
          Fx.gap(48),
          _navLink('Editorial'),
          Fx.gap(48),
          _navLink('Journal'),
          Fx.gap(48),
          _navLink('About'),
        ],
      ),
      mobileMenu: const SizedBox.shrink(),
      actions: Fx.row(
        children: [
          if (homeController != null) 
            Fx(() {
              final count = homeController!.cartItems.value.length;
              final button = FxButton(
                onTap: () => homeController!.toggleCart(),
                label: mobile ? '' : 'Cart',
                icon: mobile ? Fx.icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20) : null,
                isRounded: true,
                style: FxStyle(
                  backgroundColor: const Color(0xFF6366F1), // indigo-500
                  color: Colors.white,
                  padding: mobile ? const EdgeInsets.all(12) : const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  shadows: const [BoxShadow(color: Color(0x406366F1), blurRadius: 10, offset: Offset(0, 4))],
                ),
              );

              return FxBadge(
                show: count > 0,
                label: count.toString(),
                color: const Color(0xFFEF4444), // red-500
                offset: mobile ? const Offset(2, -2) : const Offset(4, -4),
                child: button,
              );
            })
          else 
            FxButton(
              onTap: () => FluxyRouter.to('/home'),
              label: mobile ? '' : 'Go back',
              icon: mobile ? Fx.icon(Icons.arrow_back, color: Colors.white, size: 20) : null,
              isRounded: true,
              style: FxStyle(
                backgroundColor: const Color(0xFF6366F1),
                color: Colors.white,
                padding: mobile ? const EdgeInsets.all(12) : const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shadows: const [BoxShadow(color: Color(0x406366F1), blurRadius: 10, offset: Offset(0, 4))],
              ),
            ),
          if (mobile) ...[
            Fx.gap(16),
            Fx.box(
              onTap: () {
                 if (homeController != null) homeController.toggleMobileMenu();
              },
              style: const FxStyle(cursor: SystemMouseCursors.click),
              child: Fx.icon(Icons.menu, size: 32, color: const Color(0xFF0F172A)),
            ),
          ]
        ],
      )
    );
  }

  Widget _navLink(String label) {
    return Fx.navLink(
      Fx.text(label).tw('text-base text-slate-500 font-semibold'),
      to: '/${label.toLowerCase()}',
    );
  }
}
