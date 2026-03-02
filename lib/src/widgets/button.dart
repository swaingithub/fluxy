import 'package:flutter/material.dart';
import '../styles/tokens.dart';
import '../dsl/fx.dart';
import 'box.dart';
import '../widgets/fx_widget.dart';
import '../engine/style_resolver.dart';

enum FxButtonVariant {
  primary,
  secondary,
  danger,
  warning,
  success,
  text,
  ghost,
  outline,
  none, // New: Completely unstyled variant
}

enum FxButtonSize { xs, sm, md, lg, xl, none } // New: 'none' size

class FxButton extends FxWidget {
  final String? label; // Now optional if child is provided
  final Widget? child; // New: Custom child support
  final VoidCallback? onTap;
  final FxButtonVariant variant;
  final FxButtonSize size;
  final bool isRounded;
  @override
  final FxStyle style;
  @override
  final FxResponsiveStyle? responsive;
  final Widget? icon;
  final Widget? trailingIcon;
  final bool isLoading;

  const FxButton({
    super.key,
    super.id,
    super.className,
    this.label,
    this.child,
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

  @override
  FxButton copyWithStyle(FxStyle additionalStyle) {
    return copyWith(style: style.merge(additionalStyle));
  }

  @override
  FxButton copyWithResponsive(FxResponsiveStyle additionalResponsive) {
    return copyWith(
      responsive: responsive?.merge(additionalResponsive) ?? additionalResponsive,
    );
  }

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
  FxButton get warning => copyWith(variant: FxButtonVariant.warning);
  FxButton get success => copyWith(variant: FxButtonVariant.success);
  FxButton get ghost => copyWith(variant: FxButtonVariant.ghost);
  FxButton get outline => copyWith(variant: FxButtonVariant.outline);
  FxButton get text => copyWith(variant: FxButtonVariant.text);
  FxButton get none => copyWith(variant: FxButtonVariant.none);

  FxButton withChild(Widget child) => copyWith(child: child);

  FxButton loading([bool value = true]) => copyWith(isLoading: value);

  FxButton withIcon(Widget icon) => copyWith(icon: icon);
  FxButton withTrailing(Widget icon) => copyWith(trailingIcon: icon);

  FxButton fullWidth() =>
      copyWith(style: style.merge(const FxStyle(width: double.infinity)));

  FxButton shadowSm() =>
      copyWith(style: style.merge(FxStyle(shadows: FxTokens.shadow.sm)));
  FxButton shadowMd() =>
      copyWith(style: style.merge(FxStyle(shadows: FxTokens.shadow.md)));
  FxButton shadowLg() =>
      copyWith(style: style.merge(FxStyle(shadows: FxTokens.shadow.lg)));

  FxButton bg(Color color) =>
      copyWith(style: style.merge(FxStyle(backgroundColor: color)));
  FxButton textColor(Color color) =>
      copyWith(style: style.merge(FxStyle(color: color)));

  /// Merges a custom style object
  FxButton applyStyle(FxStyle s) => copyWith(style: style.merge(s));

  FxButton copyWith({
    String? label,
    Widget? child,
    VoidCallback? onTap,
    FxButtonVariant? variant,
    FxButtonSize? size,
    bool? isRounded,
    FxStyle? style,
    FxResponsiveStyle? responsive,
    Widget? icon,
    Widget? trailingIcon,
    bool? isLoading,
    String? className,
  }) {
    return FxButton(
      key: key,
      id: id,
      className: className ?? this.className,
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
      child: child ?? this.child,
    );
  }

  @override
  State<FxButton> createState() => _FxButtonState();
}

class _FxButtonState extends State<FxButton> {
  @override
  Widget build(BuildContext context) {
    // 1. Resolve Brand Colors (Base)
    Color brandColor;
    Color onBrandColor;
    Color? borderColor;

    switch (widget.variant) {
      case FxButtonVariant.primary:
        brandColor = FxTokens.colors.primary;
        onBrandColor = FxTokens.colors.white; // Or onPrimary if available
        break;
      case FxButtonVariant.none:
        brandColor = Colors.transparent;
        onBrandColor = FxTokens.colors.text;
        break;
      case FxButtonVariant.secondary:
        brandColor = FxTokens.colors.secondary;
        onBrandColor = FxTokens.colors.black; // Secondary usually needs contrast
        break;
      case FxButtonVariant.danger:
        brandColor = FxTokens.colors.error;
        onBrandColor = FxTokens.colors.white;
        break;
      case FxButtonVariant.success:
        brandColor = FxTokens.colors.success;
        onBrandColor = FxTokens.colors.white;
        break;
      case FxButtonVariant.warning:
        brandColor = FxTokens.colors.warning;
        onBrandColor = FxTokens.colors.white;
        break;
      case FxButtonVariant.outline:
        brandColor = Colors.transparent;
        borderColor = FxTokens.colors.muted;
        onBrandColor = FxTokens.colors.text;
        break;
      case FxButtonVariant.ghost:
        brandColor = Colors.transparent;
        onBrandColor = FxTokens.colors.text;
        break;
      case FxButtonVariant.text:
        brandColor = Colors.transparent;
        onBrandColor = FxTokens.colors.primary;
        break;
    }

    // 2. Resolve Size Tokens
    double fontSize;
    double iconSize;
    EdgeInsets padding;
    double height;

    switch (widget.size) {
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
      case FxButtonSize.none:
        fontSize = 14;
        iconSize = 18;
        padding = EdgeInsets.zero;
        height = 0; // Will be overridden if style.height exists
        break;
    }

    // 3. Construct Composite Style
    final baseStyle = FxStyle(
      minHeight: height > 0 ? height : null,
      backgroundColor: brandColor,
      padding: padding,
      borderRadius: widget.variant == FxButtonVariant.none 
          ? null 
          : BorderRadius.circular(widget.isRounded ? 9999 : 10),
      border: borderColor != null
          ? Border.all(color: borderColor, width: 1)
          : null,
      transition: const Duration(milliseconds: 150),
      // alignment removed to prevent vertical stretching in Columns
      cursor: SystemMouseCursors.click,
      justifyContent: MainAxisAlignment.center, // New: Use style-level centering
      alignItems: CrossAxisAlignment.center,
      direction: Axis.vertical, // Ensure children are vertically centered if height is given
      hover:
          widget.variant == FxButtonVariant.ghost || widget.variant == FxButtonVariant.outline || widget.variant == FxButtonVariant.none
          ? FxStyle(
              backgroundColor: brandColor == Colors.transparent || widget.variant == FxButtonVariant.none
                  ? FxTokens.colors.slate50
                  : brandColor.withValues(alpha: 0.9),
            )
          : const FxStyle(opacity: 0.9),
      pressed: const FxStyle(opacity: 0.7, shadows: []),
    ).merge(widget.style);

    // 4. Build Content Layout
    final isFullWidth = baseStyle.width == double.infinity;
    
    Widget? content = widget.child;
    
    content ??= Fx.row(
        size: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        justify: MainAxisAlignment.center, // Horizontal centering
        alignItems: CrossAxisAlignment.center, // Vertical centering
        gap: 8,
        children: [
          if (widget.isLoading)
            SizedBox(
              width: iconSize,
              height: iconSize,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  FxStyleResolver.resolveColor(context, onBrandColor),
                ),
              ),
            )
          else if (widget.icon != null)
            widget.icon!,

          Fx.text(
            widget.label ?? '',
            style: FxStyle(
              color: onBrandColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),

          if (!widget.isLoading && widget.trailingIcon != null) widget.trailingIcon!,
        ],
      );

    // 5. Build with Box (handles hover/pressed/responsive automatically)
    return Box(
      id: widget.id,
      className: widget.className,
      style: baseStyle,
      responsive: widget.responsive,
      onTap: widget.isLoading ? null : widget.onTap,
      child: content,
    );
  }
}
