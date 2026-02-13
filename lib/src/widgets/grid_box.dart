import 'package:flutter/widgets.dart';
import '../styles/style.dart';
import '../engine/style_resolver.dart';
import '../engine/decoration_builder.dart';
import '../engine/grid_layout_solver.dart';

class GridBox extends StatelessWidget {
  final FxStyle style;
  final String? className;
  final FxResponsiveStyle? responsive;
  final List<Widget> children;

  const GridBox({
    super.key,
    this.style = FxStyle.none,
    this.className,
    this.responsive,
    required this.children,
    this.onTap,
  });
  
  final VoidCallback? onTap;

  GridBox copyWith({FxStyle? style, String? className, FxResponsiveStyle? responsive, List<Widget>? children, VoidCallback? onTap}) {
    return GridBox(
      style: style ?? this.style,
      className: className ?? this.className,
      responsive: responsive ?? this.responsive,
      children: children ?? this.children,
      onTap: onTap ?? this.onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = FxStyleResolver.resolve(
      context, 
      style: style, 
      className: className,
      responsive: responsive
    );
    final double width = MediaQuery.of(context).size.width;

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
      children: children,
    );

    if (FxDecorationBuilder.hasVisuals(s) || s.width != null || s.height != null || s.margin != EdgeInsets.zero) {
      current = Container(
        width: s.width,
        height: s.height,
        margin: s.margin,
        decoration: FxDecorationBuilder.build(s),
        child: current,
      );
    }

    if (s.flex != null) {
      current = Expanded(
        flex: s.flex!,
        child: current,
      );
    }

    return onTap != null ? GestureDetector(onTap: onTap, child: current) : current;
  }
}
