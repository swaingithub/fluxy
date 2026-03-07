import 'dart:async';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';

/// Advanced Animation Orchestrator for Fluxy.
/// Provides high-level, declarative motion primitives.
class FluxyAnimationsPlugin extends FluxyPlugin {
  @override
  String get name => 'fluxy_animations';

  @override
  FutureOr<void> onRegister() {
    Fluxy.log('Animations', 'INIT', 'Motion engine ready.');
  }

  /// Global default duration for Fluxy micro-interactions.
  static const Duration fast = Duration(milliseconds: 200);
  
  /// Standard duration for page transitions.
  static const Duration standard = Duration(milliseconds: 400);

  /// Slow duration for ambient pulses and shimmers.
  static const Duration slow = Duration(milliseconds: 1000);

  /// High-end spring physics for "Liquid" feel.
  static const Curve liquid = Curves.easeOutBack;
}

/// A "Boing" effect for buttons. Pops the widget when tapped.
class FxBoing extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  const FxBoing({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.95,
  });

  @override
  State<FxBoing> createState() => _FxBoingState();
}

class _FxBoingState extends State<FxBoing> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _animation = Tween<double>(begin: 1.0, end: widget.scale).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _animation,
        child: widget.child,
      ),
    );
  }
}

/// A "Pulsar" effect for calls-to-action or status indicators.
class FxPulsar extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final double scale;

  const FxPulsar({
    super.key,
    required this.child,
    this.enabled = true,
    this.scale = 1.1,
  });

  @override
  State<FxPulsar> createState() => _FxPulsarState();
}

class _FxPulsarState extends State<FxPulsar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: widget.scale).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
      ),
      child: widget.child,
    );
  }
}

/// Advanced entrance animation with slide/scale/fade combo.
class FxEntrance extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset slideOffset;
  final double scale;

  const FxEntrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
    this.slideOffset = const Offset(0, 20),
    this.scale = 0.9,
  });

  @override
  State<FxEntrance> createState() => _FxEntranceState();
}

class _FxEntranceState extends State<FxEntrance> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(parent: _controller, curve: const Interval(0, 0.6, curve: Curves.easeOut));
    final slide = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    final scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: fade.value,
          child: Transform.translate(
            offset: widget.slideOffset * (1 - slide.value),
            child: Transform.scale(
              scale: widget.scale + (1 - widget.scale) * scale.value,
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// A staggered reveal animation for lists or sets of widgets.
class FxStaggeredReveal extends StatefulWidget {
  final List<Widget> children;
  final Duration interval;
  final Duration duration;
  final Axis axis;
  final double offset;

  const FxStaggeredReveal({
    super.key,
    required this.children,
    this.interval = const Duration(milliseconds: 50),
    this.duration = const Duration(milliseconds: 400),
    this.axis = Axis.vertical,
    this.offset = 30,
  });

  @override
  State<FxStaggeredReveal> createState() => _FxStaggeredRevealState();
}

class _FxStaggeredRevealState extends State<FxStaggeredReveal> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(widget.children.length, (index) {
        final start = (index * widget.interval.inMilliseconds) / widget.duration.inMilliseconds;
        final end = (start + 0.5).clamp(0.0, 1.0);

        final animation = CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        );

        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Opacity(
              opacity: animation.value,
              child: Transform.translate(
                offset: widget.axis == Axis.vertical 
                    ? Offset(0, widget.offset * (1 - animation.value))
                    : Offset(widget.offset * (1 - animation.value), 0),
                child: child,
              ),
            );
          },
          child: widget.children[index],
        );
      }),
    );
  }
}

/// A high-performance shimmer effect for loading states.
class FxLiquidShimmer extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const FxLiquidShimmer({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  State<FxLiquidShimmer> createState() => _FxLiquidShimmerState();
}

class _FxLiquidShimmerState extends State<FxLiquidShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.withOpacity(0.3),
                Colors.grey.withOpacity(0.1),
                Colors.grey.withOpacity(0.3),
              ],
              stops: const [0.1, 0.5, 0.9],
              transform: _SlidingGradientTransform(slidePercent: _controller.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({
    required this.slidePercent,
  });

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

/// A declarative Timeline Orchestrator. 
/// Allows chaining multiple animation steps (Scale -> Rotate -> Fade) without nested wrappers.
class FxChoreography extends StatefulWidget {
  final Widget child;
  final List<FxStep> steps;
  final bool repeat;

  const FxChoreography({
    super.key,
    required this.child,
    required this.steps,
    this.repeat = false,
  });

  @override
  State<FxChoreography> createState() => _FxChoreographyState();
}

class _FxChoreographyState extends State<FxChoreography> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _runNextStep();
  }

  void _runNextStep() {
    if (_currentStep < widget.steps.length) {
      final step = widget.steps[_currentStep];
      _controller.duration = step.duration;
      _controller.forward(from: 0).then((_) {
        _currentStep++;
        _runNextStep();
      });
    } else if (widget.repeat) {
      _currentStep = 0;
      _runNextStep();
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
      animation: _controller,
      builder: (context, child) {
        if (_currentStep >= widget.steps.length && !widget.repeat) return child!;
        
        final step = widget.steps[_currentStep < widget.steps.length ? _currentStep : widget.steps.length - 1];
        final anim = CurvedAnimation(parent: _controller, curve: step.curve);

        Widget result = child!;

        if (step.scale != null) {
          result = Transform.scale(
            scale: step.scale!.begin! + (step.scale!.end! - step.scale!.begin!) * anim.value,
            child: result,
          );
        }

        if (step.rotate != null) {
          result = Transform.rotate(
            angle: step.rotate!.begin! + (step.rotate!.end! - step.rotate!.begin!) * anim.value,
            child: result,
          );
        }

        if (step.fade != null) {
          result = Opacity(
            opacity: (step.fade!.begin! + (step.fade!.end! - step.fade!.begin!) * anim.value).clamp(0.0, 1.0),
            child: result,
          );
        }

        return result;
      },
      child: widget.child,
    );
  }
}

class FxStep {
  final Duration duration;
  final Curve curve;
  final Tween<double>? scale;
  final Tween<double>? rotate;
  final Tween<double>? fade;

  const FxStep({
    required this.duration,
    this.curve = Curves.easeInOut,
    this.scale,
    this.rotate,
    this.fade,
  });
}

/// "Magnetic" interactive physics. 
/// Widgets stick to touches and snap back with elite spring physics.
class FxMagnetic extends StatefulWidget {
  final Widget child;
  final double reach;
  final double intensity;
  final Curve snapCurve;

  const FxMagnetic({
    super.key,
    required this.child,
    this.reach = 100,
    this.intensity = 0.4,
    this.snapCurve = Curves.easeOutBack,
  });

  @override
  State<FxMagnetic> createState() => _FxMagneticState();
}

class _FxMagneticState extends State<FxMagnetic> with SingleTickerProviderStateMixin {
  Offset _pointer = Offset.zero;
  bool _isAttracted = false;

  void _onPointerMove(PointerEvent event) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    // Calculate global center of the widget
    final size = box.size;
    final center = box.localToGlobal(Offset(size.width / 2, size.height / 2));
    
    // Calculate distance between pointer and center
    final distance = (event.position - center).distance;

    if (distance < widget.reach) {
      setState(() {
        _isAttracted = true;
        // Move toward the pointer based on intensity
        _pointer = (event.position - center) * widget.intensity;
      });
    } else if (_isAttracted) {
      _reset();
    }
  }

  void _reset() {
    if (mounted && _isAttracted) {
      setState(() {
        _isAttracted = false;
        _pointer = Offset.zero;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onExit: (_) => _reset(),
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerMove: _onPointerMove,
        onPointerHover: _onPointerMove,
        onPointerUp: (_) => _reset(),
        onPointerCancel: (_) => _reset(),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Invisible sensor area that matches the "reach"
            SizedBox(
              width: widget.reach * 2,
              height: widget.reach * 2,
            ),
            // The actual animated child
            AnimatedContainer(
              duration: _isAttracted ? Duration.zero : const Duration(milliseconds: 500),
              curve: widget.snapCurve,
              transform: Matrix4.translationValues(_pointer.dx, _pointer.dy, 0),
              child: widget.child,
            ),
          ],
        ),
      ),
    );
  }
}

/// A "3D Perspective" tilt effect. Rotates the widget in 3D space based on pointer location.
class FxPerspective extends StatefulWidget {
  final Widget child;
  final double intensity;
  final double perspective;

  const FxPerspective({
    super.key,
    required this.child,
    this.intensity = 0.2,
    this.perspective = 0.002,
  });

  @override
  State<FxPerspective> createState() => _FxPerspectiveState();
}

class _FxPerspectiveState extends State<FxPerspective> {
  Offset _tilt = Offset.zero;

  void _onPointerMove(PointerEvent event) {
    if (!mounted) return;
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final size = box.size;
    final center = Offset(size.width / 2, size.height / 2);
    final localPosition = box.globalToLocal(event.position);

    setState(() {
      _tilt = Offset(
        (localPosition.dy - center.dy) / center.dy,
        (center.dx - localPosition.dx) / center.dx,
      );
    });
  }

  void _reset() {
    if (mounted) setState(() => _tilt = Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onExit: (_) => _reset(),
      child: Listener(
        onPointerMove: _onPointerMove,
        onPointerHover: _onPointerMove,
        onPointerUp: (_) => _reset(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..setEntry(3, 2, widget.perspective)
            ..rotateX(_tilt.dx * widget.intensity)
            ..rotateY(_tilt.dy * widget.intensity),
          alignment: Alignment.center,
          child: widget.child,
        ),
      ),
    );
  }
}

/// A "Jelly" wobble effect. Applies elastic distortion when interacted with.
class FxJelly extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const FxJelly({super.key, required this.child, this.onTap});

  @override
  State<FxJelly> createState() => _FxJellyState();
}

class _FxJellyState extends State<FxJelly> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _wobble() {
    _controller.forward(from: 0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    return GestureDetector(
      onTap: _wobble,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final double scaleX = 1.0 + (0.2 * (1.0 - animation.value));
          final double scaleY = 1.0 - (0.1 * (1.0 - animation.value));
          
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..scale(scaleX, scaleY),
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// A "Liquid Reveal" circular transition.
class FxLiquidReveal extends StatefulWidget {
  final Widget child;
  final bool show;
  final Duration duration;

  const FxLiquidReveal({
    super.key,
    required this.child,
    this.show = true,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<FxLiquidReveal> createState() => _FxLiquidRevealState();
}

class _FxLiquidRevealState extends State<FxLiquidReveal> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    if (widget.show) _controller.forward();
  }

  @override
  void didUpdateWidget(FxLiquidReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show != oldWidget.show) {
      widget.show ? _controller.forward() : _controller.reverse();
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
      animation: _controller,
      builder: (context, child) {
        return ClipPath(
          clipper: _CircleClipper(_controller.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _CircleClipper extends CustomClipper<Path> {
  final double fraction;
  _CircleClipper(this.fraction);

  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.longestSide * 1.5;
    
    return Path()
      ..addOval(Rect.fromCircle(center: center, radius: maxRadius * fraction));
  }

  @override
  bool shouldReclip(_CircleClipper oldClipper) => fraction != oldClipper.fraction;
}

/// An organic "Liquid Fill" wave animation for loading or progress.
class FxWave extends StatefulWidget {
  final double progress;
  final Color color;
  final double waveHeight;
  final Widget? child;

  const FxWave({
    super.key,
    required this.progress,
    this.color = Colors.blue,
    this.waveHeight = 8,
    this.child,
  });

  @override
  State<FxWave> createState() => _FxWaveState();
}

class _FxWaveState extends State<FxWave> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
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
        return ClipPath(
          clipper: _WaveClipper(_controller.value, widget.progress, widget.waveHeight),
          child: Container(
            color: widget.color,
            child: widget.child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  final double animationValue;
  final double progress;
  final double waveHeight;

  _WaveClipper(this.animationValue, this.progress, this.waveHeight);

  @override
  Path getClip(Size size) {
    final path = Path();
    final y = size.height * (1 - progress);
    
    path.lineTo(0, y);
    
    for (double x = 0; x <= size.width; x++) {
      final angle = (x / size.width * 2 * math.pi) + (animationValue * 2 * math.pi);
      final dy = math.sin(angle) * waveHeight;
      path.lineTo(x, y + dy);
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_WaveClipper oldClipper) => 
    animationValue != oldClipper.animationValue || progress != oldClipper.progress;
}

/// A "Metaball" liquid button that morphs when tapped.
class FxLiquidButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;

  const FxLiquidButton({super.key, required this.child, this.onTap, this.color});

  @override
  State<FxLiquidButton> createState() => _FxLiquidButtonState();
}

class _FxLiquidButtonState extends State<FxLiquidButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isExpanded = !_isExpanded);
    _isExpanded ? _controller.forward() : _controller.reverse();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = widget.color ?? Fx.primary;
    
    return GestureDetector(
      onTap: _toggle,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background liquid "Blobs" that morph/scale
          ...List.generate(4, (index) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final double angle = (index * 2 * math.pi / 4) + (_controller.value * 0.5);
                final double dist = 35 * _controller.value;
                final double scale = 0.7 + (0.5 * _controller.value);
                
                return Transform.translate(
                  offset: Offset(math.cos(angle) * dist, math.sin(angle) * dist),
                  child: Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: (0.6 * _controller.value).clamp(0.0, 1.0),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: buttonColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
          // Main Button Content (using FxJelly for extra wobble)
          FxJelly(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

/// A mouse-following spotlight reveal effect.
class FxSpotlight extends StatefulWidget {
  final Widget child;
  final double radius;
  final Color overlayColor;
  final double blur;

  const FxSpotlight({
    super.key,
    required this.child,
    this.radius = 120,
    this.overlayColor = Colors.black87,
    this.blur = 40,
  });

  @override
  State<FxSpotlight> createState() => _FxSpotlightState();
}

class _FxSpotlightState extends State<FxSpotlight> {
  Offset _mousePos = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (e) => setState(() => _mousePos = e.localPosition),
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: ShaderMask(
              shaderCallback: (rect) {
                return RadialGradient(
                  center: FractionalOffset(
                    _mousePos.dx / rect.width,
                    _mousePos.dy / rect.height,
                  ),
                  radius: widget.radius / (rect.width > rect.height ? rect.width : rect.height),
                  colors: [Colors.transparent, widget.overlayColor],
                  stops: const [0.0, 1.0],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstOut,
              child: Container(color: widget.overlayColor),
            ),
          ),
          // Subtle glow ring
          Positioned(
            left: _mousePos.dx - widget.radius,
            top: _mousePos.dy - widget.radius,
            child: IgnorePointer(
              child: Container(
                width: widget.radius * 2,
                height: widget.radius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A "Gooey" metaball container that makes children "melt" together.
/// Works best with vibrant colors and circular shapes.
class FxGooey extends StatelessWidget {
  final List<Widget> children;
  final double intensity; // Higher = more "melt"

  const FxGooey({
    super.key,
    required this.children,
    this.intensity = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: ColorFilter.matrix([
        1, 0, 0, 0, 0,
        0, 1, 0, 0, 0,
        0, 0, 1, 0, 0,
        0, 0, 0, intensity, -intensity * 0.5, // The magic "gooey" alpha threshold
      ]),
      child: Stack(
        alignment: Alignment.center,
        children: children.map((c) => ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: intensity * 0.4, sigmaY: intensity * 0.4),
          child: c,
        )).toList(),
      ),
    );
  }
}

/// A "Confetti" particle celebrate interaction.
class FxConfetti extends StatefulWidget {
  final Widget child;
  final int count;
  final List<Color>? colors;

  const FxConfetti({
    super.key,
    required this.child,
    this.count = 20,
    this.colors,
  });

  @override
  State<FxConfetti> createState() => _FxConfettiState();
}

class _FxConfettiState extends State<FxConfetti> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_ConfettiParticle> _particles = [];
  bool _isCelebrating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isCelebrating = false);
        _controller.reset();
      }
    });
  }

  void _celebrate() {
    if (_isCelebrating) return;
    _particles.clear();
    final random = math.Random();
    for (int i = 0; i < widget.count; i++) {
      _particles.add(_ConfettiParticle(
        angle: random.nextDouble() * 2 * math.pi,
        distance: 50 + random.nextDouble() * 100,
        size: 5 + random.nextDouble() * 10,
        color: (widget.colors ?? [Colors.red, Colors.blue, Colors.yellow, Colors.green])[random.nextInt(4)],
        rotation: random.nextDouble() * 360,
      ));
    }
    setState(() => _isCelebrating = true);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _celebrate(),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          widget.child,
          if (_isCelebrating)
            ..._particles.map((p) => AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final double progress = Curves.easeOutCubic.transform(_controller.value);
                final double opacity = 1.0 - _controller.value;
                
                return Transform.translate(
                  offset: Offset(
                    math.cos(p.angle) * p.distance * progress,
                    math.sin(p.angle) * p.distance * progress + (100 * (1 - progress)),
                  ),
                  child: Transform.rotate(
                    angle: p.rotation * progress,
                    child: Opacity(
                      opacity: opacity,
                      child: Container(
                        width: p.size,
                        height: p.size,
                        decoration: BoxDecoration(
                          color: p.color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                );
              },
            )),
        ],
      ),
    );
  }
}

class _ConfettiParticle {
  final double angle;
  final double distance;
  final double size;
  final Color color;
  final double rotation;

  _ConfettiParticle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.color,
    required this.rotation,
  });
}

/// A beautiful, fluid Mesh Gradient background that moves organically.
class FxMeshGradient extends StatefulWidget {
  final List<Color> colors;
  final double speed;

  const FxMeshGradient({
    super.key,
    required this.colors,
    this.speed = 1.0,
  });

  @override
  State<FxMeshGradient> createState() => _FxMeshGradientState();
}

class _FxMeshGradientState extends State<FxMeshGradient> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
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
        return CustomPaint(
          painter: _MeshPainter(
            colors: widget.colors,
            animationValue: _controller.value * widget.speed,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _MeshPainter extends CustomPainter {
  final List<Color> colors;
  final double animationValue;

  _MeshPainter({required this.colors, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    if (colors.length < 2) return;

    for (int i = 0; i < colors.length; i++) {
      final double phase = (i * 2 * math.pi / colors.length) + (animationValue * 2 * math.pi);
      final double x = size.width / 2 + math.cos(phase) * (size.width / 3);
      final double y = size.height / 2 + math.sin(phase * 1.5) * (size.height / 3);

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [colors[i].withValues(alpha: 0.6), Colors.transparent],
        ).createShader(Rect.fromCircle(center: Offset(x, y), radius: size.width * 0.8))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);

      canvas.drawCircle(Offset(x, y), size.width * 0.8, paint);
    }
  }

  @override
  bool shouldRepaint(_MeshPainter oldDelegate) => animationValue != oldDelegate.animationValue;
}

/// A premium glowing border that travels around the edge of a container.
class FxAnimatedBorder extends StatefulWidget {
  final Widget child;
  final Color color;
  final double width;
  final double borderRadius;
  final Duration duration;

  const FxAnimatedBorder({
    super.key,
    required this.child,
    this.color = Colors.blue,
    this.width = 2.0,
    this.borderRadius = 12.0,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<FxAnimatedBorder> createState() => _FxAnimatedBorderState();
}

class _FxAnimatedBorderState extends State<FxAnimatedBorder> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)..repeat();
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
        return CustomPaint(
          foregroundPainter: _BorderPainter(
            animationValue: _controller.value,
            color: widget.color,
            strokeWidth: widget.width,
            borderRadius: widget.borderRadius,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _BorderPainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final double strokeWidth;
  final double borderRadius;

  _BorderPainter({
    required this.animationValue,
    required this.color,
    required this.strokeWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2, 
      strokeWidth / 2, 
      size.width - strokeWidth, 
      size.height - strokeWidth
    );
    
    final path = Path()..addRRect(RRect.fromRectAndRadius(
      rect, 
      Radius.circular(math.max(0, borderRadius - strokeWidth / 2))
    ));
    
    // 1. The Main Glow (Blur)
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 2
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    // 2. The Bright Core
    final corePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;

    final pathMetrics = path.computeMetrics();
    for (var metric in pathMetrics) {
        final double length = metric.length;
        final double start = length * animationValue;
        final double end = start + (length * 0.2); 
        
        if (end <= length) {
          final p = metric.extractPath(start, end);
          canvas.drawPath(p, glowPaint);
          canvas.drawPath(p, corePaint);
        } else {
          final p1 = metric.extractPath(start, length);
          final p2 = metric.extractPath(0, end - length);
          canvas.drawPath(p1, glowPaint);
          canvas.drawPath(p1, corePaint);
          canvas.drawPath(p2, glowPaint);
          canvas.drawPath(p2, corePaint);
        }
    }
  }

  @override
  bool shouldRepaint(_BorderPainter oldDelegate) => true;
}



