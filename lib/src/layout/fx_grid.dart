import 'package:flutter/widgets.dart';
import 'breakpoint.dart';
import '../styles/style.dart';
import '../engine/style_resolver.dart';
import '../engine/decoration_builder.dart';

class FxGrid extends StatelessWidget {
  final List<Widget> children;
  final int? columns;
  final double gap;
  final double? minItemWidth;
  final FxStyle style;
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
    required this.children,
    this.columns = 2,
    this.gap = 0,
    this.minItemWidth,
    this.style = FxStyle.none,
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
  Widget build(BuildContext context) {
    final s = FxStyleResolver.resolve(context, style: style);
    final width = MediaQuery.of(context).size.width;
    
    int resolvedCols = columns ?? 2;
    
    // 1. Check if it's a responsive grid
    if (xsCols != null || smCols != null || mdCols != null || lgCols != null || xlCols != null) {
      resolvedCols = FxBreakpoint.value<int>(
        context,
        xs: xsCols ?? 2,
        sm: smCols,
        md: mdCols,
        lg: lgCols,
        xl: xlCols,
      );
    } 
    // 2. Check if it's an auto grid
    else if (minItemWidth != null) {
      resolvedCols = (width / (minItemWidth! + gap)).floor();
      if (resolvedCols < 1) resolvedCols = 1;
    }

    Widget grid = GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: resolvedCols,
        mainAxisSpacing: gap,
        crossAxisSpacing: gap,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
      shrinkWrap: shrinkWrap,
      physics: physics,
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
