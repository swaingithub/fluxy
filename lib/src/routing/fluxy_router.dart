import 'dart:async';
import 'package:flutter/material.dart';
import '../reactive/signal.dart';
import '../dsl/fx.dart';

typedef FluxyRouteBuilder = Widget Function(Map<String, String> params, Object? args);
typedef FluxyGuard = FutureOr<bool> Function();
typedef FluxyMiddleware = FutureOr<bool> Function(String path);
typedef FluxyTransitionBuilder = Widget Function(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child);

enum FxTransition { native, fade, slideUp, slideRight, slideLeft, zoom, none, custom }

/// Defines a route in Fluxy.
class FxRoute {
  final String path;
  final FluxyRouteBuilder builder;
  final List<FluxyGuard> guards;
  final String? redirectTo;
  final FxTransition transition;
  final FluxyTransitionBuilder? transitionBuilder;
  final Duration? transitionDuration;
  final List<FxRoute> children; // Nested routes

  const FxRoute({
    required this.path,
    required this.builder,
    this.guards = const [],
    this.redirectTo,
    this.transition = FxTransition.native,
    this.transitionBuilder,
    this.transitionDuration,
    this.children = const [],
  });
  
  // Quick constructors for transitions
  static FxRoute fade(String path, FluxyRouteBuilder builder) => 
      FxRoute(path: path, builder: builder, transition: FxTransition.fade);
      
  static FxRoute slideUp(String path, FluxyRouteBuilder builder) => 
      FxRoute(path: path, builder: builder, transition: FxTransition.slideUp);

  /// Helper to apply shared guards/settings to a group of routes.
  static List<FxRoute> group({
    required List<FluxyGuard> guards,
    required List<FxRoute> routes,
    String? prefix,
  }) {
    return routes.map((r) => FxRoute(
      path: prefix != null ? '$prefix${r.path}' : r.path,
      builder: r.builder,
      guards: [...guards, ...r.guards],
      redirectTo: r.redirectTo,
      transition: r.transition,
      transitionBuilder: r.transitionBuilder,
      transitionDuration: r.transitionDuration,
      children: r.children,
    )).toList();
  }
}

// ... FxOutlet ...



/// A widget that renders a nested navigator for sub-routes.
class FxOutlet extends StatelessWidget {
  final String scope;
  final String initialRoute;
  final List<FxRoute> routes;
  final FxRoute? unknownRoute;
  final List<NavigatorObserver>? observers;

  const FxOutlet({
    super.key,
    required this.scope,
    required this.initialRoute,
    required this.routes,
    this.unknownRoute,
    this.observers,
  });

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: FluxyRouter.getKey(scope),
      initialRoute: initialRoute,
      observers: observers ?? [],
      onGenerateRoute: (settings) {
         return FluxyRouter.generateScopedRoute(settings, routes, unknownRoute);
      },
    );
  }
}

/// The Fluxy Navigation Engine (Router 2.0 - Production Stable).
class FluxyRouter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final Map<String, GlobalKey<NavigatorState>> _nestedKeys = {};
  static final List<FxRoute> _routes = [];
  static final List<FluxyMiddleware> _middlewares = [];
  static final List<NavigatorObserver> _observers = [];
  static FxRoute? _unknownRoute;

  /// Gets the navigator key for a specific scope, or the root key if not found.
  static GlobalKey<NavigatorState> getKey([String? scope]) {
    if (scope == null) return navigatorKey;
    return _nestedKeys.putIfAbsent(scope, () => GlobalKey<NavigatorState>());
  }
  
  static void setRoutes(List<FxRoute> routes, {FxRoute? unknownRoute}) {
    _routes.clear();
    _routes.addAll(routes);
    _unknownRoute = unknownRoute;
  }

  static void use(FluxyMiddleware middleware) {
    _middlewares.add(middleware);
  }

  /// Enables clean URLs on Web (removes the '#' symbol).
  static void urlStrategy() {
    // Platform-specific implementation required
  }

  static void addObserver(NavigatorObserver observer) {
    _observers.add(observer);
  }

  static List<NavigatorObserver> get observers => List.from(_observers);

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    return generateScopedRoute(settings, _routes, _unknownRoute);
  }

  /// reusable route generator for root and scopes
  static Route<dynamic>? generateScopedRoute(RouteSettings settings, List<FxRoute> routes, FxRoute? unknownRoute) {
    final uri = Uri.parse(settings.name ?? '/');
    
    for (var route in routes) {
      final params = _matchPath(route.path, uri.path);
      if (params != null) {
        params.addAll(uri.queryParameters);
        return _createRoute(route, settings, params);
      }
    }

    if (unknownRoute != null) {
      return _createRoute(unknownRoute, settings, {});
    }

    return null;
  }

  static Route<dynamic> _createRoute(FxRoute route, RouteSettings settings, Map<String, String> params) {
    _GuardWrapper builder(context) => _GuardWrapper(
      route: route,
      params: params,
      arguments: settings.arguments,
    );

    if (route.transition == FxTransition.native) {
      return MaterialPageRoute(builder: builder, settings: settings);
    }

    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionDuration: route.transitionDuration ?? const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (route.transition == FxTransition.custom && route.transitionBuilder != null) {
          return route.transitionBuilder!(context, animation, secondaryAnimation, child);
        }
        
        switch (route.transition) {
          case FxTransition.fade:
            return FadeTransition(opacity: animation, child: child);
          case FxTransition.slideUp:
            return SlideTransition(
              position: Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            );
          case FxTransition.slideRight:
            return SlideTransition(
              position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            );
          case FxTransition.slideLeft:
             return SlideTransition(
              position: Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            );
          case FxTransition.zoom:
            return ScaleTransition(scale: animation, child: child);
          case FxTransition.none:
            return child;
          default:
            return child;
        }
      },
    );
  }

  /// Navigates to a new page.
  static Future<T?> to<T>(String routeName, {Object? arguments, String? scope}) async {
    if (!await _runMiddleware(routeName)) return null;

    final state = getKey(scope).currentState;
    if (state == null) {
      debugPrint("FluxyRouter: Navigator state is null for scope: ${scope ?? 'root'}. Check if your navigator is mounted.");
      return null;
    }
    return state.pushNamed<T>(routeName, arguments: arguments);
  }

  /// Replaces current page with a new one.
  static Future<T?> off<T, TO>(String routeName, {TO? result, Object? arguments, String? scope}) async {
    if (!await _runMiddleware(routeName)) return null;
    
    final state = getKey(scope).currentState;
    if (state == null) {
      debugPrint("FluxyRouter: Navigator state is null for scope: ${scope ?? 'root'}. Check if your navigator is mounted.");
      return null;
    }
    return state.pushReplacementNamed<T, TO>(routeName, result: result, arguments: arguments);
  }

  /// Clears the navigation stack and pushes a new route.
  static Future<T?> offAll<T>(String routeName, {Object? arguments, String? scope}) async {
    if (!await _runMiddleware(routeName)) return null;
    
    final state = getKey(scope).currentState;
    if (state == null) {
      debugPrint("FluxyRouter: Navigator state is null for scope: ${scope ?? 'root'}. Check if your navigator is mounted.");
      return null;
    }
    return state.pushNamedAndRemoveUntil<T>(routeName, (route) => false, arguments: arguments);
  }

  /// Goes back to previous page.
  static void back<T>([T? result, String? scope]) {
    final state = getKey(scope).currentState;
    if (state == null) {
      debugPrint("FluxyRouter: Navigator state is null for scope: ${scope ?? 'root'}. Cannot go back.");
      return;
    }
    state.pop<T>(result);
  }
  
  /// Runs global middleware. Returns false if navigation should abort.
  static Future<bool> _runMiddleware(String path) async {
    for (final middleware in _middlewares) {
      final res = await middleware(path);
      if (!res) return false;
    }
    return true;
  }

  static Map<String, String>? _matchPath(String pattern, String path) {
    if (pattern == path) return {}; // Exact match optimization & root handling
    
    final patternParts = pattern.split('/').where((e) => e.isNotEmpty).toList();
    final pathParts = path.split('/').where((e) => e.isNotEmpty).toList();
    
    if (patternParts.length != pathParts.length) return null;
    
    final Map<String, String> params = {};
    for (var i = 0; i < patternParts.length; i++) {
      if (patternParts[i].startsWith(':')) {
        params[patternParts[i].substring(1)] = pathParts[i];
      } else if (patternParts[i] != pathParts[i]) {
        return null;
      }
    }
    return params;
  }
}


class _GuardWrapper extends StatefulWidget {
  final FxRoute route;
  final Map<String, String> params;
  final Object? arguments;

  const _GuardWrapper({
    required this.route, 
    required this.params, 
    this.arguments,
  });

  @override
  State<_GuardWrapper> createState() => _GuardWrapperState();
}

class _GuardWrapperState extends State<_GuardWrapper> {
  final Signal<bool?> _isAuthorized = flux(null);

  @override
  void initState() {
    super.initState();
    _checkGuards();
  }

  Future<void> _checkGuards() async {
    if (widget.route.guards.isEmpty) {
      _isAuthorized.value = true;
      return;
    }

    for (final guard in widget.route.guards) {
      final res = await guard();
      if (!res) {
        _isAuthorized.value = false;
        if (widget.route.redirectTo != null) {
          FluxyRouter.offAll(widget.route.redirectTo!);
        }
        return;
      }
    }
    _isAuthorized.value = true;
  }

  @override
  Widget build(BuildContext context) {
    return _GuardReactiveView(
      isAuthorized: _isAuthorized,
      onCheck: _checkGuards,
      builder: () => widget.route.builder(widget.params, widget.arguments),
    );
  }
}

class _GuardReactiveView extends StatelessWidget {
  final Signal<bool?> isAuthorized;
  final VoidCallback onCheck;
  final Widget Function() builder;

  const _GuardReactiveView({
    required this.isAuthorized,
    required this.onCheck,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    // We use a separate StatelessWidget to leverage Fluxy's reactivity 
    // for the guard status without rebuilding the whole wrapper unnecessarily.
    return Fx(() {
      final status = isAuthorized.value;
      if (status == null) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (!status) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Access Denied", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: onCheck, child: const Text("Retry")),
              ],
            ),
          ),
        );
      }
      return builder();
    });
  }
}
