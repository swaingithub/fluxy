import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';
import 'item.controller.dart';
import '../shared/web_layout.dart';
import '../shared/web_footer.dart';

class ItemView extends StatelessWidget {
  final String itemId;
  const ItemView({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    final controller = Fluxy.find<ItemController>();
    controller.loadItem(itemId);

    return WebLayout(
      child: Fx.scroll(
        child: FxWeb.container(
          maxWidth: 1200,
          child: Fx.col(
            alignItems: CrossAxisAlignment.start,
            children: [
              Fx.gap(120),
              // Simulated Network Skeleton loading via Fx.suspense 
              Fx(() {
                if (controller.isLoading.value) {
                  return Fx.center(
                    child: Fx.col(
                      children: [
                        Fx.gap(100),
                        const CircularProgressIndicator(),
                        Fx.gap(24),
                        Fx.text('Fetching product details...').tw('text-slate-400 font-medium'),
                        Fx.gap(200),
                      ]
                    )
                  );
                }

                final product = controller.product.value;
                if (product == null) {
                  return Fx.center(child: Fx.text('Product not found.').tw('text-3xl font-bold py-32 text-slate-400'));
                }

                final isMobile = Fx.isMobile(context);
                
                // Using the split abstraction mapped to layout natively
                return Fx.reveal(
                  interval: const Duration(milliseconds: 150),
                  children: [
                    Fx.row(
                      alignItems: CrossAxisAlignment.start,
                      children: isMobile ? _buildMobileStack(product, controller) : _buildDesktopSplit(product, controller),
                    ),
                  ]
                ).tw('px-8');
              }),
              Fx.gap(140),
              const WebFooter(),
            ]
          )
        )
      )
    );
  }

  List<Widget> _buildDesktopSplit(Map product, ItemController controller) {
    return [
      Expanded(
        flex: 3,
        child: Fx.image(
          product['image'],
          width: double.infinity,
          height: 600,
          fit: BoxFit.cover,
          radius: 24,
        ),
      ),
      Fx.gap(64),
      Expanded(
        flex: 2,
        child: _buildDetailsBlock(product, controller),
      )
    ];
  }

  List<Widget> _buildMobileStack(Map product, ItemController controller) {
    return [
      Expanded(
        child: Fx.col(
          alignItems: CrossAxisAlignment.start,
          children: [
            Fx.image(
              product['image'],
              width: double.infinity,
              height: 400,
              fit: BoxFit.cover,
              radius: 24,
            ),
            Fx.gap(48),
            _buildDetailsBlock(product, controller),
          ]
        ),
      )
    ];
  }

  Widget _buildDetailsBlock(Map product, ItemController controller) {
    return Fx.col(
      alignItems: CrossAxisAlignment.start,
      children: [
        Fx.text(product['category']).tw('text-sm font-bold uppercase tracking-widest text-slate-400 mb-4'),
        Fx.text(product['name']).tw('text-5xl font-extrabold text-slate-900 leading-tight'),
        Fx.gap(16),
        Fx.text('\$${product['price']}').tw('text-3xl font-bold text-blue-600'),
        Fx.gap(48),
        Fx.text('A minimalist essential engineered strictly for performance rendering and aesthetic purity. Crafted meticulously for developers.').tw('text-lg text-slate-600 leading-relaxed'),
        Fx.gap(48),
        Fx.text('Size').tw('text-sm font-bold text-slate-900 uppercase tracking-widest mb-4'),
        Fx.row(
          gap: 16,
          children: ['S', 'M', 'L', 'XL'].map((s) => _buildSizeSelector(s, controller)).toList(),
        ),
        Fx.gap(64),
        SizedBox(
          width: double.infinity,
          child: FxButton(
            onTap: () => controller.addToCart(),
            isRounded: true,
            style: const FxStyle(
              backgroundColor: Color(0xFF0F172A),
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 24),
              transition: Duration(milliseconds: 200),
              hover: FxStyle(backgroundColor: Color(0xFF334155)),
            ),
            child: const Text('Add to Cart', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        ),
        Fx.gap(64),
        FxWeb.accordion(
           title: 'Material Details',
           content: Fx.text('100% Organic Cotton. Crafted to emulate the lightweight structure of the Fluxy rendering pipeline.').tw('text-slate-600 leading-relaxed text-base')
        ),
        FxWeb.accordion(
           title: 'Shipping & Returns',
           content: Fx.text('Free global shipping. Returns accepted strictly within a 30-day compile timeframe.').tw('text-slate-600 leading-relaxed text-base')
        ),
      ]
    );
  }

  Widget _buildSizeSelector(String size, ItemController controller) {
    final isSelected = controller.selectedSize.value == size;
    return Fx.box(
      onTap: () => controller.selectSize(size),
      style: FxStyle(
        width: 64,
        height: 64,
        alignment: Alignment.center,
        backgroundColor: isSelected ? const Color(0xFF0F172A) : Colors.white,
        border: Border.all(color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0), width: 2),
        borderRadius: BorderRadius.circular(16),
        cursor: SystemMouseCursors.click,
        transition: const Duration(milliseconds: 200),
        hover: isSelected ? const FxStyle() : FxStyle(border: Border.all(color: const Color(0xFF94A3B8), width: 2)),
      ),
      child: Fx.text(size).tw(isSelected ? 'text-white font-bold text-lg' : 'text-slate-600 font-bold text-lg'),
    );
  }
}
