import 'package:flutter/material.dart';

typedef FluxyRouteBuilder = Widget Function(Map<String, String> params);

/// The Fluxy Navigation Engine.
class FluxyRouter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final Map<String, FluxyRouteBuilder> _routes = {};
  
  static void setRoutes(Map<String, FluxyRouteBuilder> routes) {
    _routes.addAll(routes);
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? '/');
    
    // Simple path matching with parameter support (e.g. /user/:id)
    for (var entry in _routes.entries) {
      final params = _matchPath(entry.key, uri.path);
      if (params != null) {
        return MaterialPageRoute(
          builder: (context) => entry.value(params),
          settings: settings,
        );
      }
    }
    return null;
  }

  /// Navigates to a new page.
  static Future<T?> to<T>(String routeName, {Map<String, dynamic>? arguments}) {
    return navigatorKey.currentState!.pushNamed<T>(routeName, arguments: arguments);
  }

  /// Replaces current page with a new one.
  static Future<T?> off<T, TO>(String routeName, {TO? result, Map<String, dynamic>? arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed<T, TO>(routeName, result: result, arguments: arguments);
  }

  /// Clears the navigation stack and pushes a new route.
  static Future<T?> offAll<T>(String routeName, {Map<String, dynamic>? arguments}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(routeName, (route) => false, arguments: arguments);
  }

  /// Goes back to previous page.
  static void back<T>([T? result]) {
    navigatorKey.currentState!.pop<T>(result);
  }

  static Map<String, String>? _matchPath(String pattern, String path) {
    final patternParts = pattern.split('/');
    final pathParts = path.split('/');
    
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
