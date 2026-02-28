import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:fluxy/fluxy.dart';
import 'package:fluxy_storage/fluxy_storage.dart';
import 'package:fluxy_connectivity/fluxy_connectivity.dart';

/// Status of a synchronization operation.
enum SyncStatus { pending, inProgress, completed, failed }

/// Represents an operation to be synchronized when online.
class SyncOperation {
  final String id;
  final String action;
  final String path;
  final dynamic body;
  final DateTime timestamp;
  SyncStatus status;
  int retryCount;

  SyncOperation({
    required this.id,
    required this.action,
    required this.path,
    this.body,
    DateTime? timestamp,
    this.status = SyncStatus.pending,
    this.retryCount = 0,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'action': action,
    'path': path,
    'body': body,
    'timestamp': timestamp.toIso8601String(),
    'status': status.name,
    'retryCount': retryCount,
  };

  factory SyncOperation.fromJson(Map<String, dynamic> json) => SyncOperation(
    id: json['id'],
    action: json['action'],
    path: json['path'],
    body: json['body'],
    timestamp: DateTime.parse(json['timestamp']),
    status: SyncStatus.values.byName(json['status']),
    retryCount: json['retryCount'],
  );
}

/// Industrial Sync Plugin for Fluxy.
/// Provides offline-first persistence and background synchronization.
class FluxySyncPlugin extends FluxyPlugin {
  @override
  String get name => 'fluxy_sync';

  late FluxyStoragePlugin _storage;
  late FluxyConnectivityPlugin _connectivity;
  FluxEffect? _syncDisposer;
  
  final List<SyncOperation> _queue = [];
  final isSyncing = flux(false);
  final pendingCount = flux(0);

  static const String _storageKey = 'fluxy_sync_queue';

  @override
  FutureOr<void> onRegister() {
    _storage = use<FluxyStoragePlugin>();
    _connectivity = use<FluxyConnectivityPlugin>();
    debugPrint('[SYNC] [INIT] Sync Engine Registered.');
  }

  @override
  FutureOr<void> onAppReady() async {
    // Wait for storage to be fully hydrated before loading queue
    await _storage.ready;
    _loadQueue();
    
    // Auto-sync when coming online
    _syncDisposer = fluxEffect(() {
      if (_connectivity.isOnline.value && _queue.isNotEmpty && !isSyncing.value) {
        syncNow();
      }
    });

    debugPrint('[SYNC] [READY] Sync Engine Ready. ${_queue.length} pending operations.');
  }

  @override
  void onDispose() {
    _syncDisposer?.dispose();
    _reconnectTimer?.cancel();
    debugPrint('[SYNC] [DISPOSE] Sync Engine Disposed.');
  }

  /// Adds an operation to the persistent sync queue.
  Future<void> queue(String action, String path, {dynamic body}) async {
    final op = SyncOperation(
      id: '${DateTime.now().microsecondsSinceEpoch}_$path',
      action: action,
      path: path,
      body: body,
    );
    
    _queue.add(op);
    _saveQueue();
    pendingCount.value = _queue.length;

    debugPrint('[SYNC] [QUEUED] $action -> $path');
    
    if (_connectivity.isOnline.value) {
      syncNow();
    }
  }

  Timer? _reconnectTimer;

  /// Manually triggers a synchronization process.
  Future<void> syncNow() async {
    if (isSyncing.value || _queue.isEmpty) return;
    
    isSyncing.value = true;
    debugPrint('[SYNC] [START] Processing ${_queue.length} items...');

    final toSync = List<SyncOperation>.from(_queue);

    for (var op in toSync) {
      if (!_connectivity.isOnline.value) break;
      
      op.status = SyncStatus.inProgress;
      try {
        // Here we would typically call an ApiService or similar.
        // For the plugin, we provide a hook or assume a standard broadcast.
        await _performSync(op);
        
        op.status = SyncStatus.completed;
        _queue.removeWhere((item) => item.id == op.id);
        debugPrint('[SYNC] [DONE] Operation ${op.id} synced.');
      } catch (e) {
        op.retryCount++;
        op.status = SyncStatus.failed;
        debugPrint('[SYNC] [FAIL] Operation ${op.id} failed: $e');
        
        // Move to end of queue if we want to keep trying, or remove if fatal
        if (op.retryCount > 5) {
          _queue.removeWhere((item) => item.id == op.id);
          debugPrint('[SYNC] [DROP] Operation ${op.id} dropped after max retries.');
        }
      }
      _saveQueue();
      pendingCount.value = _queue.length;
    }

    isSyncing.value = false;
    debugPrint('[SYNC] [END] Sync process finished.');
  }

  // This is a placeholder for the actual network call.
  // In a real app, the developer would provide a handler.
  Future<void> _performSync(SyncOperation op) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    // Implementation logic here (e.g., Dio or Http call)
    // For now, we just succeed.
  }

  void _loadQueue() {
    try {
      final raw = _storage.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> data = jsonDecode(raw);
        _queue.clear();
        _queue.addAll(data.map((item) => SyncOperation.fromJson(item as Map<String, dynamic>)));
        pendingCount.value = _queue.length;
      }
    } catch (e) {
      debugPrint('[SYNC] [ERROR] Failed to load queue: $e');
      _storage.set(_storageKey, '[]'); // Reset on corruption
    }
  }

  void _saveQueue() {
    final data = _queue.map((op) => op.toJson()).toList();
    _storage.set(_storageKey, jsonEncode(data));
  }

  /// Clears all pending sync operations.
  void clearQueue() {
    _queue.clear();
    _saveQueue();
    pendingCount.value = 0;
  }
}
