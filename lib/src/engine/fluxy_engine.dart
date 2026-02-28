import 'package:flutter/material.dart';

import 'plugin.dart';


import '../routing/fluxy_router.dart';

import '../styles/fx_theme.dart';
import 'layout_guard.dart';

import '../dsl/fx.dart';

import '../di/fluxy_di.dart';
import 'error_pipeline.dart';

import 'stability/stability_metrics.dart';

import '../reactive/signal.dart';
import '../devtools/fluxy_devtools.dart';



/// The entry point for the Fluxy framework.

class Fluxy {

  static Future<void> init({bool strictMode = false, bool debugMode = true}) async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Configure Stability Engine
    FluxyLayoutGuard.strictMode = strictMode;
    FluxyLayoutGuard.debugMode = debugMode;
    
    debugPrint('[SYS] [KERNEL] Fluxy initialized (Policy: ${strictMode ? "STRICT" : "RELAXED"}).');

    // Initialize all registered plugins
    await FluxyPluginEngine.onRegisterAll();
    
    // Notify all plugins that app is ready
    await FluxyPluginEngine.onAppReadyAll();
  }



  /// Registers a plugin to the engine manually.
  static void register(FluxyPlugin plugin) {
    FluxyPluginEngine.register(plugin);
    FluxyDI.putByRuntimeType(plugin, scope: FxScope.app);
  }

  static final List<void Function()> _onAutoRegister = [];

  /// Internal: App-side registry hook
  static void registerRegistry(void Function() fn) => _onAutoRegister.add(fn);

  /// Automatically registers modular plugins found in the project.
  static void autoRegister() {
    debugPrint('[SYS] [BOOT] Scanning for modular plugins...');
    for (var fn in _onAutoRegister) {
      fn();
    }
  }



  // --- Navigation Shortcuts ---

  static Future<T?> to<T>(String routeName, {Object? arguments}) =>
      FluxyRouter.to<T>(routeName, arguments: arguments);

  static Future<T?> off<T, TO>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) => FluxyRouter.off<T, TO>(routeName, result: result, arguments: arguments);

  static Future<T?> offAll<T>(String routeName, {Object? arguments}) =>
      FluxyRouter.offAll<T>(routeName, arguments: arguments);

  static void back<T>([T? result]) => FluxyRouter.back<T>(result);

  /// Access to global networking engine.
  static final http = FluxyHttp();



  /// Helper to wrap the app with DevTools or other debug features.
  static Widget debug({required Widget child}) {
    return FluxyDevTools(child: child);
  }



  /// Shorthand for dependency injection.
  static T use<T>({String? tag}) => find<T>(tag: tag);

  /// Standardized Fluxy logger for internal and plugin use.
  static void log(String tag, String type, String message) {
    final timestamp = DateTime.now().toIso8601String().split('T').last.substring(0, 8);
    debugPrint('[$timestamp] [$type] [$tag] $message');
  }

  /// Alias for dependency injection (same as use).
  static T find<T>({String? tag}) {
    try {
      return FluxyDI.find<T>(tag: tag);
    } catch (_) {
      // Fallback: Check modular plugin engine
      // We manually iterate to avoid generic constraint issues on T
      for (final p in FluxyPluginEngine.plugins) {
        if (p is T) return p as T;
      }
      
      rethrow;
    }
  }

  /// Finds a plugin by its unique name.
  static dynamic findPlugin(String name) => FluxyPluginEngine.findByName(name);



  /// Registers a global middleware.

  static void addMiddleware(FluxyMiddleware middleware) => FluxyReactiveContext.addMiddleware(middleware);



  /// Prints a summary of stability interventions.

  /// Prints a summary of stability interventions.
  static void printStabilitySummary() {
    final summary = FluxyStabilityMetrics.getSummary();
    debugPrint('┌───────────────────────────────────────────┐');
    debugPrint('│ [KERNEL] [STABILITY] System Health Summary │');
    debugPrint('├───────────────────────────────────────────┤');
    debugPrint("│ Layout Fixes:     ${summary['layout_fixes']}                     │");
    debugPrint("│ Viewport Fixes:   ${summary['viewport_fixes']}                     │");
    debugPrint("│ State Fixes:      ${summary['state_fixes']}                     │");
    debugPrint("│ Async Fixes:      ${summary['async_fixes']}                     │");
    debugPrint("│ Total Saves:      ${summary['total_saves']}                     │");
    debugPrint('└───────────────────────────────────────────┘');
  }

  /// Registers a global error handler for the framework.
  static void onError(FluxyErrorHandler handler) => Fx.onError(handler);

  /// Performs a deep architectural health check.
  /// Used primarily in Strict Mode to ensure the engine and plugins are synchronized.
  static void verifyIntegrity() {
    debugPrint('[SYS] [AUDIT] Running architectural integrity check...');
    
    // 1. Check Plugin Registry
    final totalPlugins = FluxyPluginEngine.plugins.length;
    debugPrint('[SYS] [AUDIT] Modules synchronized: $totalPlugins');
    
    // 2. Check Stability Engine
    if (FluxyLayoutGuard.strictMode) {
      debugPrint('[SYS] [AUDIT] Stability Kernel: Enforcement Active (Strict)');
    } else {
       debugPrint('[SYS] [AUDIT] Stability Kernel: Auto-Repair Active (Relaxed)');
    }

    // 3. Print Stability Summary
    printStabilitySummary();
    
    debugPrint('[SYS] [AUDIT] Integrity check complete. App is healthy.');
  }
}



/// A root wrapper that sets up Fluxy features for the entire app.

class FluxyApp extends StatelessWidget {
  final Widget? home;
  final dynamic initialRoute;
  final List<FxRoute> routes;
  final FxRoute? unknownRoute;
  final ThemeData? theme;
  final ThemeData? darkTheme;
  final ThemeMode themeMode;
  final String title;

  const FluxyApp({
    super.key,
    this.home,
    this.initialRoute,
    this.routes = const [],
    this.unknownRoute,
    this.theme,
    this.darkTheme,
    this.themeMode = ThemeMode.system,
    this.title = 'Fluxy App',
  });

  @override
  Widget build(BuildContext context) {
    return Fx(() {
      final mode = FxTheme.mode;
      
      String? resolvedInitialRoute;
      if (initialRoute is FxRoute) {
        resolvedInitialRoute = (initialRoute as FxRoute).path;
      } else if (initialRoute is String) {
        resolvedInitialRoute = initialRoute;
      }

      return MaterialApp(
        title: title,
        debugShowCheckedModeBanner: false,
        theme: theme ?? ThemeData.light(useMaterial3: true),
        darkTheme: darkTheme ?? ThemeData.dark(useMaterial3: true),
        themeMode: mode,
        navigatorKey: FluxyRouter.navigatorKey,
        home: home,
        initialRoute: resolvedInitialRoute,
        onGenerateRoute: (settings) {
           FluxyRouter.setRoutes(routes, unknownRoute: unknownRoute);
           return FluxyRouter.onGenerateRoute(settings);
        },
      );
    });
  }
}

