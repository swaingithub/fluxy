import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:fluxy/fluxy.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

/// Status of the WebSocket connection.
enum FluxySocketStatus { disconnected, connecting, connected, error }

/// Industrial Real-Time WebSocket Plugin for Fluxy.
/// Handles auto-reconnection, heartbeat, and signal-binding.
class FluxyWebSocketPlugin extends FluxyPlugin {
  @override
  String get name => 'fluxy_websocket';

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  
  final isConnected = flux(false);
  final status = flux(FluxySocketStatus.disconnected);
  final lastMessage = flux<dynamic>(null);
  final error = flux<String?>(null);

  String? _url;
  bool _shouldReconnect = true;
  int _reconnectAttempts = 0;

  final List<FluxEffect> _disposers = [];

  @override
  FutureOr<void> onRegister() {
    debugPrint('[WS] [INIT] WebSocket Engine Ready.');
  }

  @override
  void onDispose() {
    disconnect();
    super.onDispose();
  }

  /// Connects to a WebSocket server.
  Future<void> connect(String url, {bool autoReconnect = true}) async {
    if (url.isEmpty) {
      error.value = 'URL cannot be empty';
      return;
    }
    _url = url;
    _shouldReconnect = autoReconnect;
    _reconnectAttempts = 0;
    _reconnectTimer?.cancel();
    await _establishConnection();
  }

  Future<void> _establishConnection() async {
    if (_url == null || _url!.isEmpty) return;

    try {
      debugPrint('[WS] [CONNECTING] $_url');
      status.value = FluxySocketStatus.connecting;
      
      _channel = WebSocketChannel.connect(Uri.parse(_url!));
      
      // Wait for the stream to open or fail
      _subscription = _channel!.stream.listen(
        (message) {
          isConnected.value = true;
          status.value = FluxySocketStatus.connected;
          error.value = null;
          debugPrint('[WS] [MESSAGE] $message');
          lastMessage.value = message;
          _reconnectAttempts = 0;
        },
        onError: (err) {
          debugPrint('[WS] [ERROR] $err');
          _handleDisconnect(err.toString());
        },
        onDone: () {
          debugPrint('[WS] [DONE] Connection closed.');
          _handleDisconnect('Connection closed by server.');
        },
        cancelOnError: true,
      );
    } catch (e) {
      _handleDisconnect(e.toString());
    }
  }

  void _handleDisconnect(String errMsg) {
    isConnected.value = false;
    status.value = (errMsg.contains('error') || errMsg.contains('failed')) 
        ? FluxySocketStatus.error 
        : FluxySocketStatus.disconnected;
    error.value = errMsg;
    
    _subscription?.cancel();
    _subscription = null;
    _channel = null;

    if (_shouldReconnect && _url != null) {
      final delay = _calculateBackoff();
      debugPrint('[WS] [RECONNECT] Attempting in ${delay.inSeconds}s (Attempt #$_reconnectAttempts)...');
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(delay, () {
        _reconnectAttempts++;
        _establishConnection();
      });
    }
  }

  Duration _calculateBackoff() {
    // Exponential backoff: 2, 4, 8, 16, 30
    int seconds = (1 << (_reconnectAttempts + 1)).clamp(2, 30);
    return Duration(seconds: seconds);
  }

  /// Sends a message to the server.
  void send(dynamic data) {
    if (_channel != null && isConnected.value) {
      try {
        final encoded = (data is Map || data is List) ? jsonEncode(data) : data;
        _channel!.sink.add(encoded);
        debugPrint('[WS] [SEND] $encoded');
      } catch (e) {
        debugPrint('[WS] [SEND_ERROR] $e');
      }
    } else {
      debugPrint('[WS] [SEND_FAILED] Not connected.');
    }
  }

  /// Binds a specific key from JSON messages to a Flux signal.
  Flux<T> bind<T>(String key, T initialValue) {
    final signal = flux<T>(initialValue);
    
    _disposers.add(fluxEffect(() {
      final msg = lastMessage.value;
      if (msg != null && msg is String) {
        try {
          final data = jsonDecode(msg);
          if (data is Map && data.containsKey(key)) {
            signal.value = data[key] as T;
          }
        } catch (_) {}
      }
    }));

    return signal;
  }

  /// Closes the connection.
  void disconnect() {
    _url = null;
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _subscription?.cancel();
    _subscription = null;
    
    for (final d in _disposers) {
      d.dispose();
    }
    _disposers.clear();

    _channel?.sink.close(ws_status.goingAway);
    _channel = null;
    
    isConnected.value = false;
    status.value = FluxySocketStatus.disconnected;
    debugPrint('[WS] [DISCONNECT] Connection terminated.');
  }
}
