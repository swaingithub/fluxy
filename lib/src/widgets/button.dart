import 'package:flutter/material.dart';
import '../styles/tokens.dart';
import '../dsl/fx.dart';
import 'box.dart';

enum FxButtonVariant { primary, secondary, danger, warning, success, text, ghost, outline }

enum FxButtonSize { xs, sm, md, lg, xl }

class FxButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final FxButtonVariant variant;
  final FxButtonSize size;
  final bool isRounded;
  final FxStyle style;
  final FxResponsiveStyle? responsive;
  final Widget? icon;
  final Widget? trailingIcon;
  final bool isLoading;

  const FxButton({
    super.key,
    required this.label,
    this.onTap,
    this.variant = FxButtonVariant.primary,
    this.size = FxButtonSize.md,
    this.isRounded = false,
    this.style = FxStyle.none,
    this.responsive,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
  });

  // --- Fluent Modifiers ---

  FxButton get rounded => copyWith(isRounded: true);
  FxButton get square => copyWith(isRounded: false);

  FxButton sizeXs() => copyWith(size: FxButtonSize.xs);
  FxButton sizeSm() => copyWith(size: FxButtonSize.sm);
  FxButton sizeMd() => copyWith(size: FxButtonSize.md);
  FxButton sizeLg() => copyWith(size: FxButtonSize.lg);
  FxButton sizeXl() => copyWith(size: FxButtonSize.xl);

  FxButton get primary => copyWith(variant: FxButtonVariant.primary);
  FxButton get secondary => copyWith(variant: FxButtonVariant.secondary);
  FxButton get danger => copyWith(variant: FxButtonVariant.danger);
  FxButton get success => copyWith(variant: FxButtonVariant.success);
  FxButton get ghost => copyWith(variant: FxButtonVariant.ghost);
  FxButton get outline => copyWith(variant: FxButtonVariant.outline);
  FxButton get text => copyWith(variant: FxButtonVariant.text);

  FxButton loading([bool value = true]) => copyWith(isLoading: value);

  FxButton withIcon(Widget icon) => copyWith(icon: icon);
  FxButton withTrailing(Widget icon) => copyWith(trailingIcon: icon);

  FxButton fullWidth() =>
      copyWith(style: style.merge(const FxStyle(width: double.infinity)));

  FxButton shadowSm() => copyWith(style: style.merge(FxStyle(shadows: FxTokens.shadow.sm)));
  FxButton shadowMd() => copyWith(style: style.merge(FxStyle(shadows: FxTokens.shadow.md)));
  FxButton shadowLg() => copyWith(style: style.merge(FxStyle(shadows: FxTokens.shadow.lg)));

  FxButton bg(Color color) => copyWith(style: style.merge(FxStyle(backgroundColor: color)));
  FxButton textColor(Color color) => copyWith(style: style.merge(FxStyle(color: color)));

  /// Merges a custom style object
  FxButton applyStyle(FxStyle s) => copyWith(style: style.merge(s));

  FxButton copyWith({
    String? label,
    VoidCallback? onTap,
    FxButtonVariant? variant,
    FxButtonSize? size,
    bool? isRounded,
    FxStyle? style,
    FxResponsiveStyle? responsive,
    Widget? icon,
    Widget? trailingIcon,
    bool? isLoading,
  }) {
    return FxButton(
      label: label ?? this.label,
      onTap: onTap ?? this.onTap,
      variant: variant ?? this.variant,
      size: size ?? this.size,
      isRounded: isRounded ?? this.isRounded,
      style: style ?? this.style,
      responsive: responsive ?? this.responsive,
      icon: icon ?? this.icon,
      trailingIcon: trailingIcon ?? this.trailingIcon,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Resolve Brand Colors (Base)
    Color brandColor;
    Color onBrandColor;
    Color? borderColor;

    switch (variant) {
      case FxButtonVariant.primary:
        brandColor = FxTokens.colors.blue600;
        onBrandColor = Colors.white;
        break;
      case FxButtonVariant.secondary:
        brandColor = FxTokens.colors.slate100;
        onBrandColor = FxTokens.colors.slate800;
        break;
      case FxButtonVariant.danger:
        brandColor = const Color(0xFFEF4444);
        onBrandColor = Colors.white;
        break;
      case FxButtonVariant.success:
        brandColor = const Color(0xFF10B981);
        onBrandColor = Colors.white;
        break;
      case FxButtonVariant.warning:
        brandColor = const Color(0xFFF59E0B);
        onBrandColor = Colors.white;
        break;
      case FxButtonVariant.outline:
        brandColor = Colors.transparent;
        borderColor = FxTokens.colors.slate300;
        onBrandColor = FxTokens.colors.slate700;
        break;
      case FxButtonVariant.ghost:
        brandColor = Colors.transparent;
        onBrandColor = FxTokens.colors.slate600;
        break;
      case FxButtonVariant.text:
        brandColor = Colors.transparent;
        onBrandColor = FxTokens.colors.blue600;
        break;
    }

    // 2. Resolve Size Tokens
    double fontSize;
    double iconSize;
    EdgeInsets padding;
    double height;

    switch (size) {
      case FxButtonSize.xs:
        fontSize = 12;
        iconSize = 14;
        padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4);
        height = 32;
        break;
      case FxButtonSize.sm:
        fontSize = 13;
        iconSize = 16;
        padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
        height = 36;
        break;
      case FxButtonSize.lg:
        fontSize = 16;
        iconSize = 20;
        padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
        height = 48;
        break;
      case FxButtonSize.xl:
        fontSize = 18;
        iconSize = 24;
        padding = const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
        height = 56;
        break;
      case FxButtonSize.md:
        fontSize = 14;
        iconSize = 18;
        padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
        height = 40;
        break;
    }

    // 3. Construct Composite Style
    final baseStyle = FxStyle(
      height: height,
      backgroundColor: brandColor,
      padding: padding,
      borderRadius: BorderRadius.circular(isRounded ? 9999 : 10),
      border: borderColor != null ? Border.all(color: borderColor, width: 1) : null,
      transition: const Duration(milliseconds: 150),
      // Implicit Interactivity
      hover: variant == FxButtonVariant.ghost || variant == FxButtonVariant.outline
          ? FxStyle(backgroundColor: brandColor == Colors.transparent ? FxTokens.colors.slate50 : brandColor.withValues(alpha: 0.9))
          : FxStyle(opacity: 0.9),
      pressed: const FxStyle(opacity: 0.7, shadows: []),
    ).merge(style);

    // 4. Build Content Layout
    Widget content = Fx.row(
      style: const FxStyle(mainAxisSize: MainAxisSize.min),
      gap: 8,
      children: [
        if (isLoading)
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(onBrandColor),
            ),
          )
        else if (icon != null)
          icon!,
        
        Fx.text(label, style: FxStyle(
          color: onBrandColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        )),

        if (!isLoading && trailingIcon != null) trailingIcon!,
      ],
    ).center();

    // 5. Build with Box (handles hover/pressed/responsive automatically)
    return Box(
      style: baseStyle,
      responsive: responsive,
      onTap: isLoading ? null : onTap,
      child: content,
    );
  }
}
