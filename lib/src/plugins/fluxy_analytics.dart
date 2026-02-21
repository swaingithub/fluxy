import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../engine/plugin.dart';
import '../reactive/signal.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FLUXY ANALYTICS PLUGIN
// Privacy-first, offline-capable event analytics with:
//   - Event queueing with automatic batch sending
//   - Session management (session ID, duration tracking)
//   - Screen view tracking
//   - User identification
//   - Retry logic for failed batches
//   - Custom properties / super-properties (attached to every event)
//   - Adapter pattern: plug in Firebase, Mixpanel, PostHog, etc.
// ─────────────────────────────────────────────────────────────────────────────

/// An analytics event
class FluxyEvent {
  final String name;
  final Map<String, dynamic> properties;
  final DateTime timestamp;
  final String sessionId;

  FluxyEvent({
    required this.name,
    required this.properties,
    required this.sessionId,
  }) : timestamp = DateTime.now();

  Map<String, dynamic> toJson() => {
    'name': name,
    'properties': properties,
    'timestamp': timestamp.toIso8601String(),
    'session_id': sessionId,
  };

  @override
  String toString() => 'FluxyEvent($name, ${timestamp.toIso8601String()})';
}

/// Implement this to forward events to Firebase, Mixpanel, PostHog, etc.
abstract class FluxyAnalyticsAdapter {
  /// Called with a flushed batch of events. Perform your HTTP call here.
  Future<void> sendBatch(List<FluxyEvent> events);
}

class FluxyAnalyticsPlugin extends FluxyPlugin with ChangeNotifier {
  @override
  String get name => 'fluxy_analytics';

  @override
  List<String> get permissions => ['network'];

  // ── State ────────────────────────────────────────────────────────────────────
  final List<FluxyEvent> _queue = [];
  final List<FluxyAnalyticsAdapter> _adapters = [];
  final Map<String, dynamic> _superProperties = {}; // attached to every event

  String? _userId;
  String? _sessionId;
  DateTime? _sessionStart;
  String? _currentScreen;
  Timer? _flushTimer;

  // Reactive observables
  final eventCount    = flux<int>(0, label: 'analytics_event_count');
  final currentScreen = flux<String?>( null, label: 'analytics_screen');
  final sessionDuration = flux<Duration>(Duration.zero, label: 'analytics_session_duration');
  Timer? _durationTimer;

  // Config
  int _batchSize = 20;          // flush when queue reaches this size
  Duration _flushInterval = const Duration(seconds: 30); // or every N seconds

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  FutureOr<void> onRegister() {
    debugPrint('📊 [FluxyAnalytics] Initializing...');
    _startSession();
  }

  @override
  FutureOr<void> onAppReady() {
    debugPrint('📊 [FluxyAnalytics] Tracking started. Session: $_sessionId');
    _scheduleFlush();
  }

  @override
  FutureOr<void> onDispose() async {
    _flushTimer?.cancel();
    _durationTimer?.cancel();
    await flush(); // drain the queue on exit
  }

  // ── Configuration ────────────────────────────────────────────────────────────

  /// Register an adapter (e.g. Firebase, PostHog, your own backend).
  void addAdapter(FluxyAnalyticsAdapter adapter) => _adapters.add(adapter);

  /// Set batch size before auto-flushing.
  void setBatchSize(int size) => _batchSize = size;

  /// Set auto-flush interval.
  void setFlushInterval(Duration d) {
    _flushInterval = d;
    _flushTimer?.cancel();
    _scheduleFlush();
  }

  /// Add properties that are automatically merged into every event.
  void setSuperProperties(Map<String, dynamic> props) {
    _superProperties.addAll(props);
    debugPrint('📊 [FluxyAnalytics] Super properties set: ${props.keys}');
  }

  /// Clear all super-properties.
  void clearSuperProperties() => _superProperties.clear();

  // ── User Identity ────────────────────────────────────────────────────────────

  /// Identify the current user. All future events will include this ID.
  void identify(String userId, {Map<String, dynamic>? traits}) {
    _userId = userId;
    if (traits != null) setSuperProperties({'user_id': userId, ...traits});
    logEvent('user_identified', properties: {'user_id': userId, ...?traits});
    debugPrint('📊 [FluxyAnalytics] User identified: $userId');
    notifyListeners();
  }

  /// Reset user identity (e.g. on logout).
  void reset() {
    _userId = null;
    _superProperties.remove('user_id');
    _startSession(); // new session after logout
    debugPrint('📊 [FluxyAnalytics] Identity reset. New session: $_sessionId');
  }

  // ── Core Event Logging ───────────────────────────────────────────────────────

  /// Log a named event with optional properties.
  void logEvent(String name, {Map<String, dynamic>? properties}) {
    if (name.isEmpty) return;

    final merged = <String, dynamic>{
      ..._superProperties,
      'session_duration_s': sessionDuration.value.inSeconds,
      if (_userId != null) 'user_id': _userId!,
      if (_currentScreen != null) 'screen': _currentScreen!,
      ...?properties,
    };

    final event = FluxyEvent(
      name: name,
      properties: merged,
      sessionId: _sessionId!,
    );

    _queue.add(event);
    eventCount.value = _queue.length;
    notifyListeners();

    debugPrint('📊 [FluxyAnalytics] Event: $name ${properties ?? ''}');

    if (_queue.length >= _batchSize) {
      flush();
    }
  }

  // ── Convenience Loggers ──────────────────────────────────────────────────────

  /// Log a screen view. Updates the reactive `currentScreen` signal.
  void logScreen(String screenName, {Map<String, dynamic>? properties}) {
    _currentScreen = screenName;
    currentScreen.value = screenName;
    logEvent('screen_view', properties: {'screen_name': screenName, ...?properties});
  }

  /// Log a button or element tap.
  void logTap(String elementName, {String? screen, Map<String, dynamic>? extra}) {
    logEvent('tap', properties: {
      'element': elementName,
      if (screen != null) 'screen': screen,
      ...?extra,
    });
  }

  /// Log an error or exception.
  void logError(String message, {Object? error, StackTrace? stack}) {
    logEvent('error', properties: {
      'message': message,
      if (error != null) 'error': error.toString(),
      if (stack != null) 'stack': stack.toString().substring(0, 300),
    });
  }

  /// Log a feature flag / experiment exposure.
  void logExperiment(String experiment, String variant) {
    logEvent('experiment_exposed', properties: {
      'experiment': experiment, 'variant': variant,
    });
  }

  /// Log a conversion (purchase, signup, etc.).
  void logConversion(String goal, {double? value, String? currency}) {
    logEvent('conversion', properties: {
      'goal': goal,
      if (value != null) 'value': value,
      if (currency != null) 'currency': currency,
    });
  }

  // ── Timer Events ─────────────────────────────────────────────────────────────

  final Map<String, DateTime> _timers = {};

  /// Start a timed event.
  void startTiming(String name) => _timers[name] = DateTime.now();

  /// End a timed event and log it with `duration_ms` property.
  void stopTiming(String name, {Map<String, dynamic>? properties}) {
    final start = _timers.remove(name);
    if (start == null) return;
    final ms = DateTime.now().difference(start).inMilliseconds;
    logEvent('${name}_timed', properties: {'duration_ms': ms, ...?properties});
  }

  // ── Flush Queue ──────────────────────────────────────────────────────────────

  /// Immediately send all queued events to adapters.
  Future<void> flush() async {
    if (_queue.isEmpty) return;
    if (_adapters.isEmpty) {
      debugPrint('📊 [FluxyAnalytics] No adapters — flushing ${_queue.length} events (debug only).');
      if (kDebugMode) {
        for (final e in _queue) {
          debugPrint('   → ${jsonEncode(e.toJson())}');
        }
      }
      _queue.clear();
      eventCount.value = 0;
      notifyListeners();
      return;
    }

    final batch = List<FluxyEvent>.from(_queue);
    _queue.clear();
    eventCount.value = 0;
    notifyListeners();

    for (final adapter in _adapters) {
      try {
        await adapter.sendBatch(batch);
        debugPrint('📊 [FluxyAnalytics] Flushed ${batch.length} events via ${adapter.runtimeType}.');
      } catch (e) {
        // Re-queue on failure for retry
        debugPrint('❌ [FluxyAnalytics] Flush failed (${adapter.runtimeType}): $e. Re-queuing...');
        _queue.insertAll(0, batch);
        eventCount.value = _queue.length;
        notifyListeners();
      }
    }
  }

  /// Pending events not yet flushed.
  List<FluxyEvent> get pendingEvents => List.unmodifiable(_queue);

  // ── Session ──────────────────────────────────────────────────────────────────

  String? get sessionId => _sessionId;
  String? get userId   => _userId;

  void _startSession() {
    _sessionStart = DateTime.now();
    _sessionId = 'sess_${_sessionStart!.millisecondsSinceEpoch}';
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      sessionDuration.value = DateTime.now().difference(_sessionStart!);
    });
    logEvent('session_start');
  }

  void _scheduleFlush() {
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(_flushInterval, (_) => flush());
  }
}
