import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';
import 'collection.controller.dart';
import '../shared/web_layout.dart';
import '../shared/web_footer.dart';
import '../shared/web_product_card.dart';

class CollectionView extends StatelessWidget {
  const CollectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Fluxy.find<CollectionController>();
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
                  Fx.text('COLLECTION').tw('text-5xl font-extrabold text-slate-900 tracking-tight'),
                  Fx.gap(16),
                  Fx.text('Curated aesthetic resources for the modern builder.').tw('text-xl text-slate-500'),
                ]
              ).tw('px-8'),
              Fx.gap(64),
              Fx(() {
                if (!controller.isLoaded.value) return Fx.center(child: const CircularProgressIndicator());
                
                final items = controller.collections.value;
                return Fx.reveal(
                  interval: const Duration(milliseconds: 150),
                  children: [
                    FxWeb.responsiveGrid(
                      context: context,
                      children: items.map((c) => WebProductCard(
                        product: c as Map<String, dynamic>,
                        isCollection: true,
                        width: double.infinity, // Let the grid control width
                        aspectRatio: 1.2,
                        onTap: () => FluxyRouter.to('/collection/${c['tag']}'),
                      )).toList(),
                    ),
                  ],
                ).tw('px-8');
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
