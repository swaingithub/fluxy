import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';
import 'package:fluxy_animations/fluxy_animations.dart';

class DestinationDetailsPage extends StatelessWidget {
  final Map<String, dynamic> data;
  const DestinationDetailsPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Fx(() {
      final isDark = FxTheme.isDarkMode;

      return Fx.scaffold(
        backgroundColor: isDark ? const Color(0xFF0A0F1E) : const Color(0xFFF8FAFC),
        body: Fx.stack(
          children: [
            // --- 1. Hero Image ---
            Fx.hero(
              tag: 'img_${data['id']}',
              child: Fx.image(data['image']).hFull().wFull().cover(),
            ).positioned(
              top: 0,
              left: 0,
              right: 0,
              height: screenHeight * 0.55,
            ),
  
            // --- 2. Top Scrim ---
            Fx.box()
                .hFull()
                .wFull()
                .gradient(
                  LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [isDark ? Colors.black54 : Colors.black26, Colors.transparent],
                  ),
                )
                .positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 160,
            ),
  
            // --- 3. Bottom Scrim ---
            Fx.box()
                .hFull()
                .wFull()
                .gradient(
                  LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      (isDark ? const Color(0xFF0A0F1E) : const Color(0xFFF8FAFC)).withValues(alpha: 0.7),
                      isDark ? const Color(0xFF0A0F1E) : const Color(0xFFF8FAFC),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                )
                .positioned(
              top: screenHeight * 0.32,
              left: 0,
              right: 0,
              height: screenHeight * 0.26,
            ),
  
            // --- 4. Scrollable Content ---
            Fx.col(
              alignItems: CrossAxisAlignment.start,
              children: [
                Fx.gap(screenHeight * 0.44),
  
                // --- Title + Rating Row ---
                Fx.row(
                  justify: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Fx.col(
                      alignItems: CrossAxisAlignment.start,
                      gap: 6,
                      children: [
                        Fx.text(data['location'] ?? 'Unknown')
                            .color(const Color(0xFF818CF8))
                            .fontSize(13)
                            .bold()
                            .spacing(2.0),
                        Fx.text(data['title'] ?? 'Destination')
                            .bold()
                            .fontSize(32)
                            .color(isDark ? Colors.white : const Color(0xFF0F172A))
                            .style(const FxStyle(height: 1.15)),
                      ],
                    ).expanded(),
                    Fx.gap(16),
  
                    // Rating pill
                    Fx.row(
                      gap: 5,
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.white, size: 16),
                        Fx.text(data['rating']?.toString() ?? '4.9')
                            .bold()
                            .whiteText()
                            .fontSize(14),
                      ],
                    )
                        .px(14)
                        .py(8)
                        .bg.color(const Color(0xFF6366F1))
                        .rounded(50)
                        .shadow(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.45),
                          blur: 18,
                          offset: const Offset(0, 6),
                        ),
                  ],
                ).px(28),
  
                Fx.gap(28),
  
                // --- Main Content Card ---
                Fx.col(
                  alignItems: CrossAxisAlignment.start,
                  children: [
                    // Description
                    Fx.text(
                      data['description'] ??
                          'Discover the hidden beauty and serene landscapes of this world-class destination.',
                    )
                        .color(isDark ? Colors.white.withValues(alpha: 0.65) : Colors.black54)
                        .fontSize(15)
                        .style(const FxStyle(height: 1.75)),
  
                    Fx.gap(28),
                    _divider(isDark),
                    Fx.gap(28),
  
                    // Amenities label
                    Fx.text('HIGHLIGHTS')
                        .bold()
                        .color(isDark ? Colors.white38 : Colors.black26)
                        .fontSize(11)
                        .spacing(2.2),
                    Fx.gap(18),
  
                    // Amenity icons
                    Fx.row(
                      justify: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildFeature(Icons.wifi_rounded, 'Wi-Fi', isDark),
                        _buildFeature(Icons.pool_rounded, 'Pool', isDark),
                        _buildFeature(Icons.restaurant_rounded, 'Dining', isDark),
                        _buildFeature(Icons.spa_rounded, 'Spa', isDark),
                      ],
                    ),
  
                    Fx.gap(28),
                    _divider(isDark),
                    Fx.gap(28),
  
                    // Price + CTA
                    Fx.row(
                      justify: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Fx.col(
                          alignItems: CrossAxisAlignment.start,
                          gap: 4,
                          children: [
                            Fx.text('PER NIGHT')
                                .color(isDark ? Colors.white38 : Colors.black26)
                                .fontSize(11)
                                .spacing(1.8),
                            Fx.text(data['price'] ?? r'$0')
                                .bold()
                                .fontSize(36)
                                .color(isDark ? Colors.white : const Color(0xFF0F172A)),
                          ],
                        ),
                          FxConfetti(
                            child: FxBoing(
                              onTap: () => Fx.toast.success('Reservation Initiated!'),
                              child: Fx.text('Reserve Now')
                                  .bold()
                                  .whiteText()
                                  .fontSize(16)
                                  .py(24)
                                  .px(56)
                                  .gradient(
                                    const LinearGradient(
                                      colors: [Color(0xFF818CF8), Color(0xFF6366F1)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  )
                                  .rounded(24)
                                  .shadow(
                                    color: const Color(0xFF6366F1).withValues(alpha: 0.5),
                                    blur: 24,
                                    offset: const Offset(0, 10),
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ],
                )
                    .p(28)
                    .bg.color(isDark ? const Color(0xFF111827) : Colors.white)
                    .rounded(32)
                    .border(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.03))
                    .style(FxStyle(
                      shadows: isDark ? [] : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        )
                      ],
                    ))
                    .mx(16),
  
                Fx.gap(40),
              ],
            ).scrollable(),
  
            // --- 5. Nav Buttons ---
            Fx.safeArea(
              child: Fx.row(
                justify: MainAxisAlignment.spaceBetween,
                children: [
                  _navButton(Icons.arrow_back_ios_new_rounded, () => Fx.back(), isDark),
                  _navButton(Icons.favorite_rounded, () => Fx.toast.info('Added to favorites!'), isDark),
                ],
              ).px(20).py(8),
            ),
          ],
        ),
      );
    });
  }

  Widget _divider(bool isDark) {
    return Fx.box()
        .h(1)
        .wFull()
        .gradient(
          LinearGradient(
            colors: [
              Colors.transparent,
              isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
              Colors.transparent,
            ],
          ),
        );
  }

  Widget _navButton(IconData icon, VoidCallback onTap, bool isDark) {
    return FxBoing(
      onTap: onTap,
      child: Fx.icon(icon, color: Colors.white, size: 20)
          .p(14)
          .bg.color(Colors.black.withValues(alpha: 0.45))
          .rounded(16)
          .border(color: Colors.white.withValues(alpha: 0.15))
          .glass(40),
    );
  }

  Widget _buildFeature(IconData icon, String label, bool isDark) {
    return Fx.col(
      gap: 8,
      children: [
        Fx.icon(icon, color: const Color(0xFF818CF8), size: 24)
            .p(16)
            .bg.color(const Color(0xFF6366F1).withValues(alpha: 0.12))
            .rounded(18)
            .border(color: const Color(0xFF6366F1).withValues(alpha: 0.25)),
        Fx.text(label)
            .color(isDark ? Colors.white.withValues(alpha: 0.6) : Colors.black45)
            .fontSize(12)
            .bold(),
      ],
    );
  }
}