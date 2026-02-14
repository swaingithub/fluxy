import 'package:flutter/widgets.dart';
import '../styles/style.dart';
import '../engine/style_resolver.dart';
import '../engine/decoration_builder.dart';

class ListBox extends StatelessWidget {
  final FxStyle style;
  final String? className;
  final FxResponsiveStyle? responsive;
  final List<Widget>? children; // Optional now
  final int? itemCount; // For builder support
  final IndexedWidgetBuilder? itemBuilder; // For builder support
  final Axis scrollDirection;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final double? gap;
  final VoidCallback? onTap;

  const ListBox({
    super.key,
    this.style = FxStyle.none,
    this.className,
    this.responsive,
    this.children,
    this.itemCount,
    this.itemBuilder,
    this.scrollDirection = Axis.vertical,
    this.physics,
    this.shrinkWrap = false,
    this.gap,
    this.onTap,
  });

  ListBox copyWith({
    FxStyle? style,
    String? className,
    FxResponsiveStyle? responsive,
    List<Widget>? children,
    int? itemCount,
    IndexedWidgetBuilder? itemBuilder,
    Axis? scrollDirection,
    ScrollPhysics? physics,
    bool? shrinkWrap,
    double? gap,
    VoidCallback? onTap,
  }) {
    return ListBox(
      style: style ?? this.style,
      className: className ?? this.className,
      responsive: responsive ?? this.responsive,
      children: children ?? this.children,
      itemCount: itemCount ?? this.itemCount,
      itemBuilder: itemBuilder ?? this.itemBuilder,
      scrollDirection: scrollDirection ?? this.scrollDirection,
      physics: physics ?? this.physics,
      shrinkWrap: shrinkWrap ?? this.shrinkWrap,
      gap: gap ?? this.gap,
      onTap: onTap ?? this.onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = FxStyleResolver.resolve(
      context,
      style: style,
      className: className,
      responsive: responsive,
    );

    final effectiveGap = gap ?? s.gap ?? 0;

    // Determine builder methodology
    final bool useBuilder = itemCount != null && itemBuilder != null;
    final int count = useBuilder ? itemCount! : (children?.length ?? 0);
    final IndexedWidgetBuilder builder = useBuilder
        ? itemBuilder!
        : (context, index) => children![index];

    Widget current = ListView.separated(
      scrollDirection: scrollDirection,
      physics: physics,
      shrinkWrap: shrinkWrap,
      padding: s.padding, // Apply padding to content
      itemCount: count,
      itemBuilder: builder,
      separatorBuilder: (context, index) => effectiveGap > 0
          ? (scrollDirection == Axis.vertical
                ? SizedBox(height: effectiveGap)
                : SizedBox(width: effectiveGap))
          : const SizedBox.shrink(),
    );

    // Apply wrapper style if necessary (bg, border, margin, size)
    // Note: We do NOT apply padding here as it was applied to ListView
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

    if (s.flex != null) {
      current = Expanded(flex: s.flex!, child: current);
    }

    return onTap != null
        ? GestureDetector(onTap: onTap, child: current)
        : current;
  }
}
