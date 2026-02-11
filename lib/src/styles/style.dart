import 'package:flutter/widgets.dart';
import '../responsive/responsive_engine.dart';
import '../responsive/breakpoint_resolver.dart';

/// A production-grade styling system inspired by CSS.
class Style {
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

  // Text Properties
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final String? fontFamily;
  final TextOverflow? overflow;
  final int? maxLines;

  // Interactive Styles
  final Style? hover;
  final Style? pressed;

  const Style({
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
    this.color,
    this.fontSize,
    this.fontWeight,
    this.textAlign,
    this.fontFamily,
    this.overflow,
    this.maxLines,
    this.hover,
    this.pressed,
    this.transition,
    this.flexFit,
    this.direction,
  });

  // Animation
  final Duration? transition;

  /// Merges this style with another.
  Style copyWith(Style? other) {
    if (other == null) return this;
    return Style(
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
      color: other.color ?? color,
      fontSize: other.fontSize ?? fontSize,
      fontWeight: other.fontWeight ?? fontWeight,
      textAlign: other.textAlign ?? textAlign,
      fontFamily: other.fontFamily ?? fontFamily,
      overflow: other.overflow ?? overflow,
      maxLines: other.maxLines ?? maxLines,
      hover: other.hover ?? hover,
      pressed: other.pressed ?? pressed,
      transition: other.transition ?? transition,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Style &&
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
          color == other.color &&
          fontSize == other.fontSize &&
          fontWeight == other.fontWeight &&
          textAlign == other.textAlign &&
          fontFamily == other.fontFamily &&
          overflow == other.overflow &&
          maxLines == other.maxLines &&
          hover == other.hover &&
          pressed == other.pressed &&
          transition == other.transition &&
          flexFit == other.flexFit &&
          direction == other.direction;

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
      color.hashCode ^
      fontSize.hashCode ^
      fontWeight.hashCode ^
      textAlign.hashCode ^
      fontFamily.hashCode ^
      overflow.hashCode ^
      maxLines.hashCode ^
      hover.hashCode ^
      pressed.hashCode ^
      transition.hashCode ^
      flexFit.hashCode ^
      direction.hashCode;
}

/// A container for responsive styles.
class ResponsiveStyle {
  final Style xs;
  final Style? sm;
  final Style? md;
  final Style? lg;
  final Style? xl;

  const ResponsiveStyle({
    required this.xs,
    this.sm,
    this.md,
    this.lg,
    this.xl,
  });

  Style resolve(BuildContext context) {
    final breakpoint = ResponsiveEngine.of(context);
    return BreakpointResolver.resolve(this, breakpoint);
  }
}
