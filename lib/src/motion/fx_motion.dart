import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import '../engine/lift_engine.dart';

/// Physics configuration for spring animations.
/// Designed to feel "alive" and responsive.
class Spring {
  final double mass;
  final double stiffness;
  final double damping;

  const Spring({
    this.mass = 1.0,
    required this.stiffness,
    required this.damping,
  });

  /// A snappy, responsive spring. Good for UI toggles.
  static const fast = Spring(stiffness: 1000, damping: 60);

  /// A standard, smooth spring. Good for page transitions.
  static const smooth = Spring(stiffness: 350, damping: 30);

  /// A bouncy, playful spring. Good for attention-grabbing elements.
  static const bouncy = Spring(stiffness: 300, damping: 15);

  /// A gentle, slow spring. Good for background ambiance.
  static const gentle = Spring(stiffness: 120, damping: 14);

  SpringDescription get description =>
      SpringDescription(mass: mass, stiffness: stiffness, damping: damping);
}

/// A wrapper widget that provides the Motion DSL context.
class FxMotion extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Spring? spring;
  final double? delay;
  final bool autoStart;

  // Animation values (Begin -> End is always "Natural")
  // e.g. fade: 0.0 -> 1.0
  // e.g. slide: Offset(0, 100) -> Offset.zero
  final double? fade;
  final Offset? slide;
  final double? scale;
  final double? rotate;
  final bool repeat;
  final bool reverse;

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
    this.repeat = false,
    this.reverse = false,
  });

  @override
  State<FxMotion> createState() => _FxMotionState();
}

class _FxMotionState extends State<FxMotion>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // We use a separate curved animation because the controller might be linear (if spring)
  // Actually if spring, controller follows spring. If duration, we wrap curved.

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      // If spring is used, duration is technically driven by physics,
      // but providing a fallback upper bound is good practice,
      // though animateWith ignores it.
      upperBound: 1.0,
    );

    if (widget.autoStart) {
      if (widget.delay != null) {
        Future.delayed(
          Duration(milliseconds: (widget.delay! * 1000).toInt()),
          () {
            if (mounted) _start();
          },
        );
      } else {
        _start();
      }
    }
  }

  void _start() {
    if (widget.spring != null) {
      final simulation = SpringSimulation(
        widget.spring!.description,
        0.0, // start
        1.0, // end
        0.0, // velocity
      );
      _controller.animateWith(simulation).whenComplete(() {
        if (widget.repeat && mounted) {
          _controller.value = 0;
          _start();
        }
      });
    } else {
      if (widget.repeat) {
        _controller.repeat(reverse: widget.reverse);
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If spring, curve is integrated into physics.
    // If duration, apply global Curve.
    final anim = widget.spring != null
        ? _controller
        : CurvedAnimation(parent: _controller, curve: widget.curve);

    return AnimatedBuilder(
      animation: anim,
      builder: (context, child) {
        Widget result = child ?? const SizedBox.shrink();

        if (widget.fade != null) {
          final opacityVal = Tween<double>(begin: widget.fade, end: 1.0).evaluate(anim);
          result = Opacity(
            opacity: opacityVal.clamp(0.0, 1.0),
            child: result,
          );
        }

        if (widget.slide != null) {
          result = Transform.translate(
            offset: Tween<Offset>(
              begin: widget.slide,
              end: Offset.zero,
            ).evaluate(anim),
            child: result,
          );
        }

        if (widget.scale != null) {
          result = Transform.scale(
            scale: Tween<double>(begin: widget.scale, end: 1.0).evaluate(anim),
            child: result,
          );
        }

        if (widget.rotate != null) {
          result = Transform.rotate(
            angle: Tween<double>(begin: widget.rotate, end: 0.0).evaluate(anim),
            child: result,
          );
        }

        return result;
      },
      child: widget.child,
    );
  }
}

/// Unified Animation DSL Extension
extension FxMotionExtension on Widget {
  /// Declarative animation entry point.
  ///
  /// Usage:
  /// ```dart
  /// Fx.text('Hello').animate(
  ///   fade: 0.0,
  ///   slide: Offset(0, 20),
  ///   spring: Spring.bouncy
  /// )
  /// ```
  Widget animate({
    Object? duration, // Can be Duration or num (seconds)
    Curve? curve,
    Spring? spring,
    double? delay, // Seconds
    bool autoStart = true,

    // Effects (Begin Values -> End is Natural)
    double? fade,
    Offset? slide,
    double? scale,
    double? rotate,
    bool repeat = false,
    bool reverse = false,
  }) {
    return FxLift.lift(this, (child) {
      Duration? actualDuration;
      if (duration is Duration) {
        actualDuration = duration;
      } else if (duration is num) {
        actualDuration = Duration(milliseconds: (duration * 1000).toInt());
      }

      return FxMotion(
        duration: actualDuration ?? const Duration(milliseconds: 400),
        curve: curve ?? Curves.easeOutCubic,
        spring: spring,
        delay: delay,
        autoStart: autoStart,
        fade: fade,
        slide: slide,
        scale: scale,
        rotate: rotate,
        repeat: repeat,
        reverse: reverse,
        child: child,
      );
    });
  }

  /// Preset: Fades the widget in.
  Widget fadeIn({Object? duration, double? delay, Curve? curve}) =>
      animate(fade: 0.0, duration: duration, delay: delay, curve: curve);

  /// Preset: Slides the widget up from the bottom.
  Widget slideUp({double offset = 30, Object? duration, double? delay, Curve? curve}) =>
      animate(slide: Offset(0, offset), duration: duration, delay: delay, curve: curve);

  /// Preset: Slides the widget down from the top.
  Widget slideDown({double offset = 30, Object? duration, double? delay, Curve? curve}) =>
      animate(slide: Offset(0, -offset), duration: duration, delay: delay, curve: curve);

  /// Preset: Slides the widget in from the left.
  Widget slideLeft({double offset = 30, Object? duration, double? delay, Curve? curve}) =>
      animate(slide: Offset(-offset, 0), duration: duration, delay: delay, curve: curve);

  /// Preset: Slides the widget in from the right.
  Widget slideRight({double offset = 30, Object? duration, double? delay, Curve? curve}) =>
      animate(slide: Offset(offset, 0), duration: duration, delay: delay, curve: curve);

  /// Preset: Zooms the widget in from a small scale.
  Widget zoomIn({double scale = 0.8, Object? duration, double? delay, Curve? curve}) =>
      animate(scale: scale, duration: duration, delay: delay, curve: curve);

  /// Preset: Zooms the widget out from a larger scale.
  Widget zoomOut({double scale = 1.2, Object? duration, double? delay, Curve? curve}) =>
      animate(scale: scale, duration: duration, delay: delay, curve: curve);
}

/// A specialized animated widget for revealing list items with staggered intervals.
class FxReveal extends StatelessWidget {
  final List<Widget> children;
  final Duration interval;
  final Duration duration;
  final Curve curve;
  final double? slide;
  final double? fade;

  const FxReveal({
    super.key,
    required this.children,
    this.interval = const Duration(milliseconds: 50),
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutCubic,
    this.slide = 20,
    this.fade = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(children.length, (index) {
        return children[index].animate(
          delay: (index * interval.inMilliseconds) / 1000,
          duration: duration,
          curve: curve,
          fade: fade,
          slide: slide != null ? Offset(0, slide!) : null,
        );
      }),
    );
  }
}

/// Helper for Hero Animations
class FxHero extends StatelessWidget {
  final String tag;
  final Widget child;
  final bool flightShuttleBuilder; // Customizable? For now simple.

  const FxHero({
    super.key,
    required this.tag,
    required this.child,
    this.flightShuttleBuilder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: Material(type: MaterialType.transparency, child: child),
    );
  }
}

/// Convenient extensions for duration.
extension FluxyDurationExtension on num {
  Duration get ms => Duration(milliseconds: toInt());
  Duration get s => Duration(seconds: toInt());
  Duration get sec => Duration(seconds: toInt());
  Duration get m => Duration(minutes: toInt());
  Duration get h => Duration(hours: toInt());
}
