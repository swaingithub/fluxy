library fluxy;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'src/devtools/fluxy_devtools.dart';
import 'src/dsl/fx.dart'; // Import for usage
import 'src/styles/fx_theme.dart'; // Import for usage

// Styles & Foundation
export 'src/styles/style.dart';
export 'src/styles/tokens.dart';
export 'src/styles/fx_theme.dart';
export 'src/dsl/fx.dart';
export 'src/motion/fx_motion.dart';
export 'src/devtools/fluxy_devtools.dart';
export 'src/dsl/modifiers.dart';
export 'src/dsl/responsive.dart';

// Layout
export 'src/layout/fx_row.dart';
export 'src/layout/fx_col.dart';
export 'src/layout/fx_grid.dart';
export 'src/layout/fx_stack.dart';
export 'src/layout/fx_layout.dart';

// Primary Widgets
export 'src/widgets/box.dart';
export 'src/widgets/flex_box.dart';
export 'src/widgets/grid_box.dart';
export 'src/widgets/stack_box.dart';
export 'src/widgets/text_box.dart';
export 'src/widgets/tab_stack.dart';
export 'src/widgets/inputs.dart';
export 'src/widgets/dropdown.dart';
export 'src/widgets/bottom_bar.dart';
export 'src/widgets/avatar.dart';
export 'src/widgets/button.dart';
export 'src/widgets/fx_image.dart';
export 'src/widgets/fx_shimmer.dart';
export 'src/widgets/badge.dart';
export 'src/widgets/table.dart';
export 'src/widgets/fx_chart.dart';
export 'src/widgets/fx_form.dart'; // FxForm
export 'src/widgets/scroll.dart'; // FxScroll
export 'src/widgets/advanced.dart'; // FxRefresh, FxParallax, FxInfiniteList
export 'src/feedback/overlays.dart'; // FxToast, FxLoader

// Reactive Core
export 'src/reactive/signal.dart';
export 'src/reactive/async_signal.dart';
export 'src/reactive/collections.dart';
export 'src/reactive/forms.dart';

// Data & Offline-First
export 'src/data/repository.dart';

// Infrastructure
export 'src/di/fluxy_di.dart';
export 'src/routing/fluxy_router.dart';
export 'src/engine/controller.dart';
export 'src/engine/haptics.dart';
export 'src/networking/fluxy_http.dart';

// Responsive & Layout Engines
export 'src/responsive/responsive_engine.dart';
export 'src/responsive/breakpoint_resolver.dart';
export 'src/engine/style_resolver.dart';
export 'src/engine/decoration_builder.dart';
export 'src/engine/diff_engine.dart';
export 'src/engine/plugin.dart';
export 'src/engine/error_pipeline.dart';
export 'src/engine/stability/stability.dart';
export 'src/engine/stability/stability_metrics.dart';
export 'src/test/stability_benchmarks.dart';

// Debugging Tools
export 'src/debug/debug_config.dart';
export 'src/debug/fluxy_inspector.dart';
export 'src/debug/fluxy_debug.dart';

// Core Plugins
export 'src/plugins/fluxy_storage.dart';
export 'src/plugins/fluxy_analytics.dart';
export 'src/plugins/fluxy_permissions.dart';
export 'src/plugins/fluxy_auth.dart';
export 'src/plugins/fluxy_camera.dart';
export 'src/plugins/fluxy_notifications.dart';
export 'src/plugins/fluxy_connectivity.dart';
export 'src/plugins/fluxy_biometric.dart';

// Internationalization
export 'src/i18n/fluxy_i18n.dart';
// OTA
export 'src/ota/fluxy_remote.dart';
export 'src/ota/sdui_renderer.dart';
export 'src/ota/style_parser.dart';

import 'src/di/fluxy_di.dart';
import 'src/routing/fluxy_router.dart';
import 'src/i18n/fluxy_i18n.dart';
import 'src/ota/fluxy_remote.dart';
import 'src/reactive/signal.dart';
import 'src/networking/fluxy_http.dart';
import 'src/engine/plugin.dart';
import 'src/engine/error_pipeline.dart';
import 'src/engine/layout_guard.dart';
import 'src/engine/stability/stability_metrics.dart';
import 'src/engine/plugin_registry.dart';

/// The global entry point for the Fluxy framework.
class Fluxy {
  // --- Core Lifecycle ---

  /// Initializes the Fluxy framework, including storage and core engines.
  /// Must be called at the start of main().
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // 1. Hook into Global Errors
    FluxyError.hookIntoFlutter();

    // 2. Setup Debug Tooling
    if (!kReleaseMode) {
      FluxyHttp.configure(interceptors: [FluxyNetworkLogger()]);
    }

    // 3. Initialize Persistence
    await FluxyPersistence.init();
    await FluxyPersistence.hydrate();

    // 3. Register & Boot Plugins
    await FluxyPluginEngine.onRegisterAll();

    // 4. Signal App Ready to Plugins
    await FluxyPluginEngine.onAppReadyAll();
  }

  // --- OTA Shortcuts ---
  static Future<void> update(String manifestUrl) =>
      FluxyRemote.update(manifestUrl);

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

  // --- DI Shortcuts ---
  static T find<T>({String? tag}) => FluxyDI.find<T>(tag: tag);

  static T put<T>(T instance, {String? tag, FxScope scope = FxScope.app}) =>
      FluxyDI.put<T>(instance, tag: tag, scope: scope);

  static void lazyPut<T>(T Function() factory, {String? tag, FxScope scope = FxScope.app}) =>
      FluxyDI.lazyPut<T>(factory, tag: tag, scope: scope);

  // --- State Management Shortcuts ---
  static void use(FluxyMiddleware middleware) =>
      FluxyReactiveContext.addMiddleware(middleware);

  static R untracked<R>(R Function() fn) => FluxyReactiveContext.untracked(fn);

  // --- I18n Shortcuts ---
  static void setLocale(Locale locale) => FluxyI18n.setLocale(locale);

  // --- Plugin System ---

  /// Registers a plugin to extend Fluxy's functionality.
  static void register(FluxyPlugin plugin) => FluxyPluginEngine.register(plugin);

  /// Finds a registered plugin by name.
  static T? findPlugin<T extends FluxyPlugin>() => FluxyPluginEngine.find<T>();

  /// Automatically registers all plugins found in the workspace dependencies.
  /// This calls the auto-generated registry created by the Fluxy CLI.
  static void autoRegister() {
    debugPrint("[INIT] [Platform] Registering Fluxy plugins...");
    registerFluxyPlugins();
  }

  // --- Error Pipeline ---
  
  /// Registers a global error handler for the entire framework and app.
  static void onError(FluxyErrorHandler handler) => FluxyError.onError(handler);

  /// Reports a manual error to the global pipeline.
  static void reportError(Object error, [StackTrace? stack]) =>
      FluxyError.report(error, stack);

  /// The global HTTP client for networking.
  static final http = FluxyHttp();

  /// Enables or disables Strict Mode for the Layout Guard.
  /// When true, layout violations throw an exception in development.
  static void setStrictMode(bool enabled) => FluxyLayoutGuard.strictMode = enabled;

  /// Prints a summary of all stability saves in the current session.
  static void printStabilitySummary() {
    final s = FluxyStabilityMetrics.getSummary();
    debugPrint("┌───────────────────────────────────────────┐");
    debugPrint("│ [KERNEL] STABILITY SESSION SUMMARY         │");
    debugPrint("├───────────────────────────────────────────┤");
    debugPrint("│ [LAYOUT]    Fixes:    ${s['layout_fixes'].toString().padRight(10)}      │");
    debugPrint("│ [VIEWPORT]  Fixes:    ${s['viewport_fixes'].toString().padRight(10)}      │");
    debugPrint("│ [STATE]     Fixes:    ${s['state_fixes'].toString().padRight(10)}      │");
    debugPrint("│ [ASYNC]     Fixes:    ${s['async_fixes'].toString().padRight(10)}      │");
    debugPrint("├───────────────────────────────────────────┤");
    debugPrint("│ [TOTAL]     Actions:  ${s['total_saves'].toString().padRight(10)}      │");
    debugPrint("└───────────────────────────────────────────┘");
  }

  /// Enables the Fluxy Debug Inspector overlay.
  static Widget debug({required Widget child}) => FluxyDevTools(child: child);
}

/// A pre-configured MaterialApp for Fluxy projects.
/// Automatically hooks up routing, navigation keys, and observers.
class FluxyApp extends StatelessWidget {
  final String title;
  final FxRoute? initialRoute;
  final List<FxRoute> routes;
  final FxRoute? unknownRoute;
  final ThemeData? theme;
  final ThemeData? darkTheme;
  final ThemeMode? themeMode;
  final bool debugShowCheckedModeBanner;
  final List<NavigatorObserver>? observers;
  final Widget Function(BuildContext, Widget?)? builder;

  const FluxyApp({
    super.key,
    this.title = 'Fluxy App',
    this.initialRoute,
    this.routes = const [],
    this.unknownRoute,
    this.theme,
    this.darkTheme,
    this.themeMode,
    this.debugShowCheckedModeBanner = false,
    this.observers,
    this.builder,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize the router
    FluxyRouter.setRoutes(routes, unknownRoute: unknownRoute);
    if (observers != null) {
      for (var obs in observers!) {
        FluxyRouter.addObserver(obs);
      }
    }

    return Fx(
      () => MaterialApp(
        title: title,
        navigatorKey: FluxyRouter.navigatorKey,
        onGenerateRoute: FluxyRouter.onGenerateRoute,
        initialRoute: initialRoute?.path ?? '/',
        theme: theme,
        darkTheme: darkTheme,
        themeMode:
            themeMode ?? FxTheme.mode, // Use internal theme if not provided
        debugShowCheckedModeBanner: debugShowCheckedModeBanner,
        navigatorObservers: FluxyRouter.observers,
        builder: (context, child) {
          // Global Error Boundary - Senior Level Production Protection
          ErrorWidget.builder = (FlutterErrorDetails details) {
            return Material(
              child: LayoutBuilder(builder: (context, constraints) {
                // If we are in an unbounded container (which likely caused the error), 
                // clamp our height to 400px so we don't trigger another layout crash.
                final safeH = constraints.hasBoundedHeight ? constraints.maxHeight : 400.0;
                
                return Container(
                  height: safeH,
                  color: Colors.black,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.redAccent,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Fluxy Stability Intercept",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        details.exception.toString().split('\n').first,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                          color: Colors.redAccent.withValues(alpha: 0.9),
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                      if (!kReleaseMode) ...[
                        const SizedBox(height: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              details.stack.toString(),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 10,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            );
          };

          return builder?.call(context, child) ?? child ?? const SizedBox.shrink();
        },
      ),
    );
  }
}

