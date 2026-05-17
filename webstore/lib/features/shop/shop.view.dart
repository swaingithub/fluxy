import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';
import 'shop.controller.dart';
import '../shared/web_layout.dart';
import '../shared/web_footer.dart';
import '../shared/web_product_card.dart';

class ShopView extends StatelessWidget {
  const ShopView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Fluxy.find<ShopController>();

    return WebLayout(
      child: Fx.scroll(
        child: FxWeb.container(
          maxWidth: 1200,
          child: Fx.col(
            alignItems: CrossAxisAlignment.start,
            children: [
              Fx.gap(140),
              Fx.reveal(
                children: [
                  Fx.text('SHOP').tw('text-5xl font-extrabold text-slate-900 tracking-tight'),
                  Fx.gap(16),
                  Fx.text('Browse our entire catalog of premium software developer gear and aesthetics.').tw('text-xl text-slate-500'),
                ]
              ).tw('px-8'),
              Fx.gap(48),
              
              Fx(() {
                if (!controller.isLoaded.value) return Fx.center(child: const CircularProgressIndicator());
                return Fx.reveal(
                  interval: const Duration(milliseconds: 100),
                  children: [
                    /// REACTIVE TAB BAR (Fluxy Logic)
                    FxTabBar(
                      currentIndex: controller.currentTabIndex,
                      tabs: controller.categories.value,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                    ),

                    Fx.gap(48),

                    /// PRODUCT GRID
                    Fx(() {
                      final items = controller.filteredProducts;
                      if (items.isEmpty) {
                        return Fx.center(
                          child: Fx.col(
                            children: [
                              Fx.icon(Icons.search_off, size: 64, color: Colors.grey),
                              Fx.gap(16),
                              Fx.text('No products found in this category.').tw('text-slate-400 text-lg font-medium'),
                            ],
                          ),
                        ).tw('py-20');
                      }
                      
                      return FxWeb.responsiveGrid(
                        context: context,
                        desktopColumns: 4,
                        tabletColumns: 2,
                        spacing: 32,
                        runSpacing: 48,
                        children: items.map((p) => WebProductCard(
                          product: p,
                          width: double.infinity,
                          aspectRatio: 0.9,
                          onTap: () => FluxyRouter.to('/shop/${p['id']}'),
                        )).toList(),
                      ).tw('px-8');
                    }),
                  ]
                );
              }),
              Fx.gap(120),
              const WebFooter(),
            ]
          )
        )
      )
    );
  }
}
