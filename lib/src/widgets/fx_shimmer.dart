import 'package:flutter/material.dart';
import '../styles/style.dart';
import '../motion/fx_motion.dart';
import '../widgets/box.dart';

/// A premium shimmer effect for Fluxy.
/// Can be used as a standalone skeleton or a wrapper for other widgets.
class FxShimmer extends StatelessWidget {
  final Widget? child;
  final bool enabled;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const FxShimmer({
    super.key,
    this.child,
    this.enabled = true,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child ?? const SizedBox.shrink();

    return Box(
      style: FxStyle(
        width: width,
        height: height,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
      ),
      child: Stack(
        children: [
          if (child != null) child!,
          Positioned.fill(
            child: _ShimmerEffect(),
          ),
        ],
      ),
    );
  }
}

class _ShimmerEffect extends StatefulWidget {
  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FractionallySizedBox(
          widthFactor: 2.0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.0),
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.0),
                ],
                stops: const [0.35, 0.5, 0.65],
                transform: _SlidingGradientTransform(offset: _controller.value),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.offset});

  final double offset;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (offset - 0.5) * 2, 0.0, 0.0);
  }
}
