import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:fluxy/fluxy.dart';

/// Industrial Stream Bridge for Fluxy.
/// Bridges the gap between standard Dart Streams and Fluxy reactivity.
class FluxyStreamBridgePlugin extends FluxyPlugin {
  @override
  String get name => 'fluxy_stream_bridge';

  final List<StreamSubscription> _subs = [];

  @override
  FutureOr<void> onRegister() {
    debugPrint('[BRIDGE] [INIT] Stream Bridge Ready.');
  }

  /// Pipes a Dart Stream directly into a Fluxy signal.
  /// Automatically manages subscription and updates.
  Flux<T> pipe<T>(Stream<T> stream, T initialValue) {
    final signal = flux<T>(initialValue);
    final sub = stream.listen((val) => signal.value = val);
    _subs.add(sub);
    return signal;
  }

  @override
  void onDispose() {
    for (var sub in _subs) {
      sub.cancel();
    }
    _subs.clear();
    super.onDispose();
  }
}

/// Extension for one-liner stream-to-flux conversion.
extension FluxyStreamExtension<T> on Stream<T> {
  /// Converts this stream to a Fluxy signal.
  /// Requires the [FluxyStreamBridgePlugin] to be registered for auto-disposal.
  Flux<T> toFlux(T initialValue) {
    try {
      final bridge = use<FluxyStreamBridgePlugin>();
      return bridge.pipe(this, initialValue);
    } catch (_) {
      // Fallback if plugin not registered: Manual subscription
      final signal = flux<T>(initialValue);
      listen((val) => signal.value = val);
      return signal;
    }
  }
}
