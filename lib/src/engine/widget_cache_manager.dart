import 'package:flutter/widgets.dart';

/// WidgetCacheManager stores built widget subtrees to prevent 
/// unnecessary rebuilds of deep Fluxy trees.
class WidgetCacheManager {
  final Map<String, Widget> _cache = {};

  /// Retrieves a cached widget or builds a new one if not found.
  Widget getOrBuild(String id, bool shouldRebuild, Widget Function() builder) {
    if (!shouldRebuild && _cache.containsKey(id)) {
      return _cache[id]!;
    }
    
    final widget = builder();
    _cache[id] = widget;
    return widget;
  }

  /// Explicitly invalidates a cache entry.
  void invalidate(String id) {
    _cache.remove(id);
  }

  /// Clears the entire cache.
  void clear() {
    _cache.clear();
  }
}
