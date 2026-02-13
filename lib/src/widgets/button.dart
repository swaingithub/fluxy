import 'package:flutter/material.dart';
import '../styles/tokens.dart';
import '../dsl/fx.dart';

enum FxButtonVariant { primary, secondary, text }
enum FxButtonSize { sm, md, lg }

class FxButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final FxButtonVariant variant;
  final FxButtonSize size;
  final bool isOutline;
  final bool isRounded;
  final FxStyle style;
  final Widget? icon;

  const FxButton({
    super.key,
    required this.label,
    this.onTap,
    this.variant = FxButtonVariant.primary,
    this.size = FxButtonSize.md,
    this.isOutline = false,
    this.isRounded = false,
    this.style = FxStyle.none,
    this.icon,
  });

  // --- Chaining Modifiers ---
  
  // --- Chaining Modifiers ---
  
  FxButton get outline => copyWith(isOutline: true);
  FxButton get rounded => copyWith(isRounded: true);
  
  FxButton sizeSmall() => copyWith(size: FxButtonSize.sm);
  FxButton sizeMedium() => copyWith(size: FxButtonSize.md);
  FxButton sizeLarge() => copyWith(size: FxButtonSize.lg);

  FxButton get primary => copyWith(variant: FxButtonVariant.primary);
  FxButton secondary() => copyWith(variant: FxButtonVariant.secondary);
  FxButton get text => copyWith(variant: FxButtonVariant.text);

  FxButton fullWidth() => copyWith(style: style.merge(const FxStyle(width: double.infinity)));
  
  FxButton shadowMedium() => copyWith(style: style.merge(FxStyle(shadows: FxTokens.shadow.md)));

  // Deprecated aliases? Or just keep for compatibility if previous code used them in the last few minutes.
  // The user prompt is about REDESIGN.
  
  /// Add a custom style
  FxButton setStyle(FxStyle s) => copyWith(style: style.merge(s));

  FxButton copyWith({
    String? label,
    VoidCallback? onTap,
    FxButtonVariant? variant,
    FxButtonSize? size,
    bool? isOutline,
    bool? isRounded,
    FxStyle? style,
    Widget? icon,
  }) {
    return FxButton(
      label: label ?? this.label,
      onTap: onTap ?? this.onTap,
      variant: variant ?? this.variant,
      size: size ?? this.size,
      isOutline: isOutline ?? this.isOutline,
      isRounded: isRounded ?? this.isRounded,
      style: style ?? this.style,
      icon: icon ?? this.icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Resolve Styles based on properties
    Color primaryColor = const Color(0xFF2563EB); // Default blue
    Color textColor = Colors.white;
    Color? borderColor;
    Color? bgColor = primaryColor;
    
    // Variant Logic
    switch (variant) {
      case FxButtonVariant.primary:
        bgColor = primaryColor;
        textColor = Colors.white;
        break;
      case FxButtonVariant.secondary:
        bgColor = const Color(0xFFE5E7EB);
        textColor = const Color(0xFF1F2937);
        break;
      case FxButtonVariant.text:
        bgColor = Colors.transparent;
        textColor = primaryColor;
        break;
    }

    // Outline Logic
    if (isOutline) {
      borderColor = (variant == FxButtonVariant.text) ?  primaryColor : bgColor;
      textColor = borderColor;
      bgColor = Colors.transparent;
    }

    // Size Logic
    double fontSize;
    EdgeInsets padding;
    switch (size) {
      case FxButtonSize.sm:
        fontSize = 12;
        padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
        break;
      case FxButtonSize.lg:
        fontSize = 18;
        padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
        break;  
      case FxButtonSize.md:
        fontSize = 14;
        padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
        break;
    }

    // Styles
    var finalStyle = FxStyle(
      padding: padding,
      backgroundColor: bgColor,
      border: borderColor != null ? Border.all(color: borderColor, width: 1.5) : null,
      borderRadius: BorderRadius.circular(isRounded ? 9999 : 8),
      alignment: Alignment.center,
      cursor: SystemMouseCursors.click,
    ).merge(style);

    // Text Content
    Widget content = Fx.text(label, style: FxStyle(
      color: textColor, 
      fontSize: fontSize, 
      fontWeight: FontWeight.w600
    ));
    
    if (icon != null) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          SizedBox(width: 8),
          content,
        ],
      );
    }
    
    // We use Fx.box (which uses Box) to render
    return Fx.box(
      style: finalStyle,
      onTap: onTap,
      child: content, 
      // Add hover effect standard?
      // Box supports interactions?
    );
  }
}
