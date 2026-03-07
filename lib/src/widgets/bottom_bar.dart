import 'package:flutter/material.dart';
import '../dsl/fx.dart';
import '../engine/style_resolver.dart';
import '../styles/fx_theme.dart';

class FxBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<FxBottomBarItem> items;
  final Color? activeColor;
  final Color? baseColor;
  final bool animate;
  final FxStyle? containerStyle;

  const FxBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.activeColor,
    this.baseColor,
    this.animate = true,
    this.containerStyle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = FxTheme.isDarkMode;
    
    final effectiveActive = activeColor != null ? FxStyleResolver.resolveColor(context, activeColor!) : Fx.primary;
    final effectiveBase = baseColor != null ? FxStyleResolver.resolveColor(context, baseColor!) : (isDark ? Colors.white70 : Colors.black54);

    return Fx.box(
      style: containerStyle ??
          FxStyle(
            padding: EdgeInsets.fromLTRB(
              8, 
              12, 
              8, 
              MediaQuery.paddingOf(context).bottom > 0 ? MediaQuery.paddingOf(context).bottom + 8 : 12
            ),
            backgroundColor: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.95),
            glass: 20.0,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05), width: 1)),
            shadows: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isActive = index == currentIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Subtle Active Background
                  AnimatedContainer(
                    duration: animate ? const Duration(milliseconds: 400) : Duration.zero,
                    curve: Curves.easeOutBack,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive 
                          ? effectiveActive.withValues(alpha: 0.1) 
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isActive && item.activeIconWidget != null)
                          item.activeIconWidget!
                        else if (item.iconWidget != null)
                          item.iconWidget!
                        else if (item.icon != null)
                          Icon(
                            isActive ? (item.activeIcon ?? item.icon) : item.icon,
                            color: isActive ? effectiveActive : effectiveBase,
                            size: 24,
                          )
                        else
                          const SizedBox(width: 24, height: 24),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: isActive ? effectiveActive : effectiveBase,
                            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class FxBottomBarItem {
  final IconData? icon;
  final IconData? activeIcon;
  final Widget? iconWidget;
  final Widget? activeIconWidget;
  final String label;

  const FxBottomBarItem({
    this.icon,
    required this.label,
    this.activeIcon,
    this.iconWidget,
    this.activeIconWidget,
  });
}
