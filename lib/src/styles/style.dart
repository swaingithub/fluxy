import 'package:flutter/widgets.dart';
import '../responsive/responsive_engine.dart';
import '../responsive/breakpoint_resolver.dart';

/// The core styling system for Fluxy.
/// Inspired by CSS/Tailwind, designed for Flutter.
class FxStyle {
  final double? width;
  final double? height;
  final EdgeInsets padding;
  final EdgeInsets margin;
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
  final double? lineHeight; // line-height

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
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
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
    this.lineHeight,
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

  /// Creates a copy of this style with the given fields replaced.
  FxStyle copyWith({
    double? width,
    double? height,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? backgroundColor,
    Gradient? gradient,
    List<BoxShadow>? shadows,
    double? glass,
    BorderRadius? borderRadius,
    BoxBorder? border,
    Axis? direction,
    MainAxisAlignment? justifyContent,
    CrossAxisAlignment? alignItems,
    MainAxisSize? mainAxisSize,
    int? flex,
    int? flexGrow,
    int? flexShrink,
    double? gap,
    FlexFit? flexFit,
    int? crossAxisCount,
    double? minColumnWidth,
    double? childAspectRatio,
    AlignmentGeometry? alignment,
    Clip? clipBehavior,
    double? top,
    double? right,
    double? bottom,
    double? left,
    double? zIndex,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    String? fontFamily,
    TextOverflow? overflow,
    int? maxLines,
    double? letterSpacing,
    double? lineHeight,
    FxStyle? hover,
    FxStyle? pressed,
    Duration? transition,
    MouseCursor? cursor,
    double? opacity,
    double? aspectRatio,
  }) {
    return FxStyle(
      width: width ?? this.width,
      height: height ?? this.height,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      gradient: gradient ?? this.gradient,
      shadows: shadows ?? this.shadows,
      glass: glass ?? this.glass,
      borderRadius: borderRadius ?? this.borderRadius,
      border: border ?? this.border,
      justifyContent: justifyContent ?? this.justifyContent,
      alignItems: alignItems ?? this.alignItems,
      mainAxisSize: mainAxisSize ?? this.mainAxisSize,
      direction: direction ?? this.direction,
      flex: flex ?? this.flex,
      flexGrow: flexGrow ?? this.flexGrow,
      flexShrink: flexShrink ?? this.flexShrink,
      gap: gap ?? this.gap,
      flexFit: flexFit ?? this.flexFit,
      crossAxisCount: crossAxisCount ?? this.crossAxisCount,
      minColumnWidth: minColumnWidth ?? this.minColumnWidth,
      childAspectRatio: childAspectRatio ?? this.childAspectRatio,
      alignment: alignment ?? this.alignment,
      clipBehavior: clipBehavior ?? this.clipBehavior,
      top: top ?? this.top,
      right: right ?? this.right,
      bottom: bottom ?? this.bottom,
      left: left ?? this.left,
      zIndex: zIndex ?? this.zIndex,
      color: color ?? this.color,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      textAlign: textAlign ?? this.textAlign,
      fontFamily: fontFamily ?? this.fontFamily,
      overflow: overflow ?? this.overflow,
      maxLines: maxLines ?? this.maxLines,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      lineHeight: lineHeight ?? this.lineHeight,
      hover: hover ?? this.hover,
      pressed: pressed ?? this.pressed,
      transition: transition ?? this.transition,
      cursor: cursor ?? this.cursor,
      opacity: opacity ?? this.opacity,
      aspectRatio: aspectRatio ?? this.aspectRatio,
    );
  }

  /// Merges this style with another FxStyle.
  FxStyle merge(FxStyle? other) {
    if (other == null) return this;
    return copyWith(
      width: other.width,
      height: other.height,
      padding: other.padding == EdgeInsets.zero ? null : other.padding,
      margin: other.margin == EdgeInsets.zero ? null : other.margin,
      backgroundColor: other.backgroundColor,
      gradient: other.gradient,
      shadows: other.shadows,
      glass: other.glass,
      borderRadius: other.borderRadius,
      border: other.border,
      justifyContent: other.justifyContent,
      alignItems: other.alignItems,
      mainAxisSize: other.mainAxisSize,
      direction: other.direction,
      flex: other.flex,
      flexGrow: other.flexGrow,
      flexShrink: other.flexShrink,
      gap: other.gap,
      flexFit: other.flexFit,
      crossAxisCount: other.crossAxisCount,
      minColumnWidth: other.minColumnWidth,
      childAspectRatio: other.childAspectRatio,
      alignment: other.alignment,
      clipBehavior: other.clipBehavior,
      top: other.top,
      right: other.right,
      bottom: other.bottom,
      left: other.left,
      zIndex: other.zIndex,
      color: other.color,
      fontSize: other.fontSize,
      fontWeight: other.fontWeight,
      textAlign: other.textAlign,
      fontFamily: other.fontFamily,
      overflow: other.overflow,
      maxLines: other.maxLines,
      letterSpacing: other.letterSpacing,
      lineHeight: other.lineHeight,
      hover: other.hover,
      pressed: other.pressed,
      transition: other.transition,
      cursor: other.cursor,
      opacity: other.opacity,
      aspectRatio: other.aspectRatio,
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
          lineHeight == other.lineHeight &&
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
      lineHeight.hashCode ^
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
    this.xs = FxStyle.none,
    this.sm,
    this.md,
    this.lg,
    this.xl,
  });

  FxStyle resolve(BuildContext context) {
    final breakpoint = ResponsiveEngine.of(context);
    return BreakpointResolver.resolve(this, breakpoint);
  }

  /// Merges this responsive style with another.
  FxResponsiveStyle merge(FxResponsiveStyle? other) {
    if (other == null) return this;
    return FxResponsiveStyle(
      xs: xs.merge(other.xs),
      sm: sm?.merge(other.sm) ?? other.sm ?? sm,
      md: md?.merge(other.md) ?? other.md ?? md,
      lg: lg?.merge(other.lg) ?? other.lg ?? lg,
      xl: xl?.merge(other.xl) ?? other.xl ?? xl,
    );
  }

  /// Creates a responsive style from individual builders.
  factory FxResponsiveStyle.from({
    FxStyle Function(FxStyle s)? xs,
    FxStyle Function(FxStyle s)? sm,
    FxStyle Function(FxStyle s)? md,
    FxStyle Function(FxStyle s)? lg,
    FxStyle Function(FxStyle s)? xl,
  }) {
    return FxResponsiveStyle(
      xs: xs != null ? xs(FxStyle.none) : FxStyle.none,
      sm: sm != null ? sm(FxStyle.none) : null,
      md: md != null ? md(FxStyle.none) : null,
      lg: lg != null ? lg(FxStyle.none) : null,
      xl: xl != null ? xl(FxStyle.none) : null,
    );
  }
}
