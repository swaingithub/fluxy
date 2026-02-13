import 'package:flutter/material.dart';
import '../dsl/fx.dart';
import '../reactive/signal.dart';
import '../routing/fluxy_router.dart';

/// A widget that manages a nested navigation stack, typically used for Tab views.
class FxNestedStack extends StatelessWidget {
  final String scope;
  final String initialRoute;
  final List<FxRoute> routes;

  const FxNestedStack({
    super.key,
    required this.scope,
    required this.initialRoute,
    required this.routes,
  });

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: FluxyRouter.getKey(scope),
      initialRoute: initialRoute,
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? initialRoute);
        
        for (var route in routes) {
          // Flatten match for nested navigators to simplify sub-routing
          if (route.path == uri.path) {
             return MaterialPageRoute(
               builder: (context) => route.builder({}, settings.arguments),
               settings: settings,
             );
          }
        }
        return null;
      },
    );
  }
}

/// A scaffold that implements parallel navigation stacks for tabs.
class FxTabScaffold extends StatelessWidget {
  final Signal<int> currentIndex;
  final List<FxTabItem> tabs;
  final Widget Function(BuildContext, int)? bottomNavBuilder;

  const FxTabScaffold({
    super.key,
    required this.currentIndex,
    required this.tabs,
    this.bottomNavBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Fx(() => IndexedStack(
        index: currentIndex.value,
        children: tabs.map((tab) => FxNestedStack(
          scope: tab.label,
          initialRoute: tab.initialRoute,
          routes: tab.routes,
        )).toList(),
      )),
      bottomNavigationBar: bottomNavBuilder != null 
        ? Fx(() => bottomNavBuilder!(context, currentIndex.value))
        : Fx(() => BottomNavigationBar(
            currentIndex: currentIndex.value,
            onTap: (index) => currentIndex.value = index,
            items: tabs.map((tab) => BottomNavigationBarItem(
              icon: Icon(tab.icon),
              label: tab.label,
            )).toList(),
          )),
    );
  }
}

class FxTabItem {
  final String label;
  final IconData icon;
  final String initialRoute;
  final List<FxRoute> routes;

  FxTabItem({
    required this.label,
    required this.icon,
    required this.initialRoute,
    required this.routes,
  });
}
