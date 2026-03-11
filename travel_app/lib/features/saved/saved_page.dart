import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';
import 'package:fluxy_animations/fluxy_animations.dart';
import '../../core/app_data.dart' as data;

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mocking saved data from the first few items
    final savedItems = data.destinations.take(3).toList();

    return Fx(() {
      final isDark = FxTheme.isDarkMode;
      
      return Fx.stack(
        children: [
          if (isDark)
            const FxMeshGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF0F172A)],
              speed: 0.3,
            )
          else
            const FxMeshGradient(
              colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF), Color(0xFFC7D2FE), Color(0xFFEEF2FF)],
              speed: 0.3,
            ),
        
        Fx.safeArea(
          child: Fx.col(
            alignItems: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              Fx.row(
                justify: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Fx.col(
                      alignItems: CrossAxisAlignment.start,
                      children: [
                        Fx.text('Saved Collections')
                            .bold()
                            .fontSize(32)
                            .color(isDark ? Colors.white : Colors.black87)
                            .ellipsis(),
                        Fx.text('${savedItems.length} items in your wishlist')
                            .color(isDark ? Colors.white54 : Colors.black45)
                            .textSm(),
                      ],
                    ),
                  ),
                  Fx.icon(Icons.sort_rounded, color: isDark ? Colors.white : Colors.black87, size: 24)
                      .p(12)
                      .bg.color(isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05))
                      .rounded(14)
                      .glass(isDark ? 10 : 0),
                ],
              ).p(24),

              // --- List of Saved Items ---
              if (savedItems.isEmpty)
                Fx.col(
                  mainAxisAlignment: MainAxisAlignment.center,
                  gap: 20,
                  children: [
                    Fx.icon(Icons.favorite_border_rounded, color: isDark ? Colors.white12 : Colors.black12, size: 80),
                    Fx.text('Your Wishlist is Empty')
                        .bold()
                        .textLg()
                        .color(isDark ? Colors.white : Colors.black87),
                    Fx.text('Explore and save your favorite destinations for later.')
                        .color(isDark ? Colors.white38 : Colors.black38)
                        .center()
                        .px(40),
                  ],
                ).expanded()
              else
                Fx.col(
                  gap: 20,
                  children: savedItems.map((item) => _buildSavedCard(item, isDark)).toList(),
                ).px(24).scrollable().expanded(),
              
      Fx.gap(100), // Bottom padding for navbar
            ],
          ),
        ),
      ],
    );
     });
  }

  Widget _buildSavedCard(Map<String, dynamic> item, bool isDark) {
    return FxPerspective(
      child: FxBoing(
      onTap: () => Fx.to('/details', arguments: item),
        child: Fx.row(
          gap: 16,
          children: [
            // Image
            Fx.hero(
              tag: 'img_${item['id']}',
              child: Fx.image(item['image'])
                  .w(110)
                  .h(110)
                  .cover()
                  .rounded(20),
            ),

            // Content
            Fx.col(
              alignItems: CrossAxisAlignment.start,
              gap: 4,
              children: [
                Fx.text(item['location'] ?? 'Unknown')
                    .color(const Color(0xFF818CF8))
                    .font.bold()
                    .fontSize(10)
                    .spacing(1.5),
                Fx.text(item['title'] ?? 'Title')
                    .bold()
                    .textBase()
                    .color(isDark ? Colors.white : Colors.black87)
                    .ellipsis(),
                Fx.row(
                  gap: 4,
                  children: [
                    Fx.icon(Icons.star_rounded, color: Colors.amber, size: 14),
                    Fx.text(item['rating']?.toString() ?? '5.0')
                        .color(isDark ? Colors.white70 : Colors.black54)
                        .textXs()
                        .bold(),
                  ],
                ).mt(4),
                
                Fx.row(
                  justify: MainAxisAlignment.spaceBetween,
                  children: [
                    Fx.text(item['price'] ?? '0')
                        .bold()
                        .textLg()
                        .color(isDark ? Colors.white : Colors.black87),
                    
                    // Remove button
                    FxBoing(
                      onTap: () => Fx.toast.info('Removed from saved!'),
                      child: Fx.icon(Icons.heart_broken_rounded, color: Colors.redAccent, size: 18)
                          .p(8)
                          .bg.color(isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05))
                          .rounded(10),
                    ),
                  ],
                ).wFull().mt(8),
              ],
            ).expanded(),
          ],
        )
            .p(16)
            .bg.color(isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white)
            .rounded(24)
            .border(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05))
            .glass(isDark ? 20 : 0)
            .style(FxStyle(
              shadows: isDark ? [] : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            )),
      ),
    );
  }
}
