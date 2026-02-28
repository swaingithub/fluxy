import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:fluxy/fluxy.dart';
import 'package:fluxy_websocket/fluxy_websocket.dart';

/// Represents a user's presence state in a real-time room.
class FluxyUserPresence {
  final String id;
  final String name;
  final String? avatar;
  final DateTime lastSeen;
  final bool isOnline;
  final Map<String, dynamic> metadata;

  FluxyUserPresence({
    required this.id,
    required this.name,
    this.avatar,
    DateTime? lastSeen,
    this.isOnline = true,
    this.metadata = const {},
  }) : lastSeen = lastSeen ?? DateTime.now();

  factory FluxyUserPresence.fromJson(Map<String, dynamic> json) => FluxyUserPresence(
    id: json['id'],
    name: json['name'],
    avatar: json['avatar'],
    lastSeen: DateTime.parse(json['last_seen']),
    isOnline: json['is_online'] ?? true,
    metadata: json['metadata'] ?? {},
  );
}

/// Industrial Presence Plugin for Fluxy.
/// Manages "Who is online", "Who is typing", and session states.
class FluxyPresencePlugin extends FluxyPlugin {
  @override
  String get name => 'fluxy_presence';

  late FluxyWebSocketPlugin _ws;
  
  /// List of users currently in the session/room.
  final users = flux<List<FluxyUserPresence>>([]);
  
  /// Users who are currently typing.
  final typingUsers = flux<Set<String>>({});
  
  /// Reactive signal for the current user's local typing state.
  final isLocalTyping = flux(false);

  Timer? _typingTimer;

  FluxEffect? _presenceDisposer;

  @override
  FutureOr<void> onRegister() {
    _ws = use<FluxyWebSocketPlugin>();
    debugPrint('[PRESENCE] [INIT] Presence Engine Registered.');
  }

  @override
  void onAppReady() {
    // Listen to websocket messages for presence events
    _presenceDisposer = fluxEffect(() {
      final msg = _ws.lastMessage.value;
      if (msg != null && msg is Map<String, dynamic>) {
        _handlePresenceMessage(msg);
      }
    });

    debugPrint('[PRESENCE] [READY] Presence Engine Ready.');
  }

  /// Broadcasts that the local user has started or stopped typing.
  void setTyping(bool typing) {
    if (isLocalTyping.value == typing) return;
    
    isLocalTyping.value = typing;
    _ws.send({
      'type': 'presence',
      'action': typing ? 'typing_start' : 'typing_stop',
    });

    if (typing) {
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 3), () {
        setTyping(false);
      });
    }
  }

  /// Broadcasts that the local user is online or offline.
  void setOnline(bool online) {
    _ws.send({
      'type': 'presence',
      'action': online ? 'user_join' : 'user_leave',
      'user': {
        'id': 'local_user', // In real app, use actual user ID
        'name': 'Fluxy Developer',
        'last_seen': DateTime.now().toIso8601String(),
        'is_online': online,
      }
    });
  }

  void _handlePresenceMessage(Map<String, dynamic> msg) {
    final type = msg['type'];
    if (type != 'presence') return;

    final action = msg['action'];
    final userId = msg['user_id'];

    switch (action) {
      case 'typing_start':
        final current = Set<String>.from(typingUsers.value);
        current.add(userId);
        typingUsers.value = current;
        break;
      case 'typing_stop':
        final current = Set<String>.from(typingUsers.value);
        current.remove(userId);
        typingUsers.value = current;
        break;
      case 'user_list':
        final List<dynamic> list = msg['users'];
        users.value = list.map((u) => FluxyUserPresence.fromJson(u)).toList();
        break;
      case 'user_join':
        final newUser = FluxyUserPresence.fromJson(msg['user']);
        final current = List<FluxyUserPresence>.from(users.value);
        current.removeWhere((u) => u.id == newUser.id);
        current.add(newUser);
        users.value = current;
        break;
      case 'user_leave':
        final current = List<FluxyUserPresence>.from(users.value);
        current.removeWhere((u) => u.id == userId);
        users.value = current;
        break;
    }
  }

  /// Returns true if a specific user is currently typing.
  bool isUserTyping(String userId) => typingUsers.value.contains(userId);

  @override
  void onDispose() {
    _typingTimer?.cancel();
    _presenceDisposer?.dispose();
    super.onDispose();
    debugPrint('[PRESENCE] [DISPOSE] Presence Engine Disposed.');
  }
}
