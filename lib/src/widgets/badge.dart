import 'package:flutter/material.dart';
import '../styles/style.dart';
import '../widgets/box.dart';

class FxBadge extends StatelessWidget {
  final Widget child;
  final Widget? content;
  final String? label;
  final Color? color;
  final Color? textColor;
  final double? size;
  final Offset offset;

  const FxBadge({
    super.key,
    required this.child,
    this.content,
    this.label,
    this.color,
    this.textColor,
    this.size,
    this.offset = const Offset(8, -8),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: offset.dy,
          right: -offset
              .dx, // Negative because we position from left/top usually in Stack but badge is usually top-right
          // Actually Stack uses top/right/bottom/left.
          // Let's use top and right.
          child: _buildBadge(),
        ),
      ],
    );
  }

  Widget _buildBadge() {
    Widget badgeContent = const SizedBox.shrink();
    double? diameter = size;
    EdgeInsets padding = EdgeInsets.zero;

    if (content != null) {
      badgeContent = content!;
      padding = const EdgeInsets.all(4);
      diameter = null; // Auto size
    } else if (label != null) {
      badgeContent = Text(
        label!,
        style: TextStyle(
          color: textColor ?? Colors.white,
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

    return Box(
      style: FxStyle(
        backgroundColor: color ?? Colors.red,
        borderRadius: BorderRadius.circular(999),
        padding: padding,
        width: diameter,
        height: diameter,
        alignment: Alignment.center,
        shadows: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: badgeContent,
    );
  }
}
