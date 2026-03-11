import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';
import 'package:fluxy_animations/fluxy_animations.dart';

class DestinationCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const DestinationCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Fx(() {
      final isDark = FxTheme.isDarkMode;
      
      return FxEntrance(
        slideOffset: const Offset(0, 40),
        child: FxPerspective(
          intensity: 0.05,
          child: FxBoing(
            onTap: () => Fx.to('/details', arguments: data),
            child: Fx.box(
              style: FxStyle(
                borderRadius: BorderRadius.circular(28),
                backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                glass: isDark ? 15 : 0,
                border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.03)),
                clipBehavior: Clip.antiAlias,
                shadows: isDark ? [] : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Fx.col(
                children: [
                  Stack(
                    children: [
                      Fx.image(data['image']).h(160).wFull().cover(),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Fx.row(
                          gap: 4,
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                            Fx.text(data['rating'].toString()).bold().textXs().whiteText(),
                          ],
                        ).p(8).bg.color(Colors.black38).rounded(12).glass(10),
                      ),
                    ],
                  ),
                  Fx.row(
                    justify: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Fx.col(
                          alignItems: CrossAxisAlignment.start,
                          children: [
                            Fx.text(data['title'])
                                .bold()
                                .textLg()
                                .color(isDark ? Colors.white : Colors.black87)
                                .ellipsis(),
                            Fx.row(
                              gap: 4,
                              children: [
                                Icon(Icons.location_on_rounded, color: isDark ? Colors.white54 : Colors.black45, size: 14),
                                Expanded(
                                  child: Fx.text(data['location'])
                                      .color(isDark ? Colors.white54 : Colors.black45)
                                      .textXs()
                                      .ellipsis(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Fx.gap(12),
                      Fx.col(
                        alignItems: CrossAxisAlignment.end,
                        children: [
                          Fx.text(data['price']).bold().fontSize(20).color(const Color(0xFF6366F1)),
                          Fx.text('/ person').color(isDark ? Colors.white54 : Colors.black45).fontSize(10),
                        ],
                      ),
                    ],
                  ).p(20),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
