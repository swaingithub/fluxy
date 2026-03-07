import 'package:flutter/material.dart';
import '../dsl/fx.dart';
import '../engine/style_resolver.dart';
import '../styles/fx_theme.dart';

class FxSidebarItem {
  final IconData? icon;
  final Widget? iconWidget;
  final String label;
  final Widget? trailing;
  final bool isHeader;

  const FxSidebarItem({
    this.icon,
    required this.label,
    this.iconWidget,
    this.trailing,
    this.isHeader = false,
  });
}

class FxSidebar extends StatelessWidget {
  final int? currentIndex;
  final ValueChanged<int>? onTap;
  final List<FxSidebarItem> items;
  final Widget? header;
  final Widget? footer;
  final double width;
  final Color? activeColor;
  final Color? baseColor;
  final Color? backgroundColor;
  final FxStyle? style;

  const FxSidebar({
    required this.items,
    super.key,
    this.currentIndex,
    this.onTap,
    this.header,
    this.footer,
    this.width = 280,
    this.activeColor,
    this.baseColor,
    this.backgroundColor,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    // Rely on Fluxy's reactive theme signal for consistency with the engine
    final isDark = FxTheme.isDarkMode;

    final resolvedBackgroundColor = backgroundColor ??
        (isDark ? const Color(0xFF1E293B) : Colors.white);

    final effectiveActive = activeColor != null
        ? FxStyleResolver.resolveColor(context, activeColor!)
        : Fx.primary;

    final effectiveBase = baseColor != null
        ? FxStyleResolver.resolveColor(context, baseColor!)
        : (isDark ? Colors.white70 : Colors.black87);

    return Fx.box(
      style: FxStyle(
        width: width,
        height: double.infinity,
        backgroundColor: resolvedBackgroundColor,
        border: Border(
          right: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
          ),
        ),
      ).merge(style ?? FxStyle.none),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (header != null) header!,
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final item = items[index];

                  if (item.isHeader) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 12, top: 24, bottom: 8),
                      child: Text(
                        item.label.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white30 : Colors.black38,
                          letterSpacing: 0.5,
                        ),
                      ),
                    );
                  }

                  final isActive = index == currentIndex;
                  final activeBg = isDark ? effectiveActive.withValues(alpha: 0.15) : effectiveActive.withValues(alpha: 0.1);

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        if (onTap != null) onTap!(index);
                      },
                      hoverColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isActive ? activeBg : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isActive
                                ? effectiveActive.withValues(alpha: 0.2)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            if (item.iconWidget != null)
                              item.iconWidget!
                            else if (item.icon != null)
                              Icon(
                                item.icon,
                                color: isActive ? effectiveActive : effectiveBase,
                                size: 22,
                              ),
                            if (item.iconWidget != null || item.icon != null)
                              const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  color: isActive ? effectiveActive : effectiveBase,
                                  fontSize: 15,
                                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            if (item.trailing != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: item.trailing!,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (footer != null) footer!,
          ],
        ),
      ),
    );
  }
}
