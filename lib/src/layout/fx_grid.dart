import 'package:flutter/widgets.dart';
import 'breakpoint.dart';
import '../styles/style.dart';
import '../engine/style_resolver.dart';
import '../engine/decoration_builder.dart';

import '../widgets/fx_widget.dart';

class FxGrid extends FxWidget {
  final List<Widget> children;
  final int? columns;
  final double gap;
  final double? minItemWidth;
  final FxStyle style;
  final FxResponsiveStyle? responsive;
  final double childAspectRatio;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  
  // Breakpoints for responsive factory
  final int? xsCols;
  final int? smCols;
  final int? mdCols;
  final int? lgCols;
  final int? xlCols;

  const FxGrid({
    super.key,
    super.id,
    super.className,
    required this.children,
    this.columns = 2,
    this.gap = 0,
    this.minItemWidth,
    this.style = FxStyle.none,
    this.responsive,
    this.childAspectRatio = 1.0,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
    this.xsCols,
    this.smCols,
    this.mdCols,
    this.lgCols,
    this.xlCols,
  });

  /// Automatically calculates column count based on available width and minItemWidth.
  factory FxGrid.auto({
    required List<Widget> children,
    required double minItemWidth,
    double gap = 0,
    FxStyle style = FxStyle.none,
    double childAspectRatio = 1.0,
  }) {
    return FxGrid(
      children: children,
      minItemWidth: minItemWidth,
      gap: gap,
      style: style,
      childAspectRatio: childAspectRatio,
    );
  }

  /// Explicit responsive column control.
  factory FxGrid.responsive({
    required List<Widget> children,
    int? xs,
    int? sm,
    int? md,
    int? lg,
    int? xl,
    double gap = 0,
    FxStyle style = FxStyle.none,
    double childAspectRatio = 1.0,
  }) {
    return FxGrid(
      children: children,
      xsCols: xs,
      smCols: sm,
      mdCols: md,
      lgCols: lg,
      xlCols: xl,
      gap: gap,
      style: style,
      childAspectRatio: childAspectRatio,
      columns: null, // Use breakpoint values
    );
  }

  /// Preset for Card grids.
  factory FxGrid.cards({
    required List<Widget> children,
    double gap = 16,
    double childAspectRatio = 0.8,
  }) {
    return FxGrid(
      children: children,
      gap: gap,
      childAspectRatio: childAspectRatio,
      minItemWidth: 160, // Smart default for cards
    );
  }

  /// Preset for Image Galleries.
  factory FxGrid.gallery({
    required List<Widget> children,
    double gap = 4,
    int columns = 3,
  }) {
    return FxGrid(
      children: children,
      gap: gap,
      columns: columns,
      childAspectRatio: 1.0, // Square by default
    );
  }

  @override
  FxGrid copyWithStyle(FxStyle additionalStyle) {
    return copyWith(style: style.merge(additionalStyle));
  }

  @override
  FxGrid copyWithResponsive(FxResponsiveStyle additionalResponsive) {
    return copyWith(
      responsive: responsive?.merge(additionalResponsive) ?? additionalResponsive,
    );
  }

  FxGrid copyWith({
    List<Widget>? children,
    int? columns,
    double? gap,
    double? minItemWidth,
    FxStyle? style,
    FxResponsiveStyle? responsive,
    double? childAspectRatio,
    bool? shrinkWrap,
    ScrollPhysics? physics,
  }) {
    return FxGrid(
      key: key,
      id: id,
      className: className,
      children: children ?? this.children,
      columns: columns ?? this.columns,
      gap: gap ?? this.gap,
      minItemWidth: minItemWidth ?? this.minItemWidth,
      style: style ?? this.style,
      responsive: responsive ?? this.responsive,
      childAspectRatio: childAspectRatio ?? this.childAspectRatio,
      shrinkWrap: shrinkWrap ?? this.shrinkWrap,
      physics: physics ?? this.physics,
      xsCols: xsCols,
      smCols: smCols,
      mdCols: mdCols,
      lgCols: lgCols,
      xlCols: xlCols,
    );
  }

  @override
  State<FxGrid> createState() => _FxGridState();
}

class _FxGridState extends State<FxGrid> {
  @override
  Widget build(BuildContext context) {
    final s = FxStyleResolver.resolve(
      context,
      style: widget.style,
      className: widget.className,
      responsive: widget.responsive,
    );
    final width = MediaQuery.of(context).size.width;

    // Attribute Accumulation: Style takes precedence over constructor args
    int resolvedCols = s.crossAxisCount ?? widget.columns ?? 2;
    
    // 1. Check if it's a responsive grid
    if (widget.xsCols != null ||
        widget.smCols != null ||
        widget.mdCols != null ||
        widget.lgCols != null ||
        widget.xlCols != null) {
      resolvedCols = FxBreakpoint.value<int>(
        context,
        xs: widget.xsCols ?? 2,
        sm: widget.smCols,
        md: widget.mdCols,
        lg: widget.lgCols,
        xl: widget.xlCols,
      );
    }
    // 2. Check if it's an auto grid
    else if (widget.minItemWidth != null) {
      resolvedCols = (width / (widget.minItemWidth! + widget.gap)).floor();
      if (resolvedCols < 1) resolvedCols = 1;
    }

    // Also use gap from style if set
    final effectiveGap = s.gap ?? widget.gap;

    Widget grid = GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: resolvedCols,
        mainAxisSpacing: effectiveGap,
        crossAxisSpacing: effectiveGap,
        childAspectRatio: widget.childAspectRatio,
      ),
      itemCount: widget.children.length,
      itemBuilder: (context, index) => widget.children[index],
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      padding: s.padding,
    );

    if (FxDecorationBuilder.hasVisuals(s) || s.width != null || s.height != null || s.margin != EdgeInsets.zero) {
      grid = Container(
        width: s.width,
        height: s.height,
        margin: s.margin,
        decoration: FxDecorationBuilder.build(s),
        child: grid,
      );
    }

    if (s.flex != null) {
      grid = Expanded(flex: s.flex!, child: grid);
    }

    return grid;
  }
}
