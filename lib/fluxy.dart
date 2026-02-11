library fluxy;

// Styles
export 'src/styles/style.dart';

// DSL & Primitives
export 'src/dsl/fluent_api.dart';
export 'src/dsl/ui.dart';
export 'src/widgets/box.dart';
export 'src/widgets/flex_box.dart';
export 'src/widgets/grid_box.dart';
export 'src/widgets/stack_box.dart';
export 'src/widgets/text_box.dart';

// Engine
export 'src/engine/layout_engine.dart';
export 'src/engine/layout_node.dart';
export 'src/engine/tree_builder.dart';
export 'src/engine/flex_layout_solver.dart';
export 'src/engine/grid_layout_solver.dart';
export 'src/engine/style_resolver.dart';
export 'src/engine/decoration_builder.dart';
export 'src/engine/tailwind_parser.dart';
export 'src/engine/diff_engine.dart';
export 'src/engine/widget_cache_manager.dart';

// Responsive
export 'src/responsive/responsive_engine.dart';
export 'src/responsive/breakpoint_resolver.dart';

// Debug
export 'src/debug/debug_config.dart';
export 'src/debug/fluxy_inspector.dart';

// Reactive & Patterns
export 'src/reactive/signal.dart';
export 'src/reactive/async_signal.dart';
export 'src/di/fluxy_di.dart';
export 'src/routing/fluxy_router.dart';
export 'src/dsl/fx.dart';

import 'src/di/fluxy_di.dart';
import 'src/routing/fluxy_router.dart';

/// The global entry point for the Fluxy framework.
class Fluxy {
  // Navigation Shortcuts
  static Future<T?> to<T>(String routeName, {Object? arguments}) => 
      FluxyRouter.to<T>(routeName);
  
  static void back<T>([T? result]) => FluxyRouter.back<T>(result);

  // DI Shortcuts
  static T find<T>({String? tag}) => FluxyDI.find<T>(tag: tag);
  
  static void put<T>(T instance, {String? tag}) => FluxyDI.put<T>(instance, tag: tag);

  static void lazyPut<T>(T Function() factory, {String? tag}) => 
      FluxyDI.lazyPut<T>(factory, tag: tag);
}
