import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import '../reactive/signal.dart';

/// Debug configuration for Fluxy reactive system.
class ReactiveDebugConfig {
  /// Enable signal graph tracking
  final bool enableSignalGraph;
  
  /// Enable timeline tracking
  final bool enableTimeline;
  
  /// Enable memory tracking
  final bool enableMemoryTracking;
  
  /// Enable performance metrics
  final bool enablePerformanceMetrics;
  
  /// Maximum timeline entries to keep
  final int maxTimelineEntries;

  const ReactiveDebugConfig({
    this.enableSignalGraph = true,
    this.enableTimeline = true,
    this.enableMemoryTracking = true,
    this.enablePerformanceMetrics = true,
    this.maxTimelineEntries = 1000,
  });
}


/// Represents a node in the dependency graph.
class SignalNode {
  final String id;
  final String? label;
  final String type; // 'signal', 'computed', 'effect'
  final dynamic currentValue;
  final Set<String> dependencies;
  final Set<String> dependents;
  final DateTime createdAt;
  DateTime lastUpdated;
  int updateCount;

  SignalNode({
    required this.id,
    this.label,
    required this.type,
    required this.currentValue,
    required this.dependencies,
    required this.dependents,
    required this.createdAt,
    required this.lastUpdated,
    this.updateCount = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'type': type,
    'currentValue': currentValue.toString(),
    'dependencies': dependencies.toList(),
    'dependents': dependents.toList(),
    'createdAt': createdAt.toIso8601String(),
    'lastUpdated': lastUpdated.toIso8601String(),
    'updateCount': updateCount,
  };
}

/// Represents a timeline event.
class TimelineEvent {
  final DateTime timestamp;
  final String signalId;
  final String? signalLabel;
  final String eventType; // 'read', 'update', 'computed'
  final dynamic oldValue;
  final dynamic newValue;
  final Duration? computeTime;

  TimelineEvent({
    required this.timestamp,
    required this.signalId,
    this.signalLabel,
    required this.eventType,
    this.oldValue,
    this.newValue,
    this.computeTime,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'signalId': signalId,
    'signalLabel': signalLabel,
    'eventType': eventType,
    'oldValue': oldValue?.toString(),
    'newValue': newValue?.toString(),
    'computeTime': computeTime?.inMicroseconds,
  };
}

/// Performance metrics for the reactive system.
class PerformanceMetrics {
  int totalSignals = 0;
  int totalComputed = 0;
  int totalEffects = 0;
  int totalUpdates = 0;
  int totalReads = 0;
  Duration totalComputeTime = Duration.zero;
  Duration averageComputeTime = Duration.zero;
  int circularDependencyErrors = 0;
  
  Map<String, int> signalUpdateCounts = {};
  Map<String, Duration> signalComputeTimes = {};

  void reset() {
    totalSignals = 0;
    totalComputed = 0;
    totalEffects = 0;
    totalUpdates = 0;
    totalReads = 0;
    totalComputeTime = Duration.zero;
    averageComputeTime = Duration.zero;
    circularDependencyErrors = 0;
    signalUpdateCounts.clear();
    signalComputeTimes.clear();
  }

  Map<String, dynamic> toJson() => {
    'totalSignals': totalSignals,
    'totalComputed': totalComputed,
    'totalEffects': totalEffects,
    'totalUpdates': totalUpdates,
    'totalReads': totalReads,
    'totalComputeTime': totalComputeTime.inMicroseconds,
    'averageComputeTime': averageComputeTime.inMicroseconds,
    'circularDependencyErrors': circularDependencyErrors,
    'topSignalsByUpdates': _getTopSignals(signalUpdateCounts, 10),
    'topSignalsByComputeTime': _getTopSignals(
      signalComputeTimes.map((k, v) => MapEntry(k, v.inMicroseconds)),
      10,
    ),
  };

  List<Map<String, dynamic>> _getTopSignals(Map<String, num> map, int limit) {
    final sorted = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).map((e) => {
      'signalId': e.key,
      'value': e.value,
    }).toList();
  }
}

/// Central debugging system for Fluxy reactive engine.
class FluxyDebug {
  static ReactiveDebugConfig _config = const ReactiveDebugConfig();
  static bool _isEnabled = false;
  
  static final Map<String, SignalNode> _signalGraph = {};
  static final List<TimelineEvent> _timeline = [];
  static final PerformanceMetrics _metrics = PerformanceMetrics();
  static final List<String> _disposedSignals = [];


  /// Initializes the debug system with the given configuration.
  static void enable([ReactiveDebugConfig config = const ReactiveDebugConfig()]) {
    _config = config;
    _isEnabled = true;
    
    // Hook into reactive context
    FluxyReactiveContext.onSignalRead = _onSignalRead;
    FluxyReactiveContext.onSignalUpdate = _onSignalUpdate;
    
    debugPrint('Fluxy Debug Mode Enabled');
  }

  /// Disables the debug system.
  /// Disables the debug system.
  static void disable() {
    _isEnabled = false;
    FluxyReactiveContext.onSignalRead = null;
    FluxyReactiveContext.onSignalUpdate = null;
    debugPrint('Fluxy Debug Mode Disabled');
  }

  static bool _extensionsInitialized = false;

  /// Initializes the service extensions for DevTools.
  static void init() {
    if (_extensionsInitialized) return;
    _extensionsInitialized = true;

    // Return all active signals
    registerExtension('ext.fluxy.getSignals', (method, parameters) async {
      final signals = SignalRegistry.all.map((s) => {
        'id': s.id, 
        'label': s.label, 
        'value': s.toString(),
        'type': s is Computed ? 'Computed' : 'Signal',
        'subscribers': s.subscribers.length,
      }).toList();
      return ServiceExtensionResponse.result(jsonEncode({'signals': signals}));
    });

    // Update a signal value
    registerExtension('ext.fluxy.updateSignal', (method, parameters) async {
      try {
        final id = parameters['id'];
        final valueStr = parameters['value']; // Received as string
        
        if (id == null) return ServiceExtensionResponse.error(ServiceExtensionResponse.invalidParams, 'Missing id');

        final signal = SignalRegistry.find(id);
        if (signal == null) return ServiceExtensionResponse.error(ServiceExtensionResponse.invalidParams, 'Signal not found');

        // Type inference (Best effort)
        dynamic value = valueStr;
        if (int.tryParse(valueStr!) != null) value = int.parse(valueStr);
        else if (double.tryParse(valueStr) != null) value = double.parse(valueStr);
        else if (valueStr.toLowerCase() == 'true') value = true;
        else if (valueStr.toLowerCase() == 'false') value = false;

        // We can't safely cast to T here, so we assume dynamic update.
        // In Dart, if signal is Signal<int>, passing String throws runtime error.
        // We catch it.
        (signal as dynamic).value = value;

        return ServiceExtensionResponse.result(jsonEncode({'success': true, 'newValue': value.toString()}));
      } catch (e) {
        return ServiceExtensionResponse.error(ServiceExtensionResponse.extensionError, e.toString());
      }
    });

    // Provide graph data
    registerExtension('ext.fluxy.getGraph', (method, parameters) async {
       return ServiceExtensionResponse.result(jsonEncode(_signalGraph.map((k, v) => MapEntry(k, v.toJson()))));
    });
    
    debugPrint('Fluxy DevTools Extensions Registered 🛠️');
  }

  /// Registers a signal in the dependency graph.
  static void registerSignal(Signal signal, String type) {
    if (!_isEnabled || !_config.enableSignalGraph) return;
    
    _signalGraph[signal.id] = SignalNode(
      id: signal.id,
      label: signal.label,
      type: type,
      currentValue: signal is Computed ? 'lazy' : signal.value,
      dependencies: {},
      dependents: {},
      createdAt: DateTime.now(),
      lastUpdated: DateTime.now(),
    );

    
    if (type == 'signal') _metrics.totalSignals++;
    if (type == 'computed') _metrics.totalComputed++;
    if (type == 'effect') _metrics.totalEffects++;
  }

  /// Updates dependencies in the graph.
  static void updateDependencies(String subscriberId, Set<String> dependencies) {
    if (!_isEnabled || !_config.enableSignalGraph) return;
    
    final node = _signalGraph[subscriberId];
    if (node == null) return;
    
    // Clear old dependencies
    for (final depId in node.dependencies) {
      _signalGraph[depId]?.dependents.remove(subscriberId);
    }
    
    // Set new dependencies
    node.dependencies.clear();
    node.dependencies.addAll(dependencies);
    
    // Update dependents
    for (final depId in dependencies) {
      _signalGraph[depId]?.dependents.add(subscriberId);
    }
  }

  static void _onSignalRead(Signal signal) {
    if (!_isEnabled) return;
    
    if (_config.enablePerformanceMetrics) {
      _metrics.totalReads++;
    }
    
    if (_config.enableTimeline) {
      _addTimelineEvent(TimelineEvent(
        timestamp: DateTime.now(),
        signalId: signal.id,
        signalLabel: signal.label,
        eventType: 'read',
        newValue: signal.value,
      ));
    }
  }

  static void _onSignalUpdate(Signal signal, dynamic value) {
    if (!_isEnabled) return;
    
    if (_config.enableSignalGraph) {
      final node = _signalGraph[signal.id];
      if (node != null) {
        node.lastUpdated = DateTime.now();
        node.updateCount++;
      }
    }
    
    if (_config.enablePerformanceMetrics) {
      _metrics.totalUpdates++;
      _metrics.signalUpdateCounts[signal.id] = 
        (_metrics.signalUpdateCounts[signal.id] ?? 0) + 1;
    }
    
    if (_config.enableTimeline) {
      _addTimelineEvent(TimelineEvent(
        timestamp: DateTime.now(),
        signalId: signal.id,
        signalLabel: signal.label,
        eventType: 'update',
        newValue: value,
      ));
    }
  }

  static void _addTimelineEvent(TimelineEvent event) {
    _timeline.add(event);
    if (_timeline.length > _config.maxTimelineEntries) {
      _timeline.removeAt(0);
    }
  }

  /// Records a compute operation.
  static void recordCompute(String signalId, Duration duration) {
    if (!_isEnabled || !_config.enablePerformanceMetrics) return;
    
    _metrics.totalComputeTime += duration;
    _metrics.signalComputeTimes[signalId] = 
      (_metrics.signalComputeTimes[signalId] ?? Duration.zero) + duration;
    
    final totalComputes = _metrics.signalComputeTimes.length;
    if (totalComputes > 0) {
      _metrics.averageComputeTime = Duration(
        microseconds: _metrics.totalComputeTime.inMicroseconds ~/ totalComputes
      );
    }
  }

  /// Records a circular dependency error.
  static void recordCircularDependency() {
    if (!_isEnabled || !_config.enablePerformanceMetrics) return;
    _metrics.circularDependencyErrors++;
  }

  /// Marks a signal as disposed for memory leak detection.
  static void markDisposed(String signalId) {
    if (!_isEnabled || !_config.enableMemoryTracking) return;
    _disposedSignals.add(signalId);
    _signalGraph.remove(signalId);
  }

  /// Returns the current dependency graph.
  static Map<String, SignalNode> getDependencyGraph() {
    return Map.unmodifiable(_signalGraph);
  }

  /// Returns the timeline of events.
  static List<TimelineEvent> getTimeline({int? limit}) {
    if (limit != null && limit < _timeline.length) {
      return _timeline.sublist(_timeline.length - limit);
    }
    return List.unmodifiable(_timeline);
  }

  /// Returns performance metrics.
  static PerformanceMetrics getPerformanceMetrics() {
    return _metrics;
  }

  /// Detects potential memory leaks.
  static List<String> detectMemoryLeaks() {
    if (!_isEnabled || !_config.enableMemoryTracking) return [];
    
    final leaks = <String>[];
    final now = DateTime.now();
    
    for (final node in _signalGraph.values) {
      // Signal hasn't been updated in 10 minutes and has no dependents
      if (node.dependents.isEmpty && 
          now.difference(node.lastUpdated).inMinutes > 10) {
        leaks.add('${node.label ?? node.id} (unused for ${now.difference(node.lastUpdated).inMinutes}m)');
      }
    }
    
    return leaks;
  }

  /// Clears all debug data.
  static void clear() {
    _signalGraph.clear();
    _timeline.clear();
    _metrics.reset();
    _disposedSignals.clear();
  }

  /// Prints a summary of the current state.
  static void printSummary() {
    if (!_isEnabled) {
      debugPrint('Fluxy Debug is not enabled');
      return;
    }
    
    debugPrint('=== Fluxy Debug Summary ===');
    debugPrint('Signals: ${_metrics.totalSignals}');
    debugPrint('Computed: ${_metrics.totalComputed}');
    debugPrint('Effects: ${_metrics.totalEffects}');
    debugPrint('Total Updates: ${_metrics.totalUpdates}');
    debugPrint('Total Reads: ${_metrics.totalReads}');
    debugPrint('Avg Compute Time: ${_metrics.averageComputeTime.inMicroseconds}μs');
    debugPrint('Circular Errors: ${_metrics.circularDependencyErrors}');
    debugPrint('Active Signals: ${_signalGraph.length}');
    debugPrint('Timeline Events: ${_timeline.length}');
    
    final leaks = detectMemoryLeaks();
    if (leaks.isNotEmpty) {
      debugPrint('⚠️ Potential Memory Leaks:');
      for (final leak in leaks) {
        debugPrint('  - $leak');
      }
    }
    debugPrint('========================');
  }

  /// Exports all debug data as JSON.
  static Map<String, dynamic> exportData() {
    return {
      'enabled': _isEnabled,
      'config': {
        'enableSignalGraph': _config.enableSignalGraph,
        'enableTimeline': _config.enableTimeline,
        'enableMemoryTracking': _config.enableMemoryTracking,
        'enablePerformanceMetrics': _config.enablePerformanceMetrics,
      },
      'signalGraph': _signalGraph.map((k, v) => MapEntry(k, v.toJson())),
      'timeline': _timeline.map((e) => e.toJson()).toList(),
      'metrics': _metrics.toJson(),
      'memoryLeaks': detectMemoryLeaks(),
    };
  }
}
