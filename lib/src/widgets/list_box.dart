import 'package:flutter/widgets.dart';
import '../styles/style.dart';
import '../engine/style_resolver.dart';
import '../engine/decoration_builder.dart';

import '../widgets/fx_widget.dart';

class ListBox extends FxWidget {
  final FxStyle style;
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
    super.id,
    super.className,
    this.style = FxStyle.none,
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

  @override
  ListBox copyWithStyle(FxStyle additionalStyle) {
    return copyWith(style: style.merge(additionalStyle));
  }

  @override
  ListBox copyWithResponsive(FxResponsiveStyle additionalResponsive) {
    return copyWith(
      responsive: responsive?.merge(additionalResponsive) ?? additionalResponsive,
    );
  }

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
      key: key,
      id: id,
      className: className ?? this.className,
      style: style ?? this.style,
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
  State<ListBox> createState() => _ListBoxState();
}

class _ListBoxState extends State<ListBox> {
  @override
  Widget build(BuildContext context) {
    final s = FxStyleResolver.resolve(
      context,
      style: widget.style,
      className: widget.className,
      responsive: widget.responsive,
    );

    final effectiveGap = widget.gap ?? s.gap ?? 0;

    // Determine builder methodology
    final bool useBuilder = widget.itemCount != null && widget.itemBuilder != null;
    final int count = useBuilder ? widget.itemCount! : (widget.children?.length ?? 0);
    final IndexedWidgetBuilder builder = useBuilder
        ? widget.itemBuilder!
        : (context, index) => widget.children![index];

    Widget current = ListView.separated(
      scrollDirection: widget.scrollDirection,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      padding: s.padding, // Apply padding to content
      itemCount: count,
      itemBuilder: builder,
      separatorBuilder: (context, index) => effectiveGap > 0
          ? (widget.scrollDirection == Axis.vertical
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

    return widget.onTap != null
        ? GestureDetector(onTap: widget.onTap, child: current)
        : current;
  }
}
