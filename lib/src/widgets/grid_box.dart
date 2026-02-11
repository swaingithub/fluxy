import 'package:flutter/widgets.dart';
import '../styles/style.dart';
import '../engine/grid_layout_solver.dart';
import '../engine/style_resolver.dart';
import '../engine/decoration_builder.dart';

class GridBox extends StatelessWidget {
  final Style? style;
  final String? className;
  final ResponsiveStyle? responsive;
  final List<Widget> children;

  const GridBox({
    super.key,
    this.style,
    this.className,
    this.responsive,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final s = StyleResolver.resolve(
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
      padding: s.padding ?? EdgeInsets.zero,
      children: children,
    );

    if (DecorationBuilder.hasVisuals(s) || s.width != null || s.height != null || s.margin != null) {
      current = Container(
        width: s.width,
        height: s.height,
        margin: s.margin,
        decoration: DecorationBuilder.build(s),
        child: current,
      );
    }

    if (s.flex != null) {
      current = Expanded(
        flex: s.flex!,
        child: current,
      );
    }

    return current;
  }
}
