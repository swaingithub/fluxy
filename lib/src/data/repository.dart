import 'dart:async';
import 'package:flutter/foundation.dart';
import '../di/fluxy_di.dart';
import '../reactive/signal.dart';
import '../reactive/async_signal.dart';

/// A production-ready base class for Data Repositories in Fluxy.
/// 
/// Designed for offline-first applications with database subscriptions.
/// Addresses the "Classical Rebuild Problem" by providing atomic state management
/// and easy stream-to-state binding.
abstract class FluxyRepository extends FluxyController {
  
  /// Helper to bind a Stream (e.g. Firestore, Supabase, WebSockets) to a Flux state.
  /// This automatically pushes updates into the Fluxy reactivity engine.
  /// 
  /// The subscription is automatically canceled when this repository is disposed via FluxyDI.
  StreamSubscription<T> bindStream<T>(Stream<T> stream, Flux<T> target) {
    final sub = stream.listen(
      (data) {
        target.value = data;
      },
      onError: (e) {
        debugPrint("Fluxy [Repository] Stream Error: $e");
      },
    );
    _subscriptions.add(sub);
    return sub;
  }

  /// Helper to bind an AsyncFlux to a database stream.
  /// This manages loading, success, and error states automatically.
  void bindAsyncFlux<T>(Stream<T> stream, AsyncFlux<T> target) {
    target.bindStream(stream);
  }

  final List<StreamSubscription> _subscriptions = [];

  @override
  @mustCallSuper
  void onDispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    super.onDispose();
  }

  /// Generates a scoped key for multi-user persistence.
  /// Use this with PersistentFlux to prevent data leakage between user sessions.
  /// 
  /// Usage: 
  /// ```dart
  /// final settings = flux(default, persistKey: userScope(currentUserId, 'prefs'));
  /// ```
  String userScope(String userId, String key) => "u_${userId}_$key";

  /// Connectivity status flux (optional helper).
  final isOnline = flux(true);
}
