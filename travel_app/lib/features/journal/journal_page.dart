import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';
import 'package:fluxy_animations/fluxy_animations.dart';
import 'journal_controller.dart';

class JournalPage extends StatelessWidget {
  const JournalPage({super.key});

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.find<JournalController>();

    return Fx(() {
      final isDark = FxTheme.isDarkMode;
      
      return Fx.scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        body: Fx.stack(
          children: [
            _buildBackground(isDark),
            
            Fx.safeArea(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildHeader(isDark),
                  ),
                  
                  Fx(() {
                    final items = controller.entries.value;
                    
                    if (items.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildEmptyState(isDark),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Fx.col(
                            children: [
                              _buildJournalCard(items[index], index, isDark),
                              Fx.gap(24),
                            ],
                          ),
                          childCount: items.length,
                        ),
                      ),
                    );
                  }),
                  SliverToBoxAdapter(child: Fx.gap(100)),
                ],
              ),
            ),

            _buildFAB(),
          ],
        ),
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

  Widget _buildFAB() {
    return FxBoing(
      onTap: () => Fx.toast.info('Create new entry feature coming soon!'),
      child: Fx.icon(Icons.add_rounded, color: Colors.white, size: 32)
          .p(16)
          .bg.color(const Color(0xFF6366F1))
          .rounded(20)
          .shadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.5),
            blur: 20,
            offset: const Offset(0, 8),
          ),
    ).positioned(bottom: 30, right: 30);
  }

  Widget _buildHeader(bool isDark) {
    return Fx.col(
      alignItems: CrossAxisAlignment.start,
      children: [
        Fx.row(
          justify: MainAxisAlignment.spaceBetween,
          children: [
            FxBoing(
              onTap: () => Fx.back(),
              child: Fx.icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black87, size: 20)
                  .p(12)
                  .bg.color(isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05))
                  .rounded(14)
                  .glass(isDark ? 10 : 0),
            ),
            Fx.text('Travel Journal').bold().textLg().color(isDark ? Colors.white : Colors.black87),
            Fx.icon(Icons.search_rounded, color: isDark ? Colors.white : Colors.black87, size: 24)
                .p(12)
                .bg.color(isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05))
                .rounded(14)
                .glass(isDark ? 10 : 0),
          ],
        ),
        Fx.gap(24),
        Fx.text('Your Travel Memories')
            .bold()
            .fontSize(32)
            .color(isDark ? Colors.white : Colors.black87)
            .ellipsis(),
        Fx.text('Preserve every moment of your elite journeys')
            .color(isDark ? Colors.white54 : Colors.black45)
            .textSm()
            .ellipsis(),
      ],
    ).px(24).pt(8).pb(24);
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Fx.col(
        gap: 20,
        children: [
          Fx.icon(Icons.menu_book_rounded, color: isDark ? Colors.white12 : Colors.black12, size: 80),
          Fx.text('No Memories Yet').bold().textLg().color(isDark ? Colors.white : Colors.black87),
          Fx.text('Tap the + button to start documenting your journey.')
              .color(isDark ? Colors.white38 : Colors.black45)
              .center()
              .px(40),
        ],
      ).pack(),
    );
  }

  Widget _buildJournalCard(JournalEntry entry, int index, bool isDark) {
    return FxPerspective(
      child: Fx.box()
          .bg.color(isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white)
          .rounded(32)
          .border(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05))
          .glass(isDark ? 20 : 0)
          .child(
            Fx.col(
              alignItems: CrossAxisAlignment.start,
              children: [
                // Image
                Fx.image(entry.images.first)
                    .h(200)
                    .wFull()
                    .cover()
                    .style(
                      const FxStyle(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                      ),
                    ),
                
                Fx.col(
                  alignItems: CrossAxisAlignment.start,
                  children: [
                    Fx.row(
                      justify: MainAxisAlignment.spaceBetween,
                      children: [
                        Fx.text(_formatDate(entry.date))
                            .color(const Color(0xFF818CF8))
                            .bold()
                            .fontSize(10)
                            .spacing(1.5),
                        Fx.row(
                          gap: 4,
                          children: [
                            Fx.icon(Icons.star_rounded, color: Colors.amber, size: 14),
                            Fx.text(entry.rating.toString()).color(isDark ? Colors.white : Colors.black87).bold().textXs(),
                          ],
                        ),
                      ],
                    ),
                    Fx.gap(8),
                    Fx.text(entry.title).bold().fontSize(22).color(isDark ? Colors.white : Colors.black87).ellipsis(),
                    Fx.row(
                      gap: 4,
                      children: [
                        Fx.icon(Icons.location_on_rounded, color: isDark ? Colors.white38 : Colors.black38, size: 14),
                        Fx.text(entry.location).color(isDark ? Colors.white38 : Colors.black38).textXs(),
                      ],
                    ),
                    Fx.gap(16),
                    Fx.text(entry.content)
                        .color(isDark ? Colors.white70 : Colors.black54)
                        .fontSize(14)
                        .maxLines(3)
                        .ellipsis()
                        .style(const FxStyle(lineHeight: 1.5)),
                  ],
                ).p(24),
              ],
            ),
          ),
    );
  }
}
