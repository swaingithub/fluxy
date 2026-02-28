import 'dart:async';
import 'package:flutter/foundation.dart';

/// Managed Resource Handler for Fluxy.
/// Tracks active listeners and automatically throttles/disposes high-energy resources.
class FluxyResource<T> {
  final String name;
  final Future<T> Function() onStart;
  final Future<void> Function(T resource) onStop;
  final Duration idleTimeout;

  T? _instance;
  int _refCount = 0;
  Timer? _idleTimer;

  FluxyResource({
    required this.name,
    required this.onStart,
    required this.onStop,
    this.idleTimeout = const Duration(seconds: 5),
  });

  /// Acquires the resource. Increments reference count.
  Future<T> acquire() async {
    _idleTimer?.cancel();
    _idleTimer = null;
    
    if (_instance == null) {
      debugPrint('[KERNEL] [RESOURCE] Starting $name...');
      _instance = await onStart();
    }
    
    _refCount++;
    return _instance!;
  }

  /// Releases the resource. Decrements reference count.
  /// If refCount hits 0, the resource enters a "Graceful Sleep" period before full disposal.
  void release() {
    _refCount--;
    if (_refCount <= 0) {
      _refCount = 0;
      _startIdleTimer();
    }
  }

  void _startIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(idleTimeout, () async {
      if (_refCount == 0 && _instance != null) {
        debugPrint('[KERNEL] [RESOURCE] $name idle timeout. Entering Deep Sleep.');
        await onStop(_instance!);
        _instance = null;
      }
    });
  }
}
