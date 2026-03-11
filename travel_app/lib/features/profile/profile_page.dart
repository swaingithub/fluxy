import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';
import 'package:fluxy_animations/fluxy_animations.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
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
                _buildProfileHeader(isDark),

                Fx.gap(32),

                // --- Stats Row ---
                Fx.row(
                  justify: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStat('Reviews', '24', isDark),
                    _buildStat('Trips', '12', isDark),
                    _buildStat('Points', '1.2k', isDark),
                  ],
                ).px(24),

                Fx.gap(40),

                // --- Sections ---
                Fx.col(
                  gap: 16,
                  children: [
                    Fx.text('Account Settings')
                        .bold()
                        .fontSize(14)
                        .color(isDark ? Colors.white38 : Colors.black38)
                        .spacing(1.5),
                    
                    _buildSettingItem(Icons.person_outline_rounded, 'Personal Information', 'Change your name and bio', isDark),
                    _buildSettingItem(Icons.notifications_none_rounded, 'Notifications', 'Manage alerts and updates', isDark),
                    _buildSettingItem(Icons.security_rounded, 'Security', 'Password and biometric settings', isDark),
                    
                    Fx.gap(16),
                    
                    Fx.text('Preferences')
                        .bold()
                        .fontSize(14)
                        .color(isDark ? Colors.white38 : Colors.black38)
                        .spacing(1.5),
                        
                    _buildSettingItem(Icons.language_rounded, 'Language', 'English (US)', isDark),
                    _buildSettingItem(
                      isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, 
                      'Appearance', 
                      isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode', 
                      isDark,
                      onTap: () => FxTheme.toggle(),
                    ),
                    
                    Fx.gap(32),
                    
                    // Logout
                    FxBoing(
                      onTap: () => Fx.toast.info('Logged out successfully'),
                      child: Fx.row(
                        gap: 12,
                        children: [
                          Fx.icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                          Fx.text('Sign Out').bold().color(Colors.redAccent),
                        ],
                      )
                      .p(20)
                      .wFull()
                      .bg.color(Colors.redAccent.withValues(alpha: 0.1))
                      .rounded(20)
                      .border(color: Colors.redAccent.withValues(alpha: 0.2)),
                    ),
                  ],
                ).px(24).scrollable().expanded(),

                Fx.gap(100),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildProfileHeader(bool isDark) {
    return Fx.row(
      gap: 20,
      children: [
        const FxPulsar(
          child: FxAvatar(
            image: 'https://i.pravatar.cc/150?img=32',
            size: FxAvatarSize.xl,
            shape: FxAvatarShape.square,
          ),
        ),
        Expanded(
          child: Fx.col(
            alignItems: CrossAxisAlignment.start,
            gap: 4,
            children: [
              Fx.text('Alex Rivera')
                  .bold()
                  .fontSize(24)
                  .color(isDark ? Colors.white : Colors.black87)
                  .ellipsis(),
              Fx.text('alex.rivera@elite.com')
                  .color(isDark ? Colors.white54 : Colors.black45)
                  .textSm()
                  .ellipsis(),
              Fx.row(
                gap: 8,
                children: [
                  Fx.icon(Icons.verified_rounded, color: const Color(0xFF6366F1), size: 16),
                  Expanded(
                    child: Fx.text('Verified Explorer')
                        .bold()
                        .fontSize(12)
                        .color(const Color(0xFF6366F1))
                        .ellipsis(),
                  ),
                ],
              ).mt(4),
            ],
          ),
        ),
      ],
    ).p(24);
  }

  Widget _buildStat(String label, String value, bool isDark) {
    return Fx.col(
      gap: 4,
      children: [
        Fx.text(value).bold().fontSize(20).color(isDark ? Colors.white : Colors.black87),
        Fx.text(label).color(isDark ? Colors.white38 : Colors.black38).textXs().bold(),
      ],
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String subtitle, bool isDark, {VoidCallback? onTap}) {
    return FxBoing(
      onTap: onTap ?? () => Fx.toast.info('Opening $title'),
      child: Fx.row(
        gap: 16,
        children: [
          Fx.icon(icon, color: isDark ? Colors.white70 : Colors.black54, size: 22)
              .p(12)
              .bg.color(isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05))
              .rounded(14),
          Fx.col(
            alignItems: CrossAxisAlignment.start,
            children: [
              Fx.text(title).bold().color(isDark ? Colors.white : Colors.black87).textBase(),
              Fx.text(subtitle).color(isDark ? Colors.white38 : Colors.black38).textXs(),
            ],
          ).expanded(),
          Fx.icon(Icons.chevron_right_rounded, color: isDark ? Colors.white24 : Colors.black26, size: 20),
        ],
      )
      .p(16)
      .bg.color(isDark ? Colors.white.withValues(alpha: 0.02) : Colors.white)
      .rounded(20)
      .border(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
    );
  }
}
