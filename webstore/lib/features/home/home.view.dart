import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';
import 'home.controller.dart';

import '../shared/web_layout.dart';
import '../shared/web_footer.dart';
import '../shared/web_product_card.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Fluxy.find<HomeController>();

    return WebLayout(
      child: Fx.scroll(
        child: FxWeb.container(
          maxWidth: 1200,
          child: Fx.col(
            alignItems: CrossAxisAlignment.start,
            children: [
              Fx.gap(100), // Padding to account for the floating navbar
              _buildHeroSection(context),
              Fx.gap(100),
              _buildTrendingSection(context, controller),
              Fx.gap(120),
              _buildFaqSection(),
              Fx.gap(120),
              const WebFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return FxWeb.hero(
      title: Fx.col(
        alignItems: CrossAxisAlignment.start,
        children: [
          Fx.text(
            'SUMMER EDITION',
          ).tw('text-blue-600 font-bold tracking-widest text-sm mb-6'),
          Fx.text('Define Your').tw(
            Fx.isMobile(context)
                ? 'text-5xl font-extrabold text-slate-900 leading-tight tracking-tight'
                : 'text-6xl font-extrabold text-slate-900 leading-tight tracking-tight',
          ),
          Fx.text('Framework.').tw(
            Fx.isMobile(context)
                ? 'text-5xl font-extrabold text-blue-600 leading-tight tracking-tight'
                : 'text-6xl font-extrabold text-blue-600 leading-tight tracking-tight',
          ),
        ],
      ),
      subtitle: Fx.text(
        'Discover premium minimalist aesthetics\ntailored for unparalleled performance.',
      ).tw('text-xl text-slate-500 leading-relaxed'),
      actions: Fx.row(
        children: [
          FxButton(
            onTap: () {FluxyRouter.to('/shop');},
            label: 'Shop Collection',
            isRounded: true,
            style: const FxStyle(
              backgroundColor: Colors.black,
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              shadows: [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
          ),
          Fx.gap(24),
          _buildHeroWatchAction(isMobile: Fx.isMobile(context)),
        ],
      ),
      media: Fx.box(
        style: const FxStyle(
          transition: Duration(milliseconds: 400),
          hover: FxStyle(transformScale: 1.02),
          cursor: SystemMouseCursors.click,
        ),
        child: Fx.image(
          'https://images.unsplash.com/photo-1445205170230-053b83016050?q=80&w=1200&auto=format&fit=crop',
          height: Fx.isMobile(context) ? 400 : 550,
          fit: BoxFit.cover,
          radius: 32,
        ),
      ),
    ).tw('px-8');
  }

  Widget _buildHeroWatchAction({bool isMobile = false}) {
    return Builder(
      builder: (context) => Fx.box(
        onTap: () {
          Fx.modal(
            context,
            child: Fx.video(
              url: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
              width: isMobile ? double.infinity : 1000, // Cinematic wide-view
              aspectRatio: 16 / 9,
              autoPlay: true,
              muted: false,
              showControls: true, // Enable the new Supreme UI
              radius: 16,
            ),
          );
        },
        style: const FxStyle(
          cursor: SystemMouseCursors.click,
          transition: Duration(milliseconds: 250),
          hover: FxStyle(transformScale: 1.05),
        ),
      child: Fx.row(
        mainAxisAlignment: isMobile
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          Fx.box(
            child: Fx.icon(Icons.play_arrow, color: Colors.blueAccent),
          ).tw('bg-blue-50 rounded-full p-4'),
          Fx.gap(12),
          Fx.text('Watch Film').tw('text-base font-bold text-slate-900'),
        ],
      ),
    ),
  );
}

  Widget _buildTrendingSection(
    BuildContext context,
    HomeController controller,
  ) {
    return Fx.box(
      child: Fx.col(
        alignItems: CrossAxisAlignment.start,
        children: [
          Fx.reveal(
            children: [
              Fx.row(
                justify: MainAxisAlignment.spaceBetween,
                children: [
                  Fx.text(
                    'Trending Pieces',
                  ).tw('text-4xl font-extrabold text-slate-900'),
                  Fx.link(
                    Fx.text(
                      'View Collection →',
                    ).tw('text-blue-600 font-bold text-base'),
                    to: '/collection',
                  ),
                ],
              ),
            ],
          ),
          Fx.gap(48),

          Fx(() {
            if (controller.isLoading.value) {
              return Fx.center(child: const CircularProgressIndicator());
            }

            final list = controller.products.value;
            return Fx.reveal(
              interval: const Duration(milliseconds: 80),
              children: [
                // Upgrading from static Grid to interactive Gallery Carousel!
                FxWeb.carousel(
                  // height: 540,
                  children: list
                      .map((p) => _buildProductCard(p, controller))
                      .toList(),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFaqSection() {
    return Fx.col(
      alignItems: CrossAxisAlignment.start,
      children: [
        Fx.text(
          'Frequently Asked Questions',
        ).tw('text-4xl font-extrabold text-slate-900 px-8'),
        Fx.gap(48),
        FxWeb.accordion(
          title: 'What is your return policy?',
          content: Fx.text(
            'We accept returns within 30 days of purchase for a full refund. The item must be in its original condition.',
          ).tw('text-slate-600 leading-relaxed text-base'),
          initialOpen: true,
        ),
        FxWeb.accordion(
          title: 'Do you offer international shipping?',
          content: Fx.text(
            'Yes! We ship globally using premium expedited carriers. Shipping times vary by destination.',
          ).tw('text-slate-600 leading-relaxed text-base'),
        ),
        FxWeb.accordion(
          title: 'When will new stock arrive?',
          content: Fx.text(
            'We restock our core lineup every two weeks. Limited editions are final run.',
          ).tw('text-slate-600 leading-relaxed text-base'),
        ),
      ],
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, HomeController controller) {
    return WebProductCard(
      product: product,
      onTap: () => FluxyRouter.to('/shop/${product['id']}'),
      onAction: () => controller.addToCart(product),
    );
  }
}
