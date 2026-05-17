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
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? const Color(0xFF0F172A) // Premium Dark Slate for active state
                      : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
                  borderRadius: BorderRadius.circular(999), // Clean Pill Shape
                  border: Border.all(
                    color: isSelected 
                        ? const Color(0xFF0F172A) 
                        : (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0)),
                    width: 1.5,
                  ),
                  boxShadow: [],
                ),
                child: Fx.text(tab).style(
                  FxStyle(
                    color: isSelected 
                        ? Colors.white
                        : Fx.textColor.withValues(alpha: 0.6),
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    letterSpacing: 0.2,
                    fontSize: 15,
                  ),
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
