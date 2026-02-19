import 'dart:async';
import 'package:flutter/foundation.dart';
import '../reactive/signal.dart';
import '../reactive/async_signal.dart';
import '../engine/controller.dart';
import '../engine/stability/data_guard.dart';

/// A production-ready base class for Data Repositories in Fluxy.
/// 
/// Designed for offline-first applications with database subscriptions.
/// Addresses the "Classical Rebuild Problem" by providing atomic state management
/// and easy stream-to-state binding.
abstract class FluxyRepository extends FluxController {
  final List<StreamSubscription> _subscriptions = [];
  
  /// Helper to bind a Stream (e.g. Firestore, Supabase, WebSockets) to a Flux state.
  /// This automatically pushes updates into the Fluxy reactivity engine.
  /// 
  /// The subscription is automatically canceled when this repository is disposed.
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

/// Interface for offline-first data management.
/// Implement this to create standardized, performance-optimized data layers.
abstract class FluxRepository<T> extends FluxyRepository {
  /// Fetches data from the remote server.
  Future<T> fetchRemote();

  /// Fetches data from the local cache.
  Future<T> fetchLocal();

  /// Saves data to the local cache.
  Future<void> saveLocal(T data);

  /// Orchestrates a standard offline-first fetch: Local first, then Remote.
  /// Uses FluxyDataGuard to handle transient network failures.
  Future<T> sync() async {
    // 1. Try local cache first for instant UI response (Optimistic)
    try {
      await fetchLocal();
      // If we have cached data, we could potentially return it and update in background,
      // but for a simple sync, let's just ensure we have it.
    } catch (_) {
      // Ignore local fetch errors
    }

    // 2. Fetch remote with stable retry logic
    try {
      final remote = await FluxyDataGuard.retry(
        () => fetchRemote(),
        label: "Sync remote ($T)",
      );
      
      await saveLocal(remote);
      return remote;
    } catch (e) {
      // Final fallback to local if remote fails completely after retries
      return fetchLocal();
    }
  }
}
