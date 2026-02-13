import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

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

  SpringDescription get description => SpringDescription(
        mass: mass,
        stiffness: stiffness,
        damping: damping,
      );
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
        widget.spring!.description,
        0.0, // start
        1.0, // end
        0.0, // velocity
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
    // If spring, curve is integrated into physics. 
    // If duration, apply global Curve.
    final anim = widget.spring != null 
        ? _controller 
        : CurvedAnimation(parent: _controller, curve: widget.curve);

    return AnimatedBuilder(
      animation: anim,
      builder: (context, child) {
        Widget result = child!;

        if (widget.fade != null) {
          result = Opacity(
            opacity: Tween<double>(begin: widget.fade, end: 1.0).evaluate(anim),
            child: result,
          );
        }

        if (widget.slide != null) {
          result = Transform.translate(
            offset: Tween<Offset>(begin: widget.slide, end: Offset.zero).evaluate(anim),
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
  }) {
    final self = this;

    // --- Structural Recursion for ParentDataWidgets ---
    if (self is Expanded) {
      return Expanded(
        flex: self.flex,
        child: self.child.animate(
          duration: duration,
          curve: curve,
          spring: spring,
          delay: delay,
          autoStart: autoStart,
          fade: fade,
          slide: slide,
          scale: scale,
          rotate: rotate,
        ),
      );
    }

    if (self is Flexible) {
      return Flexible(
        flex: self.flex,
        fit: self.fit,
        child: self.child.animate(
          duration: duration,
          curve: curve,
          spring: spring,
          delay: delay,
          autoStart: autoStart,
          fade: fade,
          slide: slide,
          scale: scale,
          rotate: rotate,
        ),
      );
    }

    if (self is Positioned) {
      return Positioned(
        left: self.left,
        top: self.top,
        right: self.right,
        bottom: self.bottom,
        width: self.width,
        height: self.height,
        child: self.child.animate(
          duration: duration,
          curve: curve,
          spring: spring,
          delay: delay,
          autoStart: autoStart,
          fade: fade,
          slide: slide,
          scale: scale,
          rotate: rotate,
        ),
      );
    }

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
      child: this,
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
      child: Material(
        type: MaterialType.transparency,
        child: child,
      ),
    );
  }
}
