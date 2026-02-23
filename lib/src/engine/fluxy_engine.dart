import 'package:flutter/material.dart';

import 'plugin.dart';

import 'plugin_registry.dart';

import '../routing/fluxy_router.dart';

import '../styles/fx_theme.dart';

import '../dsl/fx.dart';

import '../di/fluxy_di.dart';

import 'stability/stability_metrics.dart';

import '../reactive/signal.dart';

import '../networking/fluxy_http.dart';



/// The entry point for the Fluxy framework.

class Fluxy {

  /// Initializes the Fluxy framework.

  static Future<void> init() async {

    WidgetsFlutterBinding.ensureInitialized();

    debugPrint('[SYS] [KERNEL] Fluxy initialized.');

    

    // Register internal services or default plugins if any

    

    // Initialize all registered plugins

    await FluxyPluginEngine.onRegisterAll();

    

    // Notify all plugins that app is ready

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

  /// Access to global networking engine.
  static final http = FluxyHttp();



  /// Helper to wrap the app with DevTools or other debug features.

  static Widget debug({required Widget child}) {

    // In a real implementation, this would inject the Fluxy Inspector

    return child;

  }



  /// Shorthand for dependency injection.

  static T use<T>({String? tag}) => FluxyDI.find<T>(tag: tag);

  /// Alias for dependency injection (same as use).
  static T find<T>({String? tag}) => FluxyDI.find<T>(tag: tag);



  /// Registers a global middleware.

  static void addMiddleware(FluxyMiddleware middleware) => FluxyReactiveContext.addMiddleware(middleware);



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

      return MaterialApp(

        title: title,

        debugShowCheckedModeBanner: false,

        theme: theme ?? ThemeData.light(useMaterial3: true),

        darkTheme: darkTheme ?? ThemeData.dark(useMaterial3: true),

        themeMode: mode,

        navigatorKey: FluxyRouter.navigatorKey,

        home: home,

        initialRoute: initialRoute,

        onGenerateRoute: (settings) {

           FluxyRouter.setRoutes(routes, unknownRoute: unknownRoute);

           return FluxyRouter.onGenerateRoute(settings);

        },

      );

    });

  }

}

