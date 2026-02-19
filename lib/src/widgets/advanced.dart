import 'package:flutter/material.dart';
import '../dsl/fx.dart';

/// A premium Pull-To-Refresh wrapper for Fluxy.
class FxRefresh extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;
  final Color? backgroundColor;
  final double displacement;
  final double edgeOffset;

  const FxRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
    this.backgroundColor,
    this.displacement = 40.0,
    this.edgeOffset = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? Theme.of(context).primaryColor,
      backgroundColor: backgroundColor ?? Colors.white,
      displacement: displacement,
      edgeOffset: edgeOffset,
      strokeWidth: 2.5,
      child: child,
    );
  }
}

/// A Parallax wrapper for Fluxy images or background widgets.
class FxParallax extends StatelessWidget {
  final Widget child;
  final ScrollController controller;
  final double speed;

  const FxParallax({
    super.key,
    required this.child,
    required this.controller,
    this.speed = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        double offset = 0;
        if (controller.hasClients) {
          offset = controller.offset * speed;
        }
        return Transform.translate(
          offset: Offset(0, offset),
          child: child,
        );
      },
      child: child,
    );
  }
}

/// An Infinite List primitive with easy pagination support.
class FxInfiniteList extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Future<void> Function() onLoadMore;
  final bool hasMore;
  final Widget? loadingIndicator;
  final FxStyle style;
  final ScrollController? controller;

  const FxInfiniteList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.onLoadMore,
    this.hasMore = true,
    this.loadingIndicator,
    this.style = FxStyle.none,
    this.controller,
  });

  @override
  State<FxInfiniteList> createState() => _FxInfiniteListState();
}

class _FxInfiniteListState extends State<FxInfiniteList> {
  late ScrollController _scrollController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && widget.hasMore) {
        _loadMore();
      }
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoading = true);
    await widget.onLoadMore();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Fx.list(
      controller: _scrollController,
      itemCount: widget.itemCount + (widget.hasMore ? 1 : 0),
      style: widget.style,
      itemBuilder: (context, index) {
        if (index < widget.itemCount) {
          return widget.itemBuilder(context, index);
        } else {
          return widget.loadingIndicator ?? 
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
        }
      },
    );
  }
}
