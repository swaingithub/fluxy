library fluxy;

// --- Infrastructure ---
export 'src/engine/fluxy_engine.dart';
export 'src/engine/plugin.dart';
export 'src/engine/controller.dart';
export 'src/di/fluxy_di.dart';
export 'src/routing/fluxy_router.dart';
export 'src/i18n/fluxy_i18n.dart';
export 'src/engine/haptics.dart';
export 'src/feedback/overlays.dart';
export 'src/engine/stability/stability.dart';
export 'src/engine/error_pipeline.dart';

// --- Reactive Core ---
export 'src/reactive/signal.dart';
export 'src/reactive/async_signal.dart';
export 'src/reactive/collections.dart';
export 'src/reactive/forms.dart';

// --- UI & Styling ---
export 'src/dsl/fx.dart';
export 'src/styles/style.dart';
export 'src/styles/tokens.dart';
export 'src/styles/fx_theme.dart';
export 'src/layout/fx_layout.dart';
export 'src/layout/fx_row.dart';
export 'src/layout/fx_col.dart';
export 'src/layout/fx_stack.dart';
export 'src/layout/fx_grid.dart';
export 'src/motion/fx_motion.dart';

// --- UI Components ---
export 'src/widgets/box.dart';
export 'src/widgets/button.dart';
export 'src/widgets/inputs.dart';
export 'src/widgets/text_box.dart';
export 'src/widgets/dropdown.dart';
export 'src/widgets/bottom_bar.dart';
export 'src/widgets/avatar.dart';
export 'src/widgets/badge.dart';
export 'src/widgets/fx_image.dart';
export 'src/widgets/fx_shimmer.dart';
export 'src/widgets/scroll.dart';
export 'src/widgets/list_box.dart';
export 'src/widgets/table.dart';
export 'src/widgets/fx_form.dart';
export 'src/widgets/fx_chart.dart';
export 'src/widgets/tab_stack.dart';
export 'src/widgets/advanced.dart';

// --- Advanced DSL & Responsiveness ---
export 'src/dsl/responsive.dart';
export 'src/dsl/modifiers.dart';

// --- Networking ---
export 'src/networking/fluxy_http.dart';

// --- Data ---
export 'src/data/repository.dart';

// --- Debug Tools ---
export 'src/debug/debug_config.dart';
export 'src/debug/fluxy_inspector.dart';
export 'src/debug/fluxy_debug.dart';

// --- DevTools ---
export 'src/devtools/fluxy_devtools.dart';

// --- Responsive & Layout Engines ---
export 'src/responsive/responsive_engine.dart';
export 'src/responsive/breakpoint_resolver.dart';
export 'src/engine/style_resolver.dart';
export 'src/engine/decoration_builder.dart';
export 'src/engine/diff_engine.dart';
