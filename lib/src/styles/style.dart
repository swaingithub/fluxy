import 'package:flutter/widgets.dart';
import '../responsive/responsive_engine.dart';
import '../responsive/breakpoint_resolver.dart';

/// The core styling system for Fluxy.
/// Inspired by CSS/Tailwind, designed for Flutter.
class FxStyle {
  final double? _width;
  final double? _height;
  final EdgeInsets? _padding;
  final EdgeInsets? _margin;
  final Color? backgroundColor;
  final Gradient? gradient;
  final List<BoxShadow>? _shadows;
  final double? glass;
  final BorderRadius? _borderRadius;
  final BoxBorder? border;

  // Layout direction
  final Axis? direction;

  // Flexbox Properties
  final MainAxisAlignment? _justifyContent;
  final CrossAxisAlignment? _alignItems;
  final MainAxisSize? mainAxisSize;
  final int? flex;
  final int? flexGrow;
  final int? flexShrink;
  final double? _gap;
  final FlexFit? flexFit;

  // Grid Properties
  final int? _crossAxisCount;
  final double? minColumnWidth;
  final double? childAspectRatio;

  // Stack/Positioning
  final AlignmentGeometry? _alignment;
  final Clip? clipBehavior;
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;
  final double? zIndex;

  // Text Properties
  final Color? _color;
  final double? _fontSize;
  final FontWeight? _fontWeight;
  final TextAlign? _textAlign;
  final String? fontFamily;
  final TextOverflow? overflow;
  final int? maxLines;
  final double? letterSpacing;
  final double? wordSpacing;
  final TextDecoration? textDecoration;
  final double? lineHeight; // line-height

  // Interactive Styles
  final FxStyle? hover;
  final FxStyle? pressed;
  final Duration? transition;

  // Image Specific
  final String? imageSrc;
  final BoxFit? fit;
  final double? imageBlur;
  final bool? grayscale;
  final Widget? loading;
  final Widget? error;
  final Widget? placeholder;

  // Utilities
  final MouseCursor? cursor;
  final double? _opacity;
  final double? aspectRatio;
  final double? transformScale;
  final double? transformRotation;

  const FxStyle({
    double? width,
    double? height,
    EdgeInsets? padding,
    EdgeInsets? margin,
    this.backgroundColor,
    this.gradient,
    List<BoxShadow>? shadows,
    this.glass,
    BorderRadius? borderRadius,
    this.border,
    MainAxisAlignment? justifyContent,
    CrossAxisAlignment? alignItems,
    this.mainAxisSize,
    this.flex,
    this.flexGrow,
    this.flexShrink,
    double? gap,
    this.flexFit,
    int? crossAxisCount,
    this.minColumnWidth,
    this.childAspectRatio,
    AlignmentGeometry? alignment,
    this.clipBehavior,
    this.top,
    this.right,
    this.bottom,
    this.left,
    this.zIndex,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    this.fontFamily,
    this.overflow,
    this.maxLines,
    this.letterSpacing,
    this.wordSpacing,
    this.textDecoration,
    this.lineHeight,
    this.hover,
    this.pressed,
    this.transition,
    this.direction,
    this.cursor,
    double? opacity,
    this.aspectRatio,
    this.transformScale,
    this.transformRotation,
    this.fit,
    this.imageBlur,
    this.grayscale,
    this.loading,
    this.error,
    this.placeholder,
    this.imageSrc,
  })  : _width = width,
        _height = height,
        _padding = padding,
        _margin = margin,
        _shadows = shadows,
        _borderRadius = borderRadius,
        _justifyContent = justifyContent,
        _alignItems = alignItems,
        _gap = gap,
        _crossAxisCount = crossAxisCount,
        _alignment = alignment,
        _color = color,
        _fontSize = fontSize,
        _fontWeight = fontWeight,
        _textAlign = textAlign,
        _opacity = opacity;

  /// Getters to maintain compatibility
  double? get width => _width;
  double? get height => _height;
  EdgeInsets get padding => _padding ?? EdgeInsets.zero;
  EdgeInsets get margin => _margin ?? EdgeInsets.zero;
  List<BoxShadow>? get shadows => _shadows;
  BorderRadius? get borderRadius => _borderRadius;
  MainAxisAlignment? get justifyContent => _justifyContent;
  CrossAxisAlignment? get alignItems => _alignItems;
  double? get gap => _gap;
  int? get crossAxisCount => _crossAxisCount;
  AlignmentGeometry? get alignment => _alignment;
  Color? get color => _color;
  double? get fontSize => _fontSize;
  FontWeight? get fontWeight => _fontWeight;
  TextAlign? get textAlign => _textAlign;
  double? get opacity => _opacity;

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
    double? wordSpacing,
    TextDecoration? textDecoration,
    double? lineHeight,
    FxStyle? hover,
    FxStyle? pressed,
    Duration? transition,
    MouseCursor? cursor,
    double? opacity,
    double? aspectRatio,
    double? transformScale,
    double? transformRotation,
    BoxFit? fit,
    double? imageBlur,
    bool? grayscale,
    Widget? loading,
    Widget? error,
    Widget? placeholder,
    String? imageSrc,
  }) {
    return FxStyle(
      width: width ?? this.width,
      height: height ?? this.height,
      padding: padding ?? _padding,
      margin: margin ?? _margin,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      gradient: gradient ?? this.gradient,
      shadows: shadows ?? _shadows,
      glass: glass ?? this.glass,
      borderRadius: borderRadius ?? _borderRadius,
      border: border ?? this.border,
      justifyContent: justifyContent ?? _justifyContent,
      alignItems: alignItems ?? _alignItems,
      mainAxisSize: mainAxisSize ?? this.mainAxisSize,
      direction: direction ?? this.direction,
      flex: flex ?? this.flex,
      flexGrow: flexGrow ?? this.flexGrow,
      flexShrink: flexShrink ?? this.flexShrink,
      gap: gap ?? _gap,
      flexFit: flexFit ?? this.flexFit,
      crossAxisCount: crossAxisCount ?? _crossAxisCount,
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
      wordSpacing: wordSpacing ?? this.wordSpacing,
      textDecoration: textDecoration ?? this.textDecoration,
      lineHeight: lineHeight ?? this.lineHeight,
      hover: hover ?? this.hover,
      pressed: pressed ?? this.pressed,
      transition: transition ?? this.transition,
      cursor: cursor ?? this.cursor,
      opacity: opacity ?? this.opacity,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      transformScale: transformScale ?? this.transformScale,
      transformRotation: transformRotation ?? this.transformRotation,
      fit: fit ?? this.fit,
      imageBlur: imageBlur ?? this.imageBlur,
      grayscale: grayscale ?? this.grayscale,
      loading: loading ?? this.loading,
      error: error ?? this.error,
      placeholder: placeholder ?? this.placeholder,
      imageSrc: imageSrc ?? this.imageSrc,
    );
  }

  /// Merges this style with another FxStyle.
  FxStyle merge(FxStyle? other) {
    if (other == null) return this;
    return copyWith(
      width: other.width,
      height: other.height,
      padding: other._padding == null || other._padding == EdgeInsets.zero
          ? null
          : other._padding,
      margin: other._margin == null || other._margin == EdgeInsets.zero
          ? null
          : other._margin,
      backgroundColor: other.backgroundColor,
      gradient: other.gradient,
      shadows: other._shadows,
      glass: other.glass,
      borderRadius: other._borderRadius,
      border: other.border,
      justifyContent: other._justifyContent,
      alignItems: other._alignItems,
      mainAxisSize: other.mainAxisSize,
      direction: other.direction,
      flex: other.flex,
      flexGrow: other.flexGrow,
      flexShrink: other.flexShrink,
      gap: other._gap,
      flexFit: other.flexFit,
      crossAxisCount: other._crossAxisCount,
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
      wordSpacing: other.wordSpacing,
      textDecoration: other.textDecoration,
      lineHeight: other.lineHeight,
      hover: other.hover,
      pressed: other.pressed,
      transition: other.transition,
      cursor: other.cursor,
      opacity: other.opacity,
      aspectRatio: other.aspectRatio,
      transformScale: other.transformScale,
      transformRotation: other.transformRotation,
      fit: other.fit,
      imageBlur: other.imageBlur,
      grayscale: other.grayscale,
      loading: other.loading,
      error: other.error,
      placeholder: other.placeholder,
      imageSrc: other.imageSrc,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FxStyle &&
          runtimeType == other.runtimeType &&
          width == other.width &&
          height == other.height &&
          _padding == other._padding &&
          _margin == other._margin &&
          backgroundColor == other.backgroundColor &&
          gradient == other.gradient &&
          _shadows == other._shadows &&
          glass == other.glass &&
          _borderRadius == other._borderRadius &&
          border == other.border &&
          _justifyContent == other._justifyContent &&
          _alignItems == other._alignItems &&
          mainAxisSize == other.mainAxisSize &&
          flex == other.flex &&
          flexGrow == other.flexGrow &&
          flexShrink == other.flexShrink &&
          _gap == other._gap &&
          _crossAxisCount == other._crossAxisCount &&
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
      _padding.hashCode ^
      _margin.hashCode ^
      backgroundColor.hashCode ^
      gradient.hashCode ^
      _shadows.hashCode ^
      glass.hashCode ^
      _borderRadius.hashCode ^
      border.hashCode ^
      _justifyContent.hashCode ^
      _alignItems.hashCode ^
      mainAxisSize.hashCode ^
      flex.hashCode ^
      flexGrow.hashCode ^
      flexShrink.hashCode ^
      _gap.hashCode ^
      _crossAxisCount.hashCode ^
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
