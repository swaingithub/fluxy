library fluxy;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'src/devtools/fluxy_devtools.dart';
import 'src/dsl/fx.dart'; // Import for usage
import 'src/styles/fx_theme.dart'; // Import for usage

// Styles & Foundation
export 'src/styles/style.dart';
export 'src/styles/fx_theme.dart';
export 'src/dsl/fx.dart';
export 'src/motion/fx_motion.dart';
export 'src/devtools/fluxy_devtools.dart';
export 'src/dsl/modifiers.dart';

// Primary Widgets
export 'src/widgets/box.dart';
export 'src/widgets/flex_box.dart';
export 'src/widgets/grid_box.dart';
export 'src/widgets/stack_box.dart';
export 'src/widgets/text_box.dart';
export 'src/widgets/tab_stack.dart';
export 'src/widgets/dropdown.dart';
export 'src/widgets/bottom_bar.dart';
export 'src/widgets/avatar.dart';
export 'src/widgets/badge.dart';
export 'src/widgets/table.dart';

// Reactive Core
export 'src/reactive/signal.dart';
export 'src/reactive/async_signal.dart';
export 'src/reactive/collections.dart';
export 'src/reactive/forms.dart';

// Infrastructure
export 'src/di/fluxy_di.dart';
export 'src/routing/fluxy_router.dart';

// Responsive & Layout Engines
export 'src/responsive/responsive_engine.dart';
export 'src/responsive/breakpoint_resolver.dart';
export 'src/engine/style_resolver.dart';
export 'src/engine/decoration_builder.dart';
export 'src/engine/diff_engine.dart';

// Debugging Tools
export 'src/debug/debug_config.dart';
export 'src/debug/fluxy_inspector.dart';
export 'src/debug/fluxy_debug.dart';

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

/// The global entry point for the Fluxy framework.
class Fluxy {
  // OTA Shortcuts
  static Future<void> update(String manifestUrl) => FluxyRemote.update(manifestUrl);

  // Navigation Shortcuts
  static Future<T?> to<T>(String routeName, {Object? arguments}) => 
      FluxyRouter.to<T>(routeName, arguments: arguments);

  static Future<T?> off<T, TO>(String routeName, {TO? result, Object? arguments}) => 
      FluxyRouter.off<T, TO>(routeName, result: result, arguments: arguments);

  static Future<T?> offAll<T>(String routeName, {Object? arguments}) => 
      FluxyRouter.offAll<T>(routeName, arguments: arguments);
  
  static void back<T>([T? result]) => FluxyRouter.back<T>(result);

  // DI Shortcuts
  static T find<T>({String? tag}) => FluxyDI.find<T>(tag: tag);
  
  static void put<T>(T instance, {String? tag}) => FluxyDI.put<T>(instance, tag: tag);

  static void lazyPut<T>(T Function() factory, {String? tag}) => 
      FluxyDI.lazyPut<T>(factory, tag: tag);
  
  // I18n Shortcuts
  static void setLocale(Locale locale) => FluxyI18n.setLocale(locale);

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

    return Fx(() => MaterialApp(
      title: title,
      navigatorKey: FluxyRouter.navigatorKey,
      onGenerateRoute: FluxyRouter.onGenerateRoute,
      initialRoute: initialRoute?.path ?? '/',
      theme: theme,
      darkTheme: darkTheme,
      themeMode: themeMode ?? FxTheme.mode, // Use internal theme if not provided
      debugShowCheckedModeBanner: debugShowCheckedModeBanner,
      navigatorObservers: FluxyRouter.observers,
      builder: (context, child) {
        // Global Error Boundary - Senior Level Production Protection
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return Material(
            child: Container(
              color: Colors.black,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                   const SizedBox(height: 16),
                   const Text(
                     "A production error occurred",
                     style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                   ),
                   const SizedBox(height: 8),
                   Text(
                     details.exception.toString(),
                     textAlign: TextAlign.center,
                       style: TextStyle(color: Colors.redAccent.withValues(alpha: 0.9), fontSize: 12, fontFamily: 'monospace'),
                   ),
                   if (!kReleaseMode) ...[
                     const SizedBox(height: 16),
                     Expanded(
                       child: SingleChildScrollView(
                         child: Text(
                           details.stack.toString(),
                             style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, fontFamily: 'monospace'),
                         ),
                       ),
                     ),
                   ],
                ],
              ),
            ),
          );
        };
        
        return builder?.call(context, child) ?? child!;
      },
    ));
  }
}

/// Extensions on BuildContext to provide easy access to Fluxy services.
extension FluxyContextExtension on BuildContext {
  /// Navigates to a new page.
  Future<T?> to<T>(String route, {Map<String, dynamic>? arguments}) => FluxyRouter.to<T>(route, arguments: arguments);

  /// Replaces current page.
  Future<T?> off<T, TO>(String route, {TO? result, Map<String, dynamic>? arguments}) => FluxyRouter.off<T, TO>(route, result: result, arguments: arguments);

  /// Clears stack and navigates.
  Future<T?> offAll<T>(String route, {Map<String, dynamic>? arguments}) => FluxyRouter.offAll<T>(route, arguments: arguments);

  /// Goes back.
  void back<T>([T? result]) => FluxyRouter.back<T>(result);

  /// Finds a dependency.
  T find<T>({String? tag}) => FluxyDI.find<T>(tag: tag);
}
