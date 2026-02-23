import 'package:flutter/widgets.dart';
import '../styles/style.dart';
import '../engine/style_resolver.dart';
import '../engine/decoration_builder.dart';
import '../engine/grid_layout_solver.dart';

import 'fx_widget.dart';

class GridBox extends FxWidget {
  @override
  final FxStyle style;
  @override
  final FxResponsiveStyle? responsive;
  final List<Widget> children;
  final VoidCallback? onTap;

  const GridBox({
    super.key,
    super.id,
    super.className,
    this.style = FxStyle.none,
    this.responsive,
    required this.children,
    this.onTap,
  });

  @override
  GridBox copyWithStyle(FxStyle additionalStyle) {
    return copyWith(style: style.merge(additionalStyle));
  }

  @override
  GridBox copyWithResponsive(FxResponsiveStyle additionalResponsive) {
    return copyWith(
      responsive: responsive?.merge(additionalResponsive) ?? additionalResponsive,
    );
  }

  GridBox copyWith({
    FxStyle? style,
    String? className,
    FxResponsiveStyle? responsive,
    List<Widget>? children,
    VoidCallback? onTap,
  }) {
    return GridBox(
      key: key,
      id: id ?? id,
      className: className ?? this.className,
      style: style ?? this.style,
      responsive: responsive ?? this.responsive,
      onTap: onTap ?? this.onTap,
      children: children ?? this.children,
    );
  }

  @override
  State<GridBox> createState() => _GridBoxState();
}

class _GridBoxState extends State<GridBox> {
  @override
  Widget build(BuildContext context) {
    final s = FxStyleResolver.resolve(
      context,
      style: widget.style,
      className: widget.className,
      responsive: widget.responsive,
    );
    final double width = MediaQuery.sizeOf(context).width;

    Widget current = GridView.count(
      crossAxisCount: GridLayoutSolver.calculateColumnCount(
        width,
        crossAxisCount: s.crossAxisCount,
        minColumnWidth: s.minColumnWidth,
        gap: s.gap ?? 0,
      ),
      mainAxisSpacing: s.gap ?? 0,
      crossAxisSpacing: s.gap ?? 0,
      childAspectRatio: s.childAspectRatio ?? 1.0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: s.padding,
      children: widget.children,
    );

    if (FxDecorationBuilder.hasVisuals(s) ||
        s.width != null ||
        s.height != null ||
        s.margin != EdgeInsets.zero) {
      current = Container(
        width: s.width,
        height: s.height,
        margin: s.margin,
        decoration: FxDecorationBuilder.build(s),
        child: current,
      );
    }

    return widget.onTap != null
        ? GestureDetector(onTap: widget.onTap, child: current)
        : current;
  }
}
