import 'package:flutter/material.dart';
import '../styles/style.dart';
import 'box.dart';
import '../engine/style_resolver.dart';
import '../widgets/fx_widget.dart';

class FxBadge extends FxWidget {
  final Widget child;
  final Widget? content;
  final String? label;
  final Color? color;
  final Color? textColor;
  final double? size;
  final Offset offset;
  final FxStyle style;
  final FxResponsiveStyle? responsive;

  const FxBadge({
    super.key,
    super.id,
    super.className,
    required this.child,
    this.content,
    this.label,
    this.color,
    this.textColor,
    this.size,
    this.offset = const Offset(8, -8),
    this.style = FxStyle.none,
    this.responsive,
  });

  @override
  FxBadge copyWithStyle(FxStyle additionalStyle) {
    return copyWith(style: style.merge(additionalStyle));
  }

  @override
  FxBadge copyWithResponsive(FxResponsiveStyle additionalResponsive) {
    return copyWith(
      responsive: responsive?.merge(additionalResponsive) ?? additionalResponsive,
    );
  }

  FxBadge copyWith({
    Widget? child,
    Widget? content,
    String? label,
    Color? color,
    Color? textColor,
    double? size,
    Offset? offset,
    FxStyle? style,
    FxResponsiveStyle? responsive,
    String? className,
  }) {
    return FxBadge(
      key: key,
      id: id,
      className: className ?? this.className,
      child: child ?? this.child,
      content: content ?? this.content,
      label: label ?? this.label,
      color: color ?? this.color,
      textColor: textColor ?? this.textColor,
      size: size ?? this.size,
      offset: offset ?? this.offset,
      style: style ?? this.style,
      responsive: responsive ?? this.responsive,
    );
  }

  @override
  State<FxBadge> createState() => _FxBadgeState();
}

class _FxBadgeState extends State<FxBadge> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        Positioned(
          top: widget.offset.dy,
          right: -widget.offset.dx,
          child: _buildBadge(),
        ),
      ],
    );
  }

  Widget _buildBadge() {
    Widget badgeContent = const SizedBox.shrink();
    double? diameter = widget.size;
    EdgeInsets padding = EdgeInsets.zero;

    if (widget.content != null) {
      badgeContent = widget.content!;
      padding = const EdgeInsets.all(4);
      diameter = null; // Auto size
    } else if (widget.label != null) {
      badgeContent = Text(
        widget.label!,
        style: TextStyle(
          color: widget.textColor ?? Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      );
      padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 2);
      diameter = null;
    } else {
      // Dot badge
      diameter ??= 8;
    }

    final s = FxStyleResolver.resolve(
      context,
      style: widget.style,
      className: widget.className,
      responsive: widget.responsive,
    );

    return Box(
      style: FxStyle(
        backgroundColor: widget.color ?? Colors.red,
        borderRadius: BorderRadius.circular(999),
        padding: padding,
        width: diameter,
        height: diameter,
        alignment: Alignment.center,
        shadows: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ).merge(s),
      child: badgeContent,
    );
  }
}
