import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';
import '../home/home.controller.dart';
import 'web_navbar.dart';

class WebLayout extends StatelessWidget {
  final Widget child;
  const WebLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    HomeController? homeController;
    try {
      homeController = Fluxy.find<HomeController>();
    } catch (_) {}

    return Fx.scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Fx.stack(
        children: [
          // 1. The Page Array
          child,

          // 2. The Header Overlay
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: WebNavbar(),
          ),

          // 3. The Slide-overs
          if (homeController != null)
            Builder(builder: (context) {
              final ctrl = homeController!;
              return Positioned.fill(
                child: Fx(() => Stack(
                  children: [
                     FxWeb.drawer(
                        isOpen: ctrl.isMobileMenuOpen.value,
                        onClose: () => ctrl.toggleMobileMenu(),
                        fromRight: false,
                        child: _buildMobileMenuContent(ctrl),
                     ),
                     FxWeb.drawer(
                        isOpen: ctrl.isCartOpen.value,
                        onClose: () => ctrl.toggleCart(),
                        child: _buildCartContent(ctrl),
                     )
                  ]
                )),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildCartContent(HomeController controller) {
    final items = controller.cartItems.value;
    if (items.isEmpty) {
      return Fx.center(
        child: Fx.col(
          alignItems: CrossAxisAlignment.center,
          children: [
            Fx.icon(Icons.shopping_cart_outlined, size: 64, color: const Color(0xFFCBD5E1)),
            Fx.gap(24),
            Fx.text('Your cart is empty.').tw('text-lg text-slate-500 font-medium'),
          ],
        ),
      );
    }

    double total = items.fold(0, (sum, item) => sum + (item['price'] as double));

    return Fx.col(
      alignItems: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: items.length,
            separatorBuilder: (_, __) => Fx.gap(24),
            itemBuilder: (context, index) {
              final item = items[index];
              return Fx.row(
                alignItems: CrossAxisAlignment.center,
                children: [
                  Fx.image(item['image'], width: 80, height: 80, fit: BoxFit.cover, radius: 12),
                  Fx.gap(16),
                  Expanded(
                    child: Fx.col(
                      alignItems: CrossAxisAlignment.start,
                      children: [
                        Fx.text(item['name']).tw('font-bold text-slate-900 text-sm truncate'),
                        Fx.gap(4),
                        Fx.text('\$${item['price']}').tw('font-semibold text-blue-600'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        // Checkout Footer
        Fx.box(
          style: const FxStyle(
            padding: EdgeInsets.all(24),
            border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            backgroundColor: Color(0xFFF8FAFC),
          ),
          child: Fx.col(
            children: [
              Fx.row(
                justify: MainAxisAlignment.spaceBetween,
                children: [
                  Fx.text('Subtotal').tw('text-slate-500 font-semibold'),
                  Fx.text('\$${total.toStringAsFixed(2)}').tw('text-xl font-bold text-slate-900'),
                ],
              ),
              Fx.gap(24),
              SizedBox(
                width: double.infinity,
                child: FxButton(
                  onTap: () {},
                  isRounded: true,
                  style: const FxStyle(
                    backgroundColor: Color(0xFF0F172A),
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    transition: Duration(milliseconds: 200),
                    hover: FxStyle(backgroundColor: Color(0xFF334155)),
                  ),
                  child: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildMobileMenuContent(HomeController controller) {
    return Fx.col(
      alignItems: CrossAxisAlignment.start,
      children: [
        Fx.gap(24),
        ...['Shop', 'Editorial', 'Journal', 'Collection'].map((link) => Fx.box(
          onTap: () {
            controller.toggleMobileMenu();
            FluxyRouter.to('/${link.toLowerCase()}');
          },
          style: const FxStyle(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
            cursor: SystemMouseCursors.click,
          ),
          child: Fx.text(link).tw('text-xl font-bold text-slate-800 tracking-wide w-full'),
        )),
      ]
    );
  }
}
