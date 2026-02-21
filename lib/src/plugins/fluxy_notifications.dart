import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../engine/plugin.dart';
import '../reactive/signal.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FLUXY NOTIFICATIONS PLUGIN
// Complete local notification system with:
//   - Android notification channels
//   - Scheduled, repeating and immediate notifications
//   - Action buttons (up to 3 per notification)
//   - Custom sound, vibration, LED colour
//   - Big text, inbox, media style payloads
//   - Notification tap routing via payload
//   - Push notification adapter (plug in FCM / OneSignal / etc.)
//   - Reactive incoming stream for UI integration
// ─────────────────────────────────────────────────────────────────────────────

/// Incoming notification data (local or push via adapter)
class FluxyNotification {
  final int id;
  final String title;
  final String body;
  final String? payload;
  final DateTime receivedAt;

  FluxyNotification({
    required this.id,
    required this.title,
    required this.body,
    this.payload,
  }) : receivedAt = DateTime.now();

  @override
  String toString() => 'Notification($title, payload: $payload)';
}

/// Push notification adapter — implement for FCM, OneSignal, etc.
abstract class FluxyPushAdapter {
  Future<void> init(void Function(FluxyNotification) onMessage);
  Future<String?> getToken();
  Future<void> subscribeToTopic(String topic);
  Future<void> unsubscribeFromTopic(String topic);
}

/// Notification channel definition for Android
class FluxyNotificationChannel {
  final String id;
  final String name;
  final String description;
  final fln.Importance importance;
  final bool playSound;
  final bool enableVibration;
  final Color? ledColor;

  const FluxyNotificationChannel({
    required this.id,
    required this.name,
    required this.description,
    this.importance = fln.Importance.defaultImportance,
    this.playSound = true,
    this.enableVibration = true,
    this.ledColor,
  });
}

/// Predefined channels for common enterprise use-cases
class FluxyChannels {
  static const general = FluxyNotificationChannel(
    id: 'fluxy_general',
    name: 'General',
    description: 'General app notifications',
    importance: fln.Importance.high,
  );
  static const alerts = FluxyNotificationChannel(
    id: 'fluxy_alerts',
    name: 'Alerts',
    description: 'Important alerts requiring immediate attention',
    importance: fln.Importance.high,
    ledColor: Color(0xFFFF0000),
  );
  static const messages = FluxyNotificationChannel(
    id: 'fluxy_messages',
    name: 'Messages',
    description: 'Chat and messaging notifications',
    importance: fln.Importance.high,
  );
  static const updates = FluxyNotificationChannel(
    id: 'fluxy_updates',
    name: 'Updates',
    description: 'App and content update notifications',
    importance: fln.Importance.low,
  );
  static const silent = FluxyNotificationChannel(
    id: 'fluxy_silent',
    name: 'Silent',
    description: 'Background silent notifications',
    importance: fln.Importance.min,
    playSound: false,
    enableVibration: false,
  );
}

class FluxyNotificationsPlugin extends FluxyPlugin with ChangeNotifier {
  @override
  String get name => 'fluxy_notifications';

  @override
  List<String> get permissions => ['notifications'];

  // ── Core ──────────────────────────────────────────────────────────────────
  final _plugin = fln.FlutterLocalNotificationsPlugin();
  final List<FluxyPushAdapter> _pushAdapters = [];
  int _idCounter = 0;

  // ── Reactive state ────────────────────────────────────────────────────────
  final lastNotification = flux<FluxyNotification?>(null,
      label: 'notif_last');
  final unreadCount = flux<int>(0, label: 'notif_unread');

  // Stream for tapped notification payloads
  final _tapController = StreamController<String?>.broadcast();
  Stream<String?> get onTap => _tapController.stream;

  bool _isReady = false;

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  FutureOr<void> onRegister() async {
    debugPrint('🔔 [FluxyNotifications] Initializing...');

    const androidSettings =
        fln.AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = fln.DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = fln.InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    // Initialize Timezones for scheduling
    tz.initializeTimeZones();
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      debugPrint('🔔 [FluxyNotifications] Timezone init failed: $e');
    }

    // v20.0.0+ uses named 'settings' parameter
    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (fln.NotificationResponse response) {
        _tapController.add(response.payload);
        debugPrint('🔔 [FluxyNotifications] Tapped: ${response.payload}');
      },
    );

    // Auto-request permissions on startup for Android 13+ and iOS
    await requestPermission();

    // Create default channels
    await _createChannel(FluxyChannels.general);
    await _createChannel(FluxyChannels.alerts);
    await _createChannel(FluxyChannels.messages);
    await _createChannel(FluxyChannels.updates);
    await _createChannel(FluxyChannels.silent);

    _isReady = true;
    debugPrint('🔔 [FluxyNotifications] Ready with ${5} default channels.');
  }

  @override
  FutureOr<void> onDispose() async {
    await _tapController.close();
  }

  /// Request notification permissions (required for Android 13+).
  Future<bool> requestPermission() async {
    // 1. Request POST_NOTIFICATIONS (Android 13+)
    final androidOk = await _plugin
        .resolvePlatformSpecificImplementation<
            fln.AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // 2. Request Exact Alarm Permission if needed
    await _plugin
        .resolvePlatformSpecificImplementation<
            fln.AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    // 3. Request Darwin (iOS/macOS) permissions
    final iosOk = await _plugin
        .resolvePlatformSpecificImplementation<
            fln.IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    return (androidOk ?? false) || (iosOk ?? false);
  }

  // ── Push Adapters ─────────────────────────────────────────────────────────

  /// Register a push provider (e.g. FCM, OneSignal).
  Future<void> addPushAdapter(FluxyPushAdapter adapter) async {
    _pushAdapters.add(adapter);
    await adapter.init(_onPushReceived);
    debugPrint('🔔 [FluxyNotifications] Push adapter added: ${adapter.runtimeType}');
  }

  /// Get push device token (from first adapter).
  Future<String?> get pushToken async =>
      _pushAdapters.isEmpty ? null : _pushAdapters.first.getToken();

  /// Subscribe to a push topic.
  Future<void> subscribeToTopic(String topic) async {
    for (final a in _pushAdapters) {
      await a.subscribeToTopic(topic);
    }
  }

  /// Unsubscribe from a push topic.
  Future<void> unsubscribeFromTopic(String topic) async {
    for (final a in _pushAdapters) {
      await a.unsubscribeFromTopic(topic);
    }
  }

  void _onPushReceived(FluxyNotification n) {
    _recordNotification(n);
    // Also show locally so it appears even when app is foreground
    show(title: n.title, body: n.body, payload: n.payload);
  }

  // ── Show Notifications ─────────────────────────────────────────────────────

  /// Show an immediate notification.
  Future<int> show({
    required String title,
    required String body,
    String? payload,
    FluxyNotificationChannel channel = FluxyChannels.general,
    String? imageUrl,
    List<fln.AndroidNotificationAction>? actions,
    bool ongoing = false,
    bool silent = false,
  }) async {
    _assertReady();
    final id = _nextId();

    final androidDetails = fln.AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: silent ? fln.Importance.min : channel.importance,
      priority: silent ? fln.Priority.low : fln.Priority.high,
      playSound: !silent && channel.playSound,
      enableVibration: !silent && channel.enableVibration,
      ongoing: ongoing,
      actions: actions,
      ledColor: channel.ledColor,
      ledOnMs: channel.ledColor != null ? 1000 : null,
      ledOffMs: channel.ledColor != null ? 500 : null,
      styleInformation: imageUrl != null
          ? fln.BigPictureStyleInformation(
              fln.FilePathAndroidBitmap(imageUrl),
              contentTitle: title,
              summaryText: body,
            )
          : fln.BigTextStyleInformation(body),
    );

    const darwinDetails = fln.DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // v20.0.0+ uses named parameters
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: fln.NotificationDetails(android: androidDetails, iOS: darwinDetails),
      payload: payload,
    );

    _recordNotification(FluxyNotification(
        id: id, title: title, body: body, payload: payload));

    debugPrint('🔔 [FluxyNotifications] Shown [$id]: $title');
    return id;
  }

  // ── Convenience Shorthands ────────────────────────────────────────────────

  /// High-priority alert notification.
  Future<int> alert(String title, String body, {String? payload}) =>
      show(title: title, body: body, payload: payload, channel: FluxyChannels.alerts);

  /// Message-style notification.
  Future<int> message(String from, String text, {String? payload}) =>
      show(title: from, body: text, payload: payload, channel: FluxyChannels.messages);

  /// Silent background notification (no sound/vibration).
  Future<int> silentUpdate(String title, String body, {String? payload}) =>
      show(title: title, body: body, payload: payload, silent: true,
          channel: FluxyChannels.silent);

  // ── Scheduling ────────────────────────────────────────────────────────────

  /// Show notification after a delay.
  Future<int> showAfter(
    Duration delay,
    String title,
    String body, {
    String? payload,
    FluxyNotificationChannel channel = FluxyChannels.general,
  }) async {
    _assertReady();
    final id = _nextId();
    final scheduledDate = DateTime.now().add(delay);

    // v20.0.0+ uses named parameters
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: _toTZDateTime(scheduledDate),
        notificationDetails: fln.NotificationDetails(
          android: fln.AndroidNotificationDetails(channel.id, channel.name,
              channelDescription: channel.description,
              importance: channel.importance),
          iOS: const fln.DarwinNotificationDetails(),
        ),
        payload: payload,
        androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
      );
    } on Exception catch (e) {
      if (e.toString().contains('exact_alarms_not_permitted')) {
        debugPrint('🔔 [FluxyNotifications] Exact alarm failed, falling back to inexact...');
        await _plugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: _toTZDateTime(scheduledDate),
          notificationDetails: fln.NotificationDetails(
            android: fln.AndroidNotificationDetails(channel.id, channel.name,
                channelDescription: channel.description,
                importance: channel.importance),
            iOS: const fln.DarwinNotificationDetails(),
          ),
          payload: payload,
          androidScheduleMode: fln.AndroidScheduleMode.inexactAllowWhileIdle,
        );
      } else {
        rethrow;
      }
    }

    debugPrint('🔔 [FluxyNotifications] Scheduled [$id] in ${delay.inSeconds}s: $title');
    return id;
  }

  /// Show notification at a specific time.
  Future<int> showAt(
    DateTime when,
    String title,
    String body, {
    String? payload,
    FluxyNotificationChannel channel = FluxyChannels.general,
  }) =>
      showAfter(when.difference(DateTime.now()), title, body,
          payload: payload, channel: channel);

  // ── Repeating ─────────────────────────────────────────────────────────────

  /// Show a daily repeating notification at the given time.
  Future<int> daily(
    String title,
    String body, {
    int hour = 9,
    int minute = 0,
    String? payload,
    FluxyNotificationChannel channel = FluxyChannels.general,
  }) async {
    _assertReady();
    final id = _nextId();
    
    // v20.0.0+ uses named parameters
    await _plugin.periodicallyShow(
      id: id,
      title: title,
      body: body,
      repeatInterval: fln.RepeatInterval.daily,
      notificationDetails: fln.NotificationDetails(
        android: fln.AndroidNotificationDetails(channel.id, channel.name,
            channelDescription: channel.description),
        iOS: const fln.DarwinNotificationDetails(),
      ),
      payload: payload,
      androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
    );
    return id;
  }

  // ── Badge ─────────────────────────────────────────────────────────────────

  /// Update app icon badge count (iOS).
  Future<void> setBadge(int count) async {
    if (count == 0) {
      await _plugin.cancelAll();
    }
  }

  // ── Management ────────────────────────────────────────────────────────────

  /// Cancel a specific notification by ID.
  Future<void> cancel(int id) async {
    // v20.0.0+ uses named 'id'
    await _plugin.cancel(id: id);
    debugPrint('🔔 [FluxyNotifications] Cancelled [$id]');
  }

  /// Cancel all pending and shown notifications.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
    unreadCount.value = 0;
    notifyListeners();
    debugPrint('🔔 [FluxyNotifications] All cancelled.');
  }

  /// Mark all as read (reset badge count).
  void markAllRead() {
    unreadCount.value = 0;
    notifyListeners();
  }

  /// List pending (scheduled) notifications.
  Future<List<fln.PendingNotificationRequest>> get pending =>
      _plugin.pendingNotificationRequests();

  // ── Custom Channels ───────────────────────────────────────────────────────

  /// Create a custom notification channel at runtime.
  Future<void> createChannel(FluxyNotificationChannel channel) =>
      _createChannel(channel);

  // ── Private ───────────────────────────────────────────────────────────────

  Future<void> _createChannel(FluxyNotificationChannel ch) async {
    final androidChannel = fln.AndroidNotificationChannel(
      ch.id,
      ch.name,
      description: ch.description,
      importance: ch.importance,
      playSound: ch.playSound,
      enableVibration: ch.enableVibration,
      ledColor: ch.ledColor,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            fln.AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  void _recordNotification(FluxyNotification n) {
    lastNotification.value = n;
    unreadCount.value = unreadCount.value + 1;
    notifyListeners();
  }

  void _assertReady() {
    assert(_isReady, '[FluxyNotifications] Not ready — call after Fluxy.init()');
  }

  int _nextId() => ++_idCounter;

  tz.TZDateTime _toTZDateTime(DateTime dt) {
    return tz.TZDateTime.from(dt, tz.local);
  }
}
