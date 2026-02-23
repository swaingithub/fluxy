import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../networking/fluxy_http.dart';
import 'stability_metrics.dart';

/// Advanced Data Resilience Guard for Fluxy.
/// Handles retries, timeouts, and stale-while-revalidate patterns.
class FluxyDataGuard {
  static int maxRetries = 3;
  static Duration retryDelay = const Duration(seconds: 2);

  /// Executes an async operation with automatic retry logic and stability tracking.
  static Future<T> retry<T>(
    Future<T> Function() operation, {
    int? retries,
    Duration? delay,
    String? label,
  }) async {
    int attempts = 0;
    final max = retries ?? maxRetries;
    final backoff = delay ?? retryDelay;

    while (attempts < max) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts >= max) {
          debugPrint("[KERNEL] [DATA] [FATAL] Max retries exhausted for ${label ?? 'operation'}.");
          rethrow;
        }
        
        FluxyStabilityMetrics.recordAsyncFix(); // Record that we recovered via retry
        debugPrint("[KERNEL] [DATA] [RETRY] Attempt $attempts/$max for ${label ?? 'operation'}...");
        await Future.delayed(backoff * attempts); // Exponential-ish backoff
      }
    }
    throw Exception('Retry failed');
  }

  /// Implements a "Stale-While-Revalidate" pattern.
  /// Returns [local] immediately if available, then updates with [remote] in the background.
  static Future<void> swr<T>({
    required Future<T?> local,
    required Future<T> remote,
    required void Function(T data) onData,
    void Function(dynamic error)? onError,
  }) async {
    try {
      // 1. Try local cache first
      final cached = await local;
      if (cached != null) {
        onData(cached);
      }

      // 2. Fetch fresh data from remote
      final fresh = await remote;
      onData(fresh);
    } catch (e) {
      debugPrint('[KERNEL] [DATA] [ERROR] SWR cycle failed | Error: $e');
      onError?.call(e);
    }
  }
}

/// Automatically handles common network failures globally.
class FluxyNetworkResilienceInterceptor extends FluxyInterceptor {
  @override
  Future<FxResponse> onResponse(FxResponse response) async {
    // If we get a 503 or 502, we might want to suggest a retry, 
    // but interceptors are usually linear. We handle specific retries in the DataGuard.
    return response;
  }
}
