import 'package:flutter/material.dart';
import '../styles/style.dart';
import '../widgets/box.dart';

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
    final effectiveActive = activeColor ?? Theme.of(context).primaryColor;
    final effectiveBase = baseColor ?? Colors.grey.shade400;

    return Box(
      style: containerStyle ?? FxStyle(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        backgroundColor: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        shadows: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isActive = index == currentIndex;

          return GestureDetector(
            onTap: () => onTap(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: animate ? const Duration(milliseconds: 300) : Duration.zero,
              curve: Curves.fastOutSlowIn,
              padding: isActive 
                  ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
                  : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? effectiveActive.withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                children: [
                  if (isActive && item.activeIconWidget != null) 
                    item.activeIconWidget!
                  else if (item.iconWidget != null)
                    IconTheme(
                      data: IconThemeData(
                        color: isActive ? effectiveActive : effectiveBase,
                        size: 24
                      ),
                      child: item.iconWidget!,
                    )
                  else if (item.icon != null)
                    Icon(
                      isActive ? (item.activeIcon ?? item.icon) : item.icon,
                      color: isActive ? effectiveActive : effectiveBase,
                      size: 24,
                    )
                  else 
                    const SizedBox(width: 24, height: 24),

                  
                  if (isActive) ...[
                    const SizedBox(width: 8),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: effectiveActive,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
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
