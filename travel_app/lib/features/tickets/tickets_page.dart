import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';
import 'package:fluxy_animations/fluxy_animations.dart';

class TicketsPage extends StatelessWidget {
  const TicketsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tickets = [
      {
        'destination': 'Bali Bliss',
        'location': 'Indonesia',
        'date': '24 Oct 2026',
        'time': '10:30 AM',
        'seat': '12A',
        'class': 'Premium',
        'price': '\$850',
        'status': 'Upcoming',
      },
      {
        'destination': 'Swiss Alps',
        'location': 'Switzerland',
        'date': '12 Nov 2026',
        'time': '08:15 AM',
        'seat': '04C',
        'class': 'Elite',
        'price': '\$1,500',
        'status': 'Upcoming',
      },
    ];

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
              Fx.col(
                alignItems: CrossAxisAlignment.start,
                children: [
                  Fx.text('My Tickets')
                      .bold()
                      .fontSize(32)
                      .color(isDark ? Colors.white : Colors.black87),
                  Fx.text('Keep track of your upcoming journeys')
                      .color(isDark ? Colors.white54 : Colors.black45)
                      .textSm(),
                ],
              ).p(24),

              // --- Ticket List ---
              if (tickets.isEmpty)
                Fx.col(
                  mainAxisAlignment: MainAxisAlignment.center,
                  gap: 20,
                  children: [
                    Fx.icon(Icons.confirmation_number_outlined, color: isDark ? Colors.white12 : Colors.black12, size: 80),
                    Fx.text('No Active Tickets')
                        .bold()
                        .textLg()
                        .color(isDark ? Colors.white : Colors.black87),
                    Fx.text('Your adventures will appear here once booked.')
                        .color(isDark ? Colors.white38 : Colors.black45)
                        .center()
                        .px(40),
                  ],
                ).expanded()
              else
                Fx.col(
                  gap: 24,
                  children: tickets.map((t) => _buildTicketCard(t, isDark)).toList(),
                ).px(24).scrollable().expanded(),

              Fx.gap(100),
            ],
          ),
        ),
      ],
    );
    });
  }

  Widget _buildTicketCard(Map<String, String> ticket, bool isDark) {
    return FxPerspective(
      child: FxBoing(
        onTap: () => Fx.toast.info('Ticket Details Opened'),
        child: Fx.box()
            .bg.color(isDark ? const Color(0xFF1E293B).withValues(alpha: 0.8) : Colors.white)
            .rounded(30)
            .border(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05))
            .glass(isDark ? 20 : 0)
            .style(FxStyle(
              shadows: isDark ? [] : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                )
              ],
            ))
            .child(
              Fx.col(
                children: [
                  // --- Top Section ---
                  Fx.row(
                    justify: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Fx.col(
                          alignItems: CrossAxisAlignment.start,
                          children: [
                            Fx.text(ticket['location']!)
                                .color(const Color(0xFF818CF8))
                                .bold()
                                .fontSize(10)
                                .spacing(1.5),
                            Fx.text(ticket['destination']!)
                                .bold()
                                .fontSize(20)
                                .color(isDark ? Colors.white : Colors.black87)
                                .ellipsis(),
                          ],
                        ),
                      ),
                      Fx.gap(12),
                      Fx.text(ticket['class']!)
                          .bold()
                          .fontSize(12)
                          .whiteText()
                          .px(12)
                          .py(6)
                          .bg.color(const Color(0xFF6366F1).withValues(alpha: 0.3))
                          .rounded(10),
                    ],
                  ).p(20),

                  // --- Dashed Divider ---
                  Fx.row(
                    children: [
                      _halfCircle(isLeft: true),
                      Expanded(
                        child: Fx.box()
                            .h(1)
                            .bg.color(isDark ? Colors.white10 : Colors.black12)
                            .mx(4),
                      ),
                      _halfCircle(isLeft: false),
                    ],
                  ),

                  // --- Bottom Section ---
                  Fx.row(
                    justify: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoColumn('DATE', ticket['date']!, isDark),
                      _buildInfoColumn('TIME', ticket['time']!, isDark),
                      _buildInfoColumn('SEAT', ticket['seat']!, isDark),
                      Fx.icon(Icons.qr_code_2_rounded, color: isDark ? Colors.white70 : Colors.black87, size: 32),
                    ],
                  ).p(20),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, bool isDark) {
    return Fx.col(
      alignItems: CrossAxisAlignment.start,
      gap: 4,
      children: [
        Fx.text(label).color(isDark ? Colors.white38 : Colors.black38).fontSize(9).bold().spacing(1.2),
        Fx.text(value).color(isDark ? Colors.white : Colors.black87).bold().fontSize(14).ellipsis(),
      ],
    );
  }

  Widget _halfCircle({required bool isLeft}) {
    return Fx.box()
        .w(20)
        .h(10)
        .bg.color(FxTheme.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC))
        .style(
          FxStyle(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isLeft ? 0 : 20),
              bottomLeft: Radius.circular(isLeft ? 0 : 20),
              topRight: Radius.circular(isLeft ? 20 : 0),
              bottomRight: Radius.circular(isLeft ? 20 : 0),
            ),
          ),
        );
  }
}
