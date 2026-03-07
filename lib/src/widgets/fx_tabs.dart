import 'package:flutter/material.dart';
import '../dsl/fx.dart';
import '../reactive/signal.dart';
import '../styles/fx_theme.dart';

/// A reactive tab bar for Fluxy.
class FxTabBar extends StatelessWidget {
  final Flux<int> currentIndex;
  final List<String> tabs;
  final ValueChanged<int>? onChanged;
  final EdgeInsetsGeometry padding;

  const FxTabBar({
    super.key,
    required this.currentIndex,
    required this.tabs,
    this.onChanged,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;

          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Fx(() {
            final isSelected = currentIndex.value == index;
            final isDark = FxTheme.isDarkMode;
            
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                currentIndex.value = index;
                onChanged?.call(index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05))
                      : Colors.transparent,
                  // Asymmetrical / leaf border radius when active for a unique look
                  borderRadius: isSelected 
                      ? const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                          topRight: Radius.circular(6),
                          bottomLeft: Radius.circular(6),
                        )
                      : BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? Fx.primary.withValues(alpha: 0.9) 
                        : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.08)),
                    width: 1.5,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: Fx.primary.withValues(alpha: 0.25),
                      blurRadius: 16,
                      spreadRadius: 2,
                      offset: const Offset(4, 4),
                    )
                  ] : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Expanding tiny glowing dot indicator
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      width: isSelected ? 8 : 0,
                      height: 8,
                      margin: EdgeInsets.only(right: isSelected ? 10 : 0),
                      decoration: BoxDecoration(
                        color: Fx.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Fx.primary,
                            blurRadius: 8,
                            spreadRadius: 2,
                          )
                        ]
                      ),
                    ),
                    Fx.text(tab).style(
                      FxStyle(
                        color: isSelected 
                            ? (isDark ? Colors.white : Fx.primary.withOpacity(0.9)) 
                            : Fx.textColor.withValues(alpha: 0.6),
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                        letterSpacing: 0.5,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          );
        }).toList(),
      ),
    );
  }
}

/// A reactive tab view for Fluxy that preserves UI state and avoids rebuilding.
class FxTabView extends StatelessWidget {
  final Flux<int> currentIndex;
  final List<Widget> children;

  const FxTabView({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Fx(() {
      return IndexedStack(
        index: currentIndex.value,
        children: children,
      );
    });
  }
}
