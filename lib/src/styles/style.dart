import 'package:flutter/widgets.dart';
import '../responsive/responsive_engine.dart';
import '../responsive/breakpoint_resolver.dart';

/// The core styling system for Fluxy.
/// Inspired by CSS/Tailwind, designed for Flutter.
class FxStyle {
  final double? _width;
  final double? _height;
  final double? _minWidth;
  final double? _minHeight;
  final double? _maxWidth;
  final double? _maxHeight;
  final EdgeInsets? _padding;
  final EdgeInsets? _margin;
  final Color? backgroundColor;
  final Gradient? gradient;
  final List<BoxShadow>? _shadows;
  final double? glass;
  final BorderRadius? _borderRadius;
  final BoxBorder? border;

  // Individual Borders
  final BorderSide? borderTop;
  final BorderSide? borderBottom;
  final BorderSide? borderLeft;
  final BorderSide? borderRight;

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
  final FontStyle? _fontStyle;

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
    double? minWidth,
    double? minHeight,
    double? maxWidth,
    double? maxHeight,
    EdgeInsets? padding,
    EdgeInsets? margin,
    this.backgroundColor,
    this.gradient,
    List<BoxShadow>? shadows,
    this.glass,
    BorderRadius? borderRadius,
    this.border,
    this.borderTop,
    this.borderBottom,
    this.borderLeft,
    this.borderRight,
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
    FontStyle? fontStyle,
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
        _minWidth = minWidth,
        _minHeight = minHeight,
        _maxWidth = maxWidth,
        _maxHeight = maxHeight,
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
        _fontStyle = fontStyle,
        _opacity = opacity;

  /// Getters to maintain compatibility
  double? get width => _width;
  double? get height => _height;
  double? get minWidth => _minWidth;
  double? get minHeight => _minHeight;
  double? get maxWidth => _maxWidth;
  double? get maxHeight => _maxHeight;
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
  FontStyle? get fontStyle => _fontStyle;
  double? get opacity => _opacity;

  /// An empty style object.
  static const none = FxStyle();

  /// Creates a copy of this style with the given fields replaced.
  FxStyle copyWith({
    double? width,
    double? height,
    bool autoWidth = false,
    bool autoHeight = false,
    double? minWidth,
    double? minHeight,
    double? maxWidth,
    double? maxHeight,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? backgroundColor,
    Gradient? gradient,
    List<BoxShadow>? shadows,
    double? glass,
    BorderRadius? borderRadius,
    BoxBorder? border,
    BorderSide? borderTop,
    BorderSide? borderBottom,
    BorderSide? borderLeft,
    BorderSide? borderRight,
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
    FontStyle? fontStyle,
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
      width: autoWidth ? null : (width ?? this.width),
      height: autoHeight ? null : (height ?? this.height),
      minWidth: minWidth ?? this.minWidth,
      minHeight: minHeight ?? this.minHeight,
      maxWidth: maxWidth ?? this.maxWidth,
      maxHeight: maxHeight ?? this.maxHeight,
      padding: padding ?? _padding,
      margin: margin ?? _margin,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      gradient: gradient ?? this.gradient,
      shadows: shadows ?? _shadows,
      glass: glass ?? this.glass,
      borderRadius: borderRadius ?? _borderRadius,
      border: border ?? this.border,
      borderTop: borderTop ?? this.borderTop,
      borderBottom: borderBottom ?? this.borderBottom,
      borderLeft: borderLeft ?? this.borderLeft,
      borderRight: borderRight ?? this.borderRight,
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
      fontStyle: fontStyle ?? _fontStyle,
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

  /// Returns a copy of this style without flex-related properties.
  /// Used by the DSL to prevent infinite recursion during expansion lifting.
  FxStyle withoutExpansion() {
    return FxStyle(
      width: width,
      height: height,
      minWidth: minWidth,
      minHeight: minHeight,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      padding: _padding,
      margin: _margin,
      backgroundColor: backgroundColor,
      gradient: gradient,
      shadows: _shadows,
      glass: glass,
      borderRadius: _borderRadius,
      border: border,
      borderTop: borderTop,
      borderBottom: borderBottom,
      borderLeft: borderLeft,
      borderRight: borderRight,
      justifyContent: _justifyContent,
      alignItems: _alignItems,
      mainAxisSize: mainAxisSize,
      direction: direction,
      gap: _gap,
      crossAxisCount: _crossAxisCount,
      minColumnWidth: minColumnWidth,
      childAspectRatio: childAspectRatio,
      alignment: _alignment,
      clipBehavior: clipBehavior,
      top: top,
      right: right,
      bottom: bottom,
      left: left,
      zIndex: zIndex,
      color: _color,
      fontSize: _fontSize,
      fontWeight: _fontWeight,
      textAlign: _textAlign,
      fontFamily: fontFamily,
      overflow: overflow,
      maxLines: maxLines,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textDecoration: textDecoration,
      lineHeight: lineHeight,
      hover: hover,
      pressed: pressed,
      transition: transition,
      cursor: cursor,
      opacity: _opacity,
      aspectRatio: aspectRatio,
      transformScale: transformScale,
      transformRotation: transformRotation,
      fit: fit,
      imageBlur: imageBlur,
      grayscale: grayscale,
      loading: loading,
      error: error,
      placeholder: placeholder,
      imageSrc: imageSrc,
    );
  }

  /// Merges this style with another FxStyle.
  FxStyle merge(FxStyle? other) {
    if (other == null) return this;
    return copyWith(
      width: other.width,
      height: other.height,
      minWidth: other.minWidth,
      minHeight: other.minHeight,
      maxWidth: other.maxWidth,
      maxHeight: other.maxHeight,
      padding: _mergeInsets(_padding, other._padding),
      margin: _mergeInsets(_margin, other._margin),
      backgroundColor: other.backgroundColor,
      gradient: other.gradient,
      shadows: other._shadows,
      glass: other.glass,
      borderRadius: other._borderRadius,
      border: other.border,
      borderTop: other.borderTop,
      borderBottom: other.borderBottom,
      borderLeft: other.borderLeft,
      borderRight: other.borderRight,
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
      fontStyle: other._fontStyle,
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
          minWidth == other.minWidth &&
          minHeight == other.minHeight &&
          maxWidth == other.maxWidth &&
          maxHeight == other.maxHeight &&
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
      minWidth.hashCode ^
      minHeight.hashCode ^
      maxWidth.hashCode ^
      maxHeight.hashCode ^
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
  
  EdgeInsets? _mergeInsets(EdgeInsets? a, EdgeInsets? b) {
    if (a == null || a == EdgeInsets.zero) return b;
    if (b == null || b == EdgeInsets.zero) return a;
    return EdgeInsets.only(
      left: b.left != 0 ? b.left : a.left,
      top: b.top != 0 ? b.top : a.top,
      right: b.right != 0 ? b.right : a.right,
      bottom: b.bottom != 0 ? b.bottom : a.bottom,
    );
  }
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
