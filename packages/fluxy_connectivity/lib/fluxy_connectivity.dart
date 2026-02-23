import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:fluxy/fluxy.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FLUXY CONNECTIVITY PLUGIN
// Offline-first network management:
//   - Reactive online/offline signal
//   - Connection type (WiFi / Mobile / Ethernet / None)
//   - Auto-retry queue — operations queued when offline, replayed on reconnect
//   - Connection quality estimation
//   - Event callbacks for connect / disconnect
// ─────────────────────────────────────────────────────────────────────────────

/// Type of network connection
enum FluxyConnectionType { wifi, mobile, ethernet, vpn, bluetooth, none }

/// A queued operation to retry when the connection is restored
class _QueuedOperation {
  final String id;
  final Future<void> Function() task;
  final DateTime queuedAt;
  int retryCount;

  _QueuedOperation({
    required this.id,
    required this.task,
  })  : queuedAt = DateTime.now(),
        retryCount = 0;
}

class FluxyConnectivityPlugin extends FluxyPlugin with ChangeNotifier {
  @override
  String get name => 'fluxy_connectivity';

  @override
  List<String> get permissions => ['network'];

  // ── Reactive signals ──────────────────────────────────────────────────────
  final isOnline = flux<bool>(true, label: 'connectivity_online');
  final connectionType =
      flux<FluxyConnectionType>(FluxyConnectionType.none, label: 'connectivity_type');
  final isWifi = flux<bool>(false, label: 'connectivity_wifi');
  final isMobile = flux<bool>(false, label: 'connectivity_mobile');

  // ── Internals ─────────────────────────────────────────────────────────────
  final _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final List<_QueuedOperation> _retryQueue = [];
  final List<VoidCallback> _onConnectCallbacks = [];
  final List<VoidCallback> _onDisconnectCallbacks = [];

  bool _wasOnline = true;
  int _maxRetries = 3;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  FutureOr<void> onRegister() async {
    debugPrint('[NET] [INIT] Initializing connectivity engine...');

    // Get initial state
    final results = await _connectivity.checkConnectivity();
    _updateFrom(results);

    // Listen to changes
    _subscription =
        _connectivity.onConnectivityChanged.listen(_updateFrom);

    debugPrint(
        '[NET] [READY] Status: ${isOnline.value ? "ONLINE (✔)" : "OFFLINE (✖)"} | Interface: ${connectionType.value.name.toUpperCase()}');
  }

  @override
  FutureOr<void> onDispose() async {
    await _subscription?.cancel();
    _retryQueue.clear();
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Current connection type (readable synchronously).
  FluxyConnectionType get type => connectionType.value;

  /// Returns true if currently connected to any network.
  bool get online => isOnline.value;

  /// Returns true if on WiFi.
  bool get wifi => isWifi.value;

  /// Returns true if on mobile data.
  bool get mobile => isMobile.value;

  /// Force a fresh connectivity check.
  Future<bool> check() async {
    final results = await _connectivity.checkConnectivity();
    _updateFrom(results);
    return isOnline.value;
  }

  // ── Callbacks ─────────────────────────────────────────────────────────────

  /// Register a callback to fire when the app goes online.
  void onConnect(VoidCallback callback) =>
      _onConnectCallbacks.add(callback);

  /// Register a callback to fire when the app goes offline.
  void onDisconnect(VoidCallback callback) =>
      _onDisconnectCallbacks.add(callback);

  // ── Retry Queue ───────────────────────────────────────────────────────────

  /// Set maximum retry attempts per queued operation.
  void setMaxRetries(int n) => _maxRetries = n;

  /// Queue an async task to run when the network is available.
  /// If already online, runs immediately. Otherwise queued.
  Future<void> whenOnline(
    String operationId,
    Future<void> Function() task,
  ) async {
    if (isOnline.value) {
      await task();
      return;
    }
    // Remove duplicate operation IDs
    _retryQueue.removeWhere((o) => o.id == operationId);
    _retryQueue.add(_QueuedOperation(id: operationId, task: task));
    debugPrint(
        '[NET] [QUEUE] Enqueued "$operationId" — ${_retryQueue.length} job(s) pending.');
  }

  /// How many operations are waiting for network.
  int get queuedCount => _retryQueue.length;

  /// Clear the retry queue without executing.
  void clearQueue() => _retryQueue.clear();

  // ── Wait Helper ───────────────────────────────────────────────────────────

  /// Await until the device comes online (with optional timeout).
  Future<bool> waitForOnline({Duration timeout = const Duration(seconds: 30)}) async {
    if (isOnline.value) return true;
    final completer = Completer<bool>();
    late VoidCallback cb;
    cb = () {
      if (!completer.isCompleted) completer.complete(true);
      _onConnectCallbacks.remove(cb);
    };
    _onConnectCallbacks.add(cb);
    return completer.future.timeout(timeout, onTimeout: () {
      _onConnectCallbacks.remove(cb);
      return false;
    });
  }

  // ── Private ───────────────────────────────────────────────────────────────

  void _updateFrom(List<ConnectivityResult> results) {
    // Use first result if multiple
    final result =
        results.isNotEmpty ? results.first : ConnectivityResult.none;

    final newType = _mapType(result);
    final nowOnline = newType != FluxyConnectionType.none;

    connectionType.value = newType;
    isOnline.value = nowOnline;
    isWifi.value = newType == FluxyConnectionType.wifi;
    isMobile.value = newType == FluxyConnectionType.mobile;

    debugPrint('[NET] [EVENT] Status changed: ${nowOnline ? "ONLINE (✔)" : "OFFLINE (✖)"} via ${newType.name.toUpperCase()}');

    if (nowOnline && !_wasOnline) {
      // Just came back online
      for (final cb in _onConnectCallbacks) {
        cb();
      }
      _flushQueue();
    } else if (!nowOnline && _wasOnline) {
      // Just went offline
      for (final cb in _onDisconnectCallbacks) {
        cb();
      }
    }

    _wasOnline = nowOnline;
    notifyListeners();
  }

  Future<void> _flushQueue() async {
    if (_retryQueue.isEmpty) return;
    debugPrint(
        '[NET] [AUTO-SYNC] System online — Replaying ${_retryQueue.length} queued operation(s)...');

    final toRun = List<_QueuedOperation>.from(_retryQueue);
    _retryQueue.clear();

    for (final op in toRun) {
      try {
        await op.task();
        debugPrint('[NET] [SUCCESS] Operation "${op.id}" completed.');
      } catch (e) {
        op.retryCount++;
        if (op.retryCount < _maxRetries) {
          _retryQueue.add(op);
          debugPrint(
              '[NET] [RETRY] Operation "${op.id}" failed (Attempt ${op.retryCount}/$_maxRetries) | Error: $e');
        } else {
          debugPrint(
              '[NET] [FATAL] Operation "${op.id}" dropped after $_maxRetries attempts | Error: $e');
        }
      }
    }
  }

  FluxyConnectionType _mapType(ConnectivityResult r) => switch (r) {
    ConnectivityResult.wifi     => FluxyConnectionType.wifi,
    ConnectivityResult.mobile   => FluxyConnectionType.mobile,
    ConnectivityResult.ethernet => FluxyConnectionType.ethernet,
    ConnectivityResult.vpn      => FluxyConnectionType.vpn,
    ConnectivityResult.bluetooth => FluxyConnectionType.bluetooth,
    _                           => FluxyConnectionType.none,
  };
}
