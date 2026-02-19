import 'package:flutter/material.dart';
import '../dsl/fx.dart';
import '../widgets/box.dart';
import '../engine/layout_guard.dart';
import '../engine/style_resolver.dart';

import '../engine/stability/stability.dart';

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
    // Style resolution logic
    FxStyleResolver.resolve(context, style: widget.style);

    final scrollable = FluxyViewportGuard(
      direction: widget.direction,
      child: SingleChildScrollView(
        controller: _controller,
        scrollDirection: widget.direction,
        physics: const AlwaysScrollableScrollPhysics(),
        child: widget.child,
      ),
    );

    Widget content = scrollable;
    if (widget.showScrollbar) {
      content = Scrollbar(
        controller: _controller,
        child: content,
      );
    }

    return Box(
      style: widget.style,
      child: FxScrollInfo(
        direction: widget.direction,
        viewportConstraints: BoxConstraints.loose(MediaQuery.of(context).size),
        child: content,
      ),
    );
  }
}
