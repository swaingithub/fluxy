import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import '../styles/style.dart';
import '../motion/fx_motion.dart';
import '../widgets/box.dart';

/// A premium shimmer effect for Fluxy.
class FxShimmer extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const FxShimmer({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Box(
      style: FxStyle(
        width: width,
        height: height,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        backgroundColor: Colors.grey.shade200,
      ),
      child: FxMotion(
        duration: const Duration(seconds: 1),
        repeat: true,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade200,
                Colors.grey.shade100,
                Colors.grey.shade200,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
      ).animate(
        slide: const Offset(-1.0, 0),
        duration: 1.5.s,
        repeat: true,
      ),
    );
  }
}
