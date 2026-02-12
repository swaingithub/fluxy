import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// Supported animation types in Fluxy.
enum FxMotionType { fade, slide, scale, rotate }

/// Physics configuration for spring animations.
class FxSpring {
  final double mass;
  final double stiffness;
  final double damping;

  const FxSpring({
    this.mass = 1.0,
    this.stiffness = 180.0,
    this.damping = 20.0,
  });

  static const gentle = FxSpring(stiffness: 120, damping: 14);
  static const bouncy = FxSpring(stiffness: 300, damping: 15);
  static const stiff = FxSpring(stiffness: 210, damping: 20);

  SpringDescription toSpringDescription() {
    return SpringDescription(
      mass: mass,
      stiffness: stiffness,
      damping: damping,
    );
  }
}

/// A wrapper widget that provides the Motion DSL context.
class FxMotion extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final FxSpring? spring;
  final double? delay;
  final bool autoStart;

  // Animation values
  final double? fade;
  final Offset? slide;
  final double? scale;
  final double? rotate;

  const FxMotion({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.spring,
    this.delay,
    this.autoStart = true,
    this.fade,
    this.slide,
    this.scale,
    this.rotate,
  });

  @override
  State<FxMotion> createState() => _FxMotionState();
}

class _FxMotionState extends State<FxMotion> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    if (widget.autoStart) {
      if (widget.delay != null) {
        Future.delayed(Duration(milliseconds: (widget.delay! * 1000).toInt()), () {
          if (mounted) _start();
        });
      } else {
        _start();
      }
    }
  }

  void _start() {
    if (widget.spring != null) {
      final simulation = SpringSimulation(
        widget.spring!.toSpringDescription(),
        0.0,
        1.0,
        0.0,
      );
      _controller.animateWith(simulation);
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        Widget result = child!;

        if (widget.fade != null) {
          result = Opacity(
            opacity: Tween<double>(begin: widget.fade, end: 1.0).evaluate(_animation),
            child: result,
          );
        }

        if (widget.slide != null) {
          result = Transform.translate(
            offset: Tween<Offset>(begin: widget.slide, end: Offset.zero).evaluate(_animation),
            child: result,
          );
        }

        if (widget.scale != null) {
          result = Transform.scale(
            scale: Tween<double>(begin: widget.scale, end: 1.0).evaluate(_animation),
            child: result,
          );
        }

        if (widget.rotate != null) {
          result = Transform.rotate(
            angle: Tween<double>(begin: widget.rotate, end: 0.0).evaluate(_animation),
            child: result,
          );
        }

        return result;
      },
      child: widget.child,
    );
  }
}

/// Extension to provide Fluent UI Animation DSL.
extension FxMotionExtension on Widget {
  /// Animates the widget.
  FxMotion animate({
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeOutCubic,
    double? delay,
  }) {
    return FxMotion(
      duration: duration,
      curve: curve,
      delay: delay,
      child: this,
    );
  }
}

extension FxMotionWrapperExtension on FxMotion {
  /// Adds a fade effect.
  FxMotion fade({double start = 0.0}) {
    return _copyWith(fade: start);
  }

  /// Adds a slide effect.
  FxMotion slide({Offset start = const Offset(0, 20)}) {
    return _copyWith(slide: start);
  }

  /// Adds a scale effect.
  FxMotion scale({double start = 0.0}) {
    return _copyWith(scale: start);
  }

  /// Adds a rotation effect.
  FxMotion rotate({double start = 0.1}) {
    return _copyWith(rotate: start);
  }

  /// Applies spring physics.
  FxMotion spring([FxSpring spring = FxSpring.bouncy]) {
    return _copyWith(spring: spring);
  }

  /// Internal helper to update properties.
  FxMotion _copyWith({
    double? fade,
    Offset? slide,
    double? scale,
    double? rotate,
    FxSpring? spring,
  }) {
    return FxMotion(
      duration: duration,
      curve: curve,
      spring: spring ?? this.spring,
      delay: delay,
      autoStart: autoStart,
      fade: fade ?? this.fade,
      slide: slide ?? this.slide,
      scale: scale ?? this.scale,
      rotate: rotate ?? this.rotate,
      child: child,
    );
  }
}
