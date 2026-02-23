import 'package:flutter/material.dart';
import 'plugin.dart';
import 'plugin_registry.dart';
import '../routing/fluxy_router.dart';
import '../styles/fx_theme.dart';
import '../dsl/fx.dart';
import '../di/fluxy_di.dart';
import 'stability/stability_metrics.dart';
import '../reactive/signal.dart';
import 'error_pipeline.dart';
import '../networking/fluxy_http.dart';
import '../i18n/fluxy_i18n.dart';
// import '../ota/fluxy_remote.dart';

/// The entry point for the Fluxy framework.
class Fluxy {
  /// Whether strict mode is enabled for additional runtime checks
  static bool _strictMode = false;

  /// Enables or disables strict mode for additional runtime checks
  static void setStrictMode(bool enabled) {
    _strictMode = enabled;
    debugPrint('[SYS] [KERNEL] Strict mode ${enabled ? "enabled" : "disabled"}');
  }

  /// Checks if strict mode is currently enabled
  static bool get isStrictMode => _strictMode;
  /// Initializes the Fluxy framework.
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('[SYS] [KERNEL] Fluxy initialized.');
    
    // 1. Hook into Global Errors
    FluxyError.hookIntoFlutter();
    
    // 2. Setup Debug Tooling (if not release mode)
    // Note: FluxyHttp and FluxyNetworkLogger would be implemented in networking module
    
    // 3. Initialize Persistence (if available)
    // Note: FluxyPersistence would be implemented in storage module
    
    // 4. Register internal services or default plugins if any
    
    // 5. Initialize all registered plugins
    await FluxyPluginEngine.onRegisterAll();
    
    // 6. Notify all plugins that app is ready
    await FluxyPluginEngine.onAppReadyAll();
  }

  /// Registers a plugin to the engine.
  static void register(FluxyPlugin plugin) => FluxyPluginEngine.register(plugin);

  /// Automatically registers all plugins from the generated registry.
  static void autoRegister() {
    debugPrint("[INIT] [Platform] Registering Fluxy plugins...");
    registerFluxyPlugins();
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

  /// Helper to wrap the app with DevTools or other debug features.
  static Widget debug({required Widget child}) {
    // In a real implementation, this would inject the Fluxy Inspector
    // For now, return child as placeholder
    return child;
  }

  /// Shorthand for dependency injection.
  static T use<T>({String? tag}) => FluxyDI.find<T>(tag: tag);

  /// Dependency injection shortcuts.
  static T find<T>({String? tag}) => FluxyDI.find<T>(tag: tag);

  static T put<T>(T instance, {String? tag}) => FluxyDI.put<T>(instance, tag: tag);

  static void lazyPut<T>(T Function() factory, {String? tag}) => FluxyDI.lazyPut<T>(factory, tag: tag);

  /// Registers a global middleware.
  static void addMiddleware(FluxyMiddleware middleware) => FluxyReactiveContext.addMiddleware(middleware);

  /// State management shortcuts.
  static void useMiddleware(FluxyMiddleware middleware) => FluxyReactiveContext.addMiddleware(middleware);

  static R untracked<R>(R Function() fn) => FluxyReactiveContext.untracked(fn);

  /// Registers a global error handler.
  static void onError(FluxyErrorHandler handler) => FluxyError.onError(handler);

  /// Reports a manual error to the global pipeline.
  static void reportError(Object error, [StackTrace? stack]) => FluxyError.report(error, stack);

  /// The global HTTP client for networking.
  static final http = FluxyHttp();

  /// I18n shortcuts.
  static void setLocale(Locale locale) => FluxyI18n.setLocale(locale);

  /// Plugin system shortcuts.
  static T? findPlugin<T extends FluxyPlugin>() => FluxyPluginEngine.find<T>();

  /// OTA shortcuts.
  // static Future<void> update(String manifestUrl) => FluxyRemote.update(manifestUrl);

  /// Prints a summary of stability interventions.
  static void printStabilitySummary() {
    final summary = FluxyStabilityMetrics.getSummary();
    debugPrint("┌───────────────────────────────────────────┐");
    debugPrint("│ [KERNEL] [STABILITY] System Health Summary │");
    debugPrint("├───────────────────────────────────────────┤");
    debugPrint("│ Layout Fixes:     ${summary['layout_fixes']}                     │");
    debugPrint("│ Viewport Fixes:   ${summary['viewport_fixes']}                     │");
    debugPrint("│ State Fixes:      ${summary['state_fixes']}                     │");
    debugPrint("│ Async Fixes:      ${summary['async_fixes']}                     │");
    debugPrint("│ Total Saves:      ${summary['total_saves']}                     │");
    debugPrint("└───────────────────────────────────────────┘");
  }
}

/// A root wrapper that sets up Fluxy features for the entire app.
class FluxyApp extends StatelessWidget {
  final Widget? home;
  final String? initialRoute;
  final List<FxRoute> routes;
  final FxRoute? unknownRoute;
  final ThemeData? theme;
  final ThemeData? darkTheme;
  final ThemeMode? themeMode;
  final String title;
  final bool debugShowCheckedModeBanner;
  final List<NavigatorObserver> observers;
  final TransitionBuilder? builder;

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
    this.debugShowCheckedModeBanner = true,
    this.observers = const [],
    this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Fx(() {
      final mode = themeMode ?? FxTheme.mode;
      return MaterialApp(
        title: title,
        debugShowCheckedModeBanner: debugShowCheckedModeBanner,
        theme: theme ?? ThemeData.light(useMaterial3: true),
        darkTheme: darkTheme ?? ThemeData.dark(useMaterial3: true),
        themeMode: mode,
        navigatorKey: FluxyRouter.navigatorKey,
        home: home,
        initialRoute: initialRoute,
        navigatorObservers: observers,
        builder: builder,
        onGenerateRoute: (settings) {
           FluxyRouter.setRoutes(routes, unknownRoute: unknownRoute);
           return FluxyRouter.onGenerateRoute(settings);
        },
      );
    });
  }
}
