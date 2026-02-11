import 'package:flutter/widgets.dart';
import '../responsive/responsive_engine.dart';
import '../responsive/breakpoint_resolver.dart';

/// The core styling system for Fluxy.
/// Inspired by CSS/Tailwind, designed for Flutter.
class FxStyle {
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final Gradient? gradient;
  final List<BoxShadow>? shadows;
  final double? glass;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  
  // Layout direction
  final Axis? direction;
  
  // Flexbox Properties
  final MainAxisAlignment? justifyContent;
  final CrossAxisAlignment? alignItems;
  final MainAxisSize? mainAxisSize;
  final int? flex;
  final int? flexGrow;
  final int? flexShrink;
  final double? gap;
  final FlexFit? flexFit;

  // Grid Properties
  final int? crossAxisCount;
  final double? minColumnWidth;
  final double? childAspectRatio;

  // Stack/Positioning
  final AlignmentGeometry? alignment;
  final Clip? clipBehavior;
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;
  final double? zIndex;

  // Text Properties
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final String? fontFamily;
  final TextOverflow? overflow;
  final int? maxLines;
  final double? letterSpacing;
  final double? height_multiplier; // line-height

  // Interactive Styles
  final FxStyle? hover;
  final FxStyle? pressed;
  final Duration? transition;

  // Utilities
  final MouseCursor? cursor;
  final double? opacity;
  final double? aspectRatio;

  const FxStyle({
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.gradient,
    this.shadows,
    this.glass,
    this.borderRadius,
    this.border,
    this.justifyContent,
    this.alignItems,
    this.mainAxisSize,
    this.flex,
    this.flexGrow,
    this.flexShrink,
    this.gap,
    this.crossAxisCount,
    this.minColumnWidth,
    this.childAspectRatio,
    this.alignment,
    this.clipBehavior,
    this.top,
    this.right,
    this.bottom,
    this.left,
    this.zIndex,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.textAlign,
    this.fontFamily,
    this.overflow,
    this.maxLines,
    this.letterSpacing,
    this.height_multiplier,
    this.hover,
    this.pressed,
    this.transition,
    this.flexFit,
    this.direction,
    this.cursor,
    this.opacity,
    this.aspectRatio,
  });

  /// An empty style object.
  static const none = FxStyle();

  /// Merges this style with another FxStyle.
  FxStyle copyWith(FxStyle? other) {
    if (other == null) return this;
    return FxStyle(
      width: other.width ?? width,
      height: other.height ?? height,
      padding: other.padding ?? padding,
      margin: other.margin ?? margin,
      backgroundColor: other.backgroundColor ?? backgroundColor,
      gradient: other.gradient ?? gradient,
      shadows: other.shadows ?? shadows,
      glass: other.glass ?? glass,
      borderRadius: other.borderRadius ?? borderRadius,
      border: other.border ?? border,
      justifyContent: other.justifyContent ?? justifyContent,
      alignItems: other.alignItems ?? alignItems,
      mainAxisSize: other.mainAxisSize ?? mainAxisSize,
      direction: other.direction ?? direction,
      flex: other.flex ?? flex,
      flexGrow: other.flexGrow ?? flexGrow,
      flexShrink: other.flexShrink ?? flexShrink,
      gap: other.gap ?? gap,
      flexFit: other.flexFit ?? flexFit,
      crossAxisCount: other.crossAxisCount ?? crossAxisCount,
      minColumnWidth: other.minColumnWidth ?? minColumnWidth,
      childAspectRatio: other.childAspectRatio ?? childAspectRatio,
      alignment: other.alignment ?? alignment,
      clipBehavior: other.clipBehavior ?? clipBehavior,
      top: other.top ?? top,
      right: other.right ?? right,
      bottom: other.bottom ?? bottom,
      left: other.left ?? left,
      zIndex: other.zIndex ?? zIndex,
      color: other.color ?? color,
      fontSize: other.fontSize ?? fontSize,
      fontWeight: other.fontWeight ?? fontWeight,
      textAlign: other.textAlign ?? textAlign,
      fontFamily: other.fontFamily ?? fontFamily,
      overflow: other.overflow ?? overflow,
      maxLines: other.maxLines ?? maxLines,
      letterSpacing: other.letterSpacing ?? letterSpacing,
      height_multiplier: other.height_multiplier ?? height_multiplier,
      hover: other.hover ?? hover,
      pressed: other.pressed ?? pressed,
      transition: other.transition ?? transition,
      cursor: other.cursor ?? cursor,
      opacity: other.opacity ?? opacity,
      aspectRatio: other.aspectRatio ?? aspectRatio,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FxStyle &&
          runtimeType == other.runtimeType &&
          width == other.width &&
          height == other.height &&
          padding == other.padding &&
          margin == other.margin &&
          backgroundColor == other.backgroundColor &&
          gradient == other.gradient &&
          shadows == other.shadows &&
          glass == other.glass &&
          borderRadius == other.borderRadius &&
          border == other.border &&
          justifyContent == other.justifyContent &&
          alignItems == other.alignItems &&
          mainAxisSize == other.mainAxisSize &&
          flex == other.flex &&
          flexGrow == other.flexGrow &&
          flexShrink == other.flexShrink &&
          gap == other.gap &&
          crossAxisCount == other.crossAxisCount &&
          minColumnWidth == other.minColumnWidth &&
          childAspectRatio == other.childAspectRatio &&
          alignment == other.alignment &&
          clipBehavior == other.clipBehavior &&
          top == other.top &&
          right == other.right &&
          bottom == other.bottom &&
          left == other.left &&
          zIndex == other.zIndex &&
          color == other.color &&
          fontSize == other.fontSize &&
          fontWeight == other.fontWeight &&
          textAlign == other.textAlign &&
          fontFamily == other.fontFamily &&
          overflow == other.overflow &&
          maxLines == other.maxLines &&
          letterSpacing == other.letterSpacing &&
          height_multiplier == other.height_multiplier &&
          hover == other.hover &&
          pressed == other.pressed &&
          transition == other.transition &&
          flexFit == other.flexFit &&
          direction == other.direction &&
          cursor == other.cursor &&
          opacity == other.opacity &&
          aspectRatio == other.aspectRatio;

  @override
  int get hashCode =>
      width.hashCode ^
      height.hashCode ^
      padding.hashCode ^
      margin.hashCode ^
      backgroundColor.hashCode ^
      gradient.hashCode ^
      shadows.hashCode ^
      glass.hashCode ^
      borderRadius.hashCode ^
      border.hashCode ^
      justifyContent.hashCode ^
      alignItems.hashCode ^
      mainAxisSize.hashCode ^
      flex.hashCode ^
      flexGrow.hashCode ^
      flexShrink.hashCode ^
      gap.hashCode ^
      crossAxisCount.hashCode ^
      minColumnWidth.hashCode ^
      childAspectRatio.hashCode ^
      alignment.hashCode ^
      clipBehavior.hashCode ^
      top.hashCode ^
      right.hashCode ^
      bottom.hashCode ^
      left.hashCode ^
      zIndex.hashCode ^
      color.hashCode ^
      fontSize.hashCode ^
      fontWeight.hashCode ^
      textAlign.hashCode ^
      fontFamily.hashCode ^
      overflow.hashCode ^
      maxLines.hashCode ^
      letterSpacing.hashCode ^
      height_multiplier.hashCode ^
      hover.hashCode ^
      pressed.hashCode ^
      transition.hashCode ^
      flexFit.hashCode ^
      direction.hashCode ^
      cursor.hashCode ^
      opacity.hashCode ^
      aspectRatio.hashCode;
}

/// A container for responsive styles.
class FxResponsiveStyle {
  final FxStyle xs;
  final FxStyle? sm;
  final FxStyle? md;
  final FxStyle? lg;
  final FxStyle? xl;

  const FxResponsiveStyle({
    required this.xs,
    this.sm,
    this.md,
    this.lg,
    this.xl,
  });

  FxStyle resolve(BuildContext context) {
    final breakpoint = ResponsiveEngine.of(context);
    return BreakpointResolver.resolve(this, breakpoint);
  }
}
