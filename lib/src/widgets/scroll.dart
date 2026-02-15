import 'package:flutter/material.dart';
import '../dsl/fx.dart';
import '../widgets/box.dart';
import '../reactive/signal.dart';
import '../responsive/responsive_engine.dart';

/// A managed scrollable container with built-in scrollbar support and state management.
class FxScroll extends StatefulWidget {
  final Widget child;
  final Axis direction;
  final FxStyle style;
  final bool showScrollbar;

  const FxScroll({
    super.key,
    required this.child,
    this.direction = Axis.vertical,
    this.style = FxStyle.none,
    this.showScrollbar = true,
  });

  @override
  State<FxScroll> createState() => _FxScrollState();
}

class _FxScrollState extends State<FxScroll> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Box(
      style: widget.style,
      child: Fx(() {
        final ctx = FluxyReactiveContext.currentContext;
        final scrollable = SingleChildScrollView(
          controller: _controller,
          scrollDirection: widget.direction,
          child: widget.child,
        );
        
        if (widget.showScrollbar && ctx != null) {
          final bp = ResponsiveEngine.of(ctx);
          final isDesktop = bp == Breakpoint.lg || bp == Breakpoint.xl;
          return Scrollbar(
            controller: _controller,
            thumbVisibility: isDesktop,
            child: scrollable,
          );
        }
        return scrollable;
      }),
    );
  }
}
