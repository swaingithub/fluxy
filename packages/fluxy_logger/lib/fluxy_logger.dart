import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:fluxy/fluxy.dart';

/// Industrial Audit & Logging Engine for Fluxy.
/// Standardizes semantic bracketed logs for production monitoring.
class FluxyLoggerPlugin extends FluxyPlugin {
  @override
  String get name => 'fluxy_logger';

  final level = flux(LogLevel.info);
  final logs = flux<List<String>>([]);

  @override
  FutureOr<void> onRegister() {
    Fluxy.log('Logger', 'READY', 'Audit pipeline active.');
  }

  /// Logs a system operation.
  void sys(String message, {String? tag}) {
    _log(message, tag: tag ?? 'SYS', type: 'INFO');
  }

  /// Logs a data/state operation.
  void data(String message, {String? tag}) {
    _log(message, tag: tag ?? 'DATA', type: 'INFO');
  }

  /// Logs a critical failure.
  void fatal(String message, {Object? error, StackTrace? stack}) {
    _log(message, tag: 'FATAL', type: 'PANIC');
    if (error != null) debugPrint('[PANIC] Error: $error');
  }

  void _log(String message, {required String tag, required String type}) {
    final timestamp = DateTime.now().toIso8601String().split('T').last.substring(0, 8);
    final formatted = '[$timestamp] [$type] [$tag] $message';
    
    // Add to internal audit list (limited to last 1000)
    final currentLogs = List<String>.from(logs.value);
    if (currentLogs.length > 1000) currentLogs.removeAt(0);
    currentLogs.add(formatted);
    logs.value = currentLogs;

    // Output to console in debug mode
    if (kDebugMode) {
      debugPrint(formatted);
    }
  }

  /// Clears all session logs.
  void clear() => logs.value = [];
}

enum LogLevel { debug, info, warn, error, fatal }
