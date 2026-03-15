import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../engine/plugin.dart';
export '../networking/fluxy_http.dart';
import '../networking/fluxy_http.dart';
import '../responsive/responsive_engine.dart';
import '../styles/style.dart';
import '../styles/tokens.dart'; // Tokens
import 'modifiers.dart'; // Extension
import '../widgets/box.dart';
import '../widgets/text_box.dart';
import '../reactive/signal.dart';
import '../reactive/async_signal.dart';
import '../widgets/inputs.dart'; // Existing FxTextField
import '../widgets/button.dart'; // FxButton
import '../motion/fx_motion.dart';
import '../routing/fluxy_router.dart';
import '../widgets/dropdown.dart';
import '../widgets/bottom_bar.dart';
import '../widgets/avatar.dart';
import '../widgets/badge.dart';
import '../widgets/fx_image.dart';
import '../widgets/fx_shimmer.dart';
import '../widgets/scroll.dart';
export '../widgets/sidebar.dart';

// Re-export specific styles/tokens for easy access if needed
export '../styles/style.dart';
export 'modifiers.dart';
import '../styles/fx_theme.dart';
import '../widgets/list_box.dart';
import '../widgets/table.dart';
import '../widgets/fx_form.dart';
import '../widgets/advanced.dart';
import '../feedback/overlays.dart';
import '../reactive/forms.dart';
import '../layout/fx_grid.dart';
import '../layout/fx_row.dart';
import '../layout/fx_col.dart';
import '../layout/fx_stack.dart';
import '../engine/error_pipeline.dart';
import '../widgets/fx_chart.dart';

export '../widgets/fx_chart.dart';
export '../widgets/fx_tabs.dart';
import '../layout/fx_layout.dart';
import '../engine/stability/stability.dart';
import '../engine/metrics/observability.dart';
import '../engine/stability/feature_toggle.dart';
import '../engine/layout_guard.dart'; // Corrected import

// Import plugin extensions for direct access to modular packages
// ignore: unused_import
import 'fx_extensions.dart';

  /// The hyper-minimal Fx API for Fluxy.
  /// Designed for maximum builder velocity and zero boilerplate reactivity.
  class Fx extends StatefulWidget {
  /// Whether the framework is in Strict mode (throws on layout violations).
  static bool get strictMode => FluxyLayoutGuard.strictMode;

  /// Whether the framework is in Debug mode (logs violations).
  static bool get debugMode => FluxyLayoutGuard.debugMode;

    final Widget Function() builder;
    final String? label;
  
    const Fx(this.builder, {super.key, this.label});
  
    @override
    State<Fx> createState() => _FxState();
  
    // --- Design Tokens ---
    // Expose global design scale: Fx.space.sm
    static const space = FxTokens.space;
    static const radius = FxTokens.radius;
    static const font = FxTokens.font;
    static const shadow = FxTokens.shadow;

    // --- Semantic Theme Proxies ---
    // These automatically resolve to the current theme's colors.
    static Color get primary => FxTokens.colors.primary;
    static Color get secondary => FxTokens.colors.secondary;
    static Color get success => FxTokens.colors.success;
    static Color get error => FxTokens.colors.error;
    static Color get warning => FxTokens.colors.warning;
    static Color get info => FxTokens.colors.info;
    static Color get background => FxTokens.colors.background;
    static Color get surface => FxTokens.colors.surface;
    static Color get textColor => FxTokens.colors.text;
    static Color get muted => FxTokens.colors.muted;
  
    // --- Global Feedback & Overlays ---
  
    /// Access to global toast system.
    /// Usage: `Fx.toast("Hello")` or `Fx.toast.success("Great job")`
    static const _FxToastHelper toast = _FxToastHelper();
  
    /// Access to global loader system.
    /// Usage: `Fx.loader.show()`
    static const _FxLoaderHelper loader = _FxLoaderHelper();
  
    /// Access to global dialog system.
    /// Usage: `Fx.dialog.alert(...)`
    static const _FxDialogHelper dialog = _FxDialogHelper();
  
    // --- Core Services ---
  
    /// Access to global networing engine.
    static final http = FluxyHttp();
  
    /// Access to global platform services.
    /// Usage: `Fx.platform.auth`, `Fx.platform.camera`, `Fx.platform.permissions`, etc.
    static const platform = _FxPlatformHelper();
  
    /// High-performance sensory haptic feedback.
    static dynamic get haptic => platform.haptic;
  
    // --- Theme Management ---
  
    /// Toggles between light and dark mode.
    static void toggleTheme() => FxTheme.toggle();
  
    /// Checks if the current theme is dark.
    static bool get isDarkMode => FxTheme.isDarkMode;
  
    /// Sets the theme mode.
    static void setThemeMode(ThemeMode mode) => FxTheme.setMode(mode);
  
  
    /// Registers a global error handler.
    static void onError(FluxyErrorHandler handler) => FluxyError.onError(handler);
  
    // --- Responsive Layouts ---
  
  /// Advanced Layout Switcher. Automatically chooses layout based on screen size.
  static Widget layout({
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) => FxLayout(mobile: mobile, tablet: tablet, desktop: desktop);
  
  /// A reactive feature-toggle wrapper.
  /// If [key] is disabled via FluxyFeatureToggle, this returns [fallback] (default: empty).
  static Widget feature(String key, {required Widget child, Widget fallback = const SizedBox.shrink()}) {
    return Fx(() => FluxyFeatureToggle.isEnabled(key) ? child : fallback);
  }

  static Widget dashboard({
    required Widget body,
    Widget? navbar,
  }) {
    return layout(
      mobile: scaffold(
        appBar: navbar != null
            ? PreferredSize(
                preferredSize: const Size.fromHeight(64), child: navbar)
            : null,
        body: body,
      ),
      desktop: scaffold(
        body: Fx.row(
          children: [
            Expanded(
              child: Fx.col(
                children: [
                  if (navbar != null) navbar,
                  Expanded(child: body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Structural Responsive Helpers
  /// -----------------------------

  /// Shows children only on mobile devices (< 600px).
  static Widget mobile(dynamic children) => _responsiveWrapper(mobile: children);

  /// Shows children only on tablet devices (600px - 1200px).
  static Widget tablet(dynamic children) => _responsiveWrapper(tablet: children);

  /// Shows children only on desktop devices (>= 1200px).
  static Widget desktop(dynamic children) => _responsiveWrapper(desktop: children);

  /// Helper to wrap children in a responsive layout.
  static Widget _responsiveWrapper({dynamic mobile, dynamic tablet, dynamic desktop}) {
    Widget toWidget(dynamic value) {
      if (value == null) return const SizedBox.shrink();
      if (value is Widget) return value;
      if (value is List<Widget>) return Fx.col(children: value);
      return Fx.text(value.toString());
    }

    return Fx.layout(
      mobile: toWidget(mobile),
      tablet: tablet != null ? toWidget(tablet) : (mobile != null ? const SizedBox.shrink() : toWidget(desktop)),
      desktop: desktop != null ? toWidget(desktop) : (tablet != null || mobile != null ? const SizedBox.shrink() : const SizedBox.shrink()),
    );
  }

  /// A responsive value utility.
  /// Usage: `final gap = Fx.responsiveValue(context, xs: 10, md: 20)`
  static T responsiveValue<T>(
    BuildContext context, {
    required T xs,
    T? sm,
    T? md,
    T? lg,
    T? xl,
  }) =>
      ResponsiveEngine.value<T>(context,
          xs: xs, sm: sm, md: md, lg: lg, xl: xl);

  /// Alias for responsiveValue
  static T on<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) => responsiveValue(context, xs: mobile, md: tablet, lg: desktop);

  /// A responsive container that centers content and adds a max-width on large screens.
  /// Perfect for web applications.
  static Widget container({
    required Widget child,
    double? maxWidth,
    FxStyle style = FxStyle.none,
  }) {
    return Fx(() {
      final context = FluxyReactiveContext.currentContext;
      if (context == null) return child;
      final autoWidth = ResponsiveEngine.containerWidth(context);
      return Center(
        child: Box(
          style: style.merge(FxStyle(
            width: maxWidth ?? autoWidth,
            alignment: Alignment.topCenter,
          )),
          child: child,
        ),
      );
    });
  }

  /// Advanced Grid Layout System.
  static const grid = _FxGridHelper();

  /// Expose the Spring configuration for animations.
  static const spring = Spring;

  /// Staggered Reveal Animation for a list of widgets.
  /// Usage: `Fx.reveal(children: [...])`
  static Widget reveal({
    required List<Widget> children,
    Duration interval = const Duration(milliseconds: 50),
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeOutCubic,
    double? slide = 20,
    double? fade = 0,
  }) {
    return FxReveal(
      interval: interval,
      duration: duration,
      curve: curve,
      slide: slide,
      fade: fade,
      children: children,
    );
  }

  /// Horizontal Layout (Row).
  static Widget row({
    required List<Widget> children,
    MainAxisAlignment justify = MainAxisAlignment.start,
    @Deprecated('Use alignItems instead. This will be removed in future versions.')
    CrossAxisAlignment? items,
    CrossAxisAlignment alignItems = CrossAxisAlignment.center,
    MainAxisAlignment? mainAxisAlignment,
    CrossAxisAlignment? crossAxisAlignment,
    double gap = 0,
    FxStyle style = FxStyle.none,
    MainAxisSize size = MainAxisSize.min,
    bool responsive = false,
  }) {
    // Priority: alignment aliases (new) -> alignItems (web style) -> items (deprecated) -> default center
    final resolvedJustify = mainAxisAlignment ?? justify;
    final resolvedItems = crossAxisAlignment ?? items ?? alignItems;

    return FxRow(
      justify: resolvedJustify,
      items: resolvedItems,
      gap: gap,
      style: style,
      size: size,
      responsive: responsive,
      children: children,
    );
  }



  /// Vertical Layout (Column).
  static Widget col({
    required List<Widget> children,
    MainAxisAlignment justify = MainAxisAlignment.start,
    @Deprecated('Use alignItems instead. This will be removed in future versions.')
    CrossAxisAlignment? items,
    CrossAxisAlignment alignItems = CrossAxisAlignment.center,
    MainAxisAlignment? mainAxisAlignment,
    CrossAxisAlignment? crossAxisAlignment,
    double gap = 0,
    FxStyle style = FxStyle.none,
    MainAxisSize size = MainAxisSize.min,
  }) {
    // Priority: alignment aliases (new) -> alignItems (web style) -> items (deprecated) -> default center
    final resolvedJustify = mainAxisAlignment ?? justify;
    final resolvedItems = crossAxisAlignment ?? items ?? alignItems;

    return FxCol(
      justify: resolvedJustify,
      items: resolvedItems,
      gap: gap,
      style: style,
      size: size,
      children: children,
    );
  }

  /// A scrollable list.
  /// Wraps [ListView.separated].
  static Widget list({
    List<Widget>? children,
    int? itemCount,
    IndexedWidgetBuilder? itemBuilder,
    Axis scrollDirection = Axis.vertical,
    FxStyle style = FxStyle.none,
    double gap = 0,
    bool shrinkWrap = false,
    ScrollPhysics? physics,
    VoidCallback? onTap,
    String? className,
    FxResponsiveStyle? responsive,
    ScrollController? controller,
  }) {
    return ListBox(
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      scrollDirection: scrollDirection,
      style: style,
      gap: gap,
      shrinkWrap: shrinkWrap,
      physics: physics,
      onTap: onTap,
      className: className,
      responsive: responsive,
      controller: controller,
      children: children,
    );
  }

  /// A subscription-based infinite scroll list.
  /// Ideal for lazy-loading feeds and paginated data.
  static Widget infiniteList({
    required int itemCount,
    required IndexedWidgetBuilder itemBuilder,
    required Future<void> Function() onLoadMore,
    bool hasMore = true,
    Widget? loadingIndicator,
    FxStyle style = FxStyle.none,
    ScrollController? controller,
  }) {
    return FxInfiniteList(
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      onLoadMore: onLoadMore,
      hasMore: hasMore,
      loadingIndicator: loadingIndicator,
      style: style,
      controller: controller,
    );
  }

  /// A parallax wrapper for smooth scroll-based background animations.
  static Widget parallax({
    required Widget child,
    required ScrollController controller,
    double speed = 0.5,
  }) {
    return FxParallax(
      controller: controller,
      speed: speed,
      child: child,
    );
  }

  /// A premium Pull-To-Refresh wrapper.
  static Widget refresh({
    required Widget child,
    required Future<void> Function() onRefresh,
    Color? color,
    Color? backgroundColor,
  }) {
    return FxRefresh(
      onRefresh: onRefresh,
      color: color,
      backgroundColor: backgroundColor,
      child: child,
    );
  }

  // --- Core Primitives ---

  /// Creates a reactive text widget.
  /// 
  /// [data] - The text to display (String, Signal<String>, etc.)
  /// [style] - Optional [FxStyle] to apply.
  /// [className] - Optional Tailwind-like utility classes.
  /// [responsive] - Optional responsive style.
  static Widget text(
    dynamic data, {
    FxStyle style = FxStyle.none,
    String? className,
    FxResponsiveStyle? responsive,
  }) {
    return TextBox(
      data: data ?? '',
      style: style,
      className: className,
      responsive: responsive,
    );
  }


  // --- Layout Primitives ---

  /// A gap (spacing) widget.
  /// Works in both Column (vertical) and Row (horizontal).
  /// Essentially a SizedBox with equal width and height.
  static Widget gap(double size) => SizedBox(width: size, height: size);

  /// A horizontal gap (spacing) widget.
  /// Explicitly intended for Rows.
  static Widget hgap(double size) => SizedBox(width: size);

  /// Conditional helper.
  static _FxCondHelper get cond => const _FxCondHelper();

  /// A generic box container.
  static Box box({
    dynamic child,
    dynamic children,
    FxStyle style = FxStyle.none,
    String? className,
    FxResponsiveStyle? responsive,
    VoidCallback? onTap,
  }) {
    return Box(
      child: child,
      children: children,
      style: style,
      className: className,
      responsive: responsive,
      onTap: onTap,
    );
  }

  /// A labeled form field helper.
  static Widget field({
    required String label,
    required Flux<String> signal,
    String? placeholder,
    IconData? icon,
    bool isPassword = false,
    List<Validator<String>>? validators,
    FxStyle style = FxStyle.none,
  }) {
    return Fx.col(
      alignItems: CrossAxisAlignment.start,
      gap: 6,
      children: [
        Fx.text(label).font.xs().font.bold().color(FxTokens.colors.muted).ml(4),
        Fx.input(
          signal: signal,
          placeholder: placeholder,
          icon: icon,
          obscureText: isPassword,
          validators: validators,
          style: style,
        ),
      ],
    );
  }


  /// A pre-configured Scaffold with a centered container for the body.
  /// Ideal for standard web pages.
  static Widget page({
    required Widget child,
    PreferredSizeWidget? appBar,
    Widget? floatingActionButton,
    Widget? drawer,
    Widget? bottomNavigationBar,
    bool useContainer = true,
    double? maxWidth,
    Color? backgroundColor,
    FxStyle style = FxStyle.none,
  }) {
    return scaffold(
      appBar: appBar,
      body: useContainer
          ? container(child: child, maxWidth: maxWidth, style: style)
          : child,
      floatingActionButton: floatingActionButton,
      drawer: drawer,
      bottomNavigationBar: bottomNavigationBar,
      backgroundColor: backgroundColor,
    );
  }

  /// A quick navbar template for web/desktop.
  static Widget navbar({
    required Widget logo,
    required List<Widget> actions,
    Widget? leading,
    double? height = 64,
    FxStyle style = FxStyle.none,
  }) {
    return Box(
      style: FxStyle(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        backgroundColor: Colors.white,
        justifyContent: MainAxisAlignment.spaceBetween,
        alignItems: CrossAxisAlignment.center,
        direction: Axis.horizontal,
      ).merge(style),
      children: [
        Fx.row(
          gap: 16,
          children: [
            if (leading != null) leading,
            logo,
          ],
        ),
        Fx.row(children: actions, gap: 20),
      ],
    );
  }

  /// A wrapper for Scaffold.
  static Widget scaffold({
    PreferredSizeWidget? appBar,
    Widget? body,
    Widget? floatingActionButton,
    Widget? drawer,
    Widget? bottomNavigationBar,
    Color? backgroundColor,
    bool resizeToAvoidBottomInset = true,
  }) {
    return Scaffold(
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      drawer: drawer,
      bottomNavigationBar: bottomNavigationBar,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }


  /// Data Table.
  static Widget table<T>({
    required List<T> data,
    required List<FxTableColumn<T>> columns,
    bool striped = true,
    VoidCallback? onRowTap,
    FxStyle style = FxStyle.none,
    String? className,
    FxResponsiveStyle? responsive,
  }) {
    return FxTable<T>(
      data: data,
      columns: columns,
      striped: striped,
      onRowTap: onRowTap,
      style: style,
      className: className,
      responsive: responsive,
    );
  }

  /// Centers its child in both axes. The "Holy Grail" of layouts.
  static Widget center({required Widget child, FxStyle style = FxStyle.none}) {
    return Box(
      style: FxStyle(
        justifyContent: MainAxisAlignment.center,
        alignItems: CrossAxisAlignment.center,
        width: double.infinity,
        height: double.infinity,
      ).merge(style),
      child: Center(child: child),
    );
  }

  /// Expanded layout.
  static Widget expand({required Widget child, int flex = 1}) {
    return Expanded(flex: flex, child: child);
  }

  /// Wrap layout.
  static Widget wrap({
    required List<Widget> children,
    double spacing = 0,
    double runSpacing = 0,
    Axis direction = Axis.horizontal,
  }) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      direction: direction,
      children: children,
    );
  }

  /// Scrollable container (SingleChildScrollView).
  static Widget scroll({
    required Widget child,
    Axis direction = Axis.vertical,
    FxStyle style = FxStyle.none,
    bool showScrollbar = true,
  }) {
    return FxScroll(
      direction: direction,
      style: style,
      showScrollbar: showScrollbar,
      child: child,
    );
  }

  /// NEW: Atomic Viewport Architecture
  /// Uses CustomScrollView with Slivers for maximum stability.
  static Widget viewport({
    required List<Widget> slivers,
    Axis direction = Axis.vertical,
    ScrollController? controller,
    bool showScrollbar = true,
  }) {
    final scroll = CustomScrollView(
      controller: controller,
      scrollDirection: direction,
      slivers: slivers,
    );

    if (!showScrollbar) return scroll;
    return Scrollbar(child: scroll);
  }

  /// NEW: Sliver Wrapper
  static Widget sliver(Widget child) {
    if (child is SliverToBoxAdapter || child is SliverList || child is SliverGrid) {
      return child;
    }
    return SliverToBoxAdapter(child: child);
  }

  /// A common SaaS layout primitive: a centered card that is also scrollable.
  /// Uses LayoutBuilder to ensure content is centered when small, but scrollable when large.
  static Widget scrollCenter({
    required Widget child,
    FxStyle style = FxStyle.none,
  }) {
    return Box(
      style: style,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final minH = constraints.hasBoundedHeight ? constraints.maxHeight : 0.0;
          final minW = constraints.hasBoundedWidth ? constraints.maxWidth : 0.0;
          
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: minH,
                minWidth: minW,
              ),
              child: Center(child: child),
            ),
          );
        },
      ),
    );
  }

  /// Icon primitive.
  static Widget icon(
    IconData icon, {
    Color? color,
    double? size,
    VoidCallback? onTap,
  }) {
    final i = Icon(icon, color: color, size: size);
    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: i);
    }
    return i;
  }

  /// Advanced Image primitive with support for network, asset, and file sources.
  /// Supports chainable filters (blur, grayscale), states (loading, error), and responsive sources.
  static FxImage image(
    String src, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    double radius = 0,
    String? semanticLabel,
    Widget? loading,
    Widget? error,
    Widget? placeholder,
  }) {
    return FxImage(
      src,
      style: FxStyle(
        width: width,
        height: height,
        fit: fit,
        borderRadius: radius > 0 ? BorderRadius.circular(radius) : null,
        loading: loading,
        error: error,
        placeholder: placeholder,
      ),
    );
  }

  /// Responsive image that chooses source based on current breakpoint.
  static FxImage responsiveImage({
    required String xs,
    String? sm,
    String? md,
    String? lg,
    String? xl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    return FxImage(
      xs,
      responsive: FxResponsiveStyle(
        xs: FxStyle(width: width, height: height, fit: fit, imageSrc: xs),
        sm: sm != null
            ? FxStyle(width: width, height: height, fit: fit, imageSrc: sm)
            : null,
        md: md != null
            ? FxStyle(width: width, height: height, fit: fit, imageSrc: md)
            : null,
        lg: lg != null
            ? FxStyle(width: width, height: height, fit: fit, imageSrc: lg)
            : null,
        xl: xl != null
            ? FxStyle(width: width, height: height, fit: fit, imageSrc: xl)
            : null,
      ),
    );
  }

  /// Hero primitive.
  static Widget hero({required String tag, required Widget child}) {
    return Hero(tag: tag, child: child);
  }

  /// Stack primitive.
  static Widget stack({
    required List<Widget> children,
    AlignmentGeometry alignment = AlignmentDirectional.topStart,
    StackFit fit = StackFit.loose,
    FxStyle style = FxStyle.none,
  }) {
    return FxStack(
      alignment: alignment,
      fit: fit,
      style: style,
      children: children,
    );
  }

  /// SafeArea primitive.
  static Widget safe(
    Widget child, {
    bool left = true,
    bool top = true,
    bool right = true,
    bool bottom = true,
    EdgeInsets minimum = EdgeInsets.zero,
    bool maintainBottomViewPadding = false,
  }) {
    return SafeArea(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      minimum: minimum,
      maintainBottomViewPadding: maintainBottomViewPadding,
      child: child,
    );
  }

  /// SafeArea primitive.
  static Widget safeArea({
    required Widget child,
    bool left = true,
    bool top = true,
    bool right = true,
    bool bottom = true,
    EdgeInsets minimum = EdgeInsets.zero,
    bool maintainBottomViewPadding = false,
  }) {
    return SafeArea(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      minimum: minimum,
      maintainBottomViewPadding: maintainBottomViewPadding,
      child: child,
    );
  }

  /// Spacer primitive.
  static Widget spacer({int flex = 1}) {
    return Spacer(flex: flex);
  }

  /// Expanded primitive.
  static Widget expanded(Widget child, {int flex = 1}) {
    return Expanded(flex: flex, child: child);
  }

  /// Flexible primitive.
  static Widget flexible(Widget child, {int flex = 1, FlexFit fit = FlexFit.loose}) {
    return Flexible(flex: flex, fit: fit, child: child);
  }

  /// Alignment primitive.
  static Widget align(Widget child, AlignmentGeometry alignment) {
    return Align(alignment: alignment, child: child);
  }

  /// Divider primitive.
  static Widget divider({double thickness = 1.0, Color? color, double? indent, double? endIndent}) {
    return Divider(
      thickness: thickness,
      color: color,
      indent: indent,
      endIndent: endIndent,
    );
  }

  /// Data Visualization primitive.
  /// Usage: `Fx.chart(data: mySignal, type: FxChartType.line)`
  static FxChart chart({
    required dynamic data,
    FxChartType type = FxChartType.bar,
    double height = 200,
    bool showLabels = true,
    bool showValues = true,
    FxStyle style = FxStyle.none,
  }) {
    return FxChart(
      data: data,
      type: type,
      height: height,
      showLabels: showLabels,
      showValues: showValues,
      style: style,
    );
  }

  // --- Buttons (Phase 5) ---

  /// A raw, unstyled button that provides interaction states (hover, pressed) 
  /// and cursor: pointer without any prescribed design.
  static FxButton btn({Widget? child, String? label, VoidCallback? onTap}) {
    return FxButton(
      label: label,
      onTap: onTap,
      variant: FxButtonVariant.none,
      size: FxButtonSize.none,
      child: child,
    );
  }

  static FxButton button(String label, {VoidCallback? onTap}) =>
      primaryButton(label, onTap: onTap);

  static FxButton primaryButton(String label, {VoidCallback? onTap}) {
    return FxButton(
      label: label,
      onTap: onTap,
      variant: FxButtonVariant.primary,
    );
  }

  static FxButton secondaryButton(String label, {VoidCallback? onTap}) {
    return FxButton(
      label: label,
      onTap: onTap,
      variant: FxButtonVariant.secondary,
    );
  }

  static FxButton textButton(String label, {VoidCallback? onTap}) {
    return FxButton(label: label, onTap: onTap, variant: FxButtonVariant.text);
  }

  static FxButton outlineButton(String label, {VoidCallback? onTap}) {
    return FxButton(label: label, onTap: onTap, variant: FxButtonVariant.outline);
  }

  static FxButton ghostButton(String label, {VoidCallback? onTap}) {
    return FxButton(label: label, onTap: onTap, variant: FxButtonVariant.ghost);
  }

  static FxButton dangerButton(String label, {VoidCallback? onTap}) {
    return FxButton(label: label, onTap: onTap, variant: FxButtonVariant.danger);
  }

  static FxButton successButton(String label, {VoidCallback? onTap}) {
    return FxButton(label: label, onTap: onTap, variant: FxButtonVariant.success);
  }

  // --- Overlays & Feedback ---

  /// Image primitive for assets, network, or local files.
  /// Use `file://` prefix for local files.
  static FxImage img(String src, {FxStyle style = FxStyle.none, VoidCallback? onTap}) {
    return FxImage(src, style: style, onTap: onTap);
  }

  /// Image primitive for memory bytes.
  static FxImage memoryImage(Uint8List bytes, {FxStyle style = FxStyle.none, VoidCallback? onTap}) {
    return FxImage.memory(bytes, style: style, onTap: onTap);
  }

  /// Shows a modal dialog.
  /// Automatically constrains width on desktop/tablet for a better UX.
  static Future<T?> modal<T>(
    BuildContext context, {
    required Widget child,
    bool barrierDismissible = true,
    Color? barrierColor,
    double? maxWidth, // Responsive constraint
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth ?? 500, // Default to 500px max on wide screens
          ),
          child: child,
        ),
      ),
    );
  }

  /// Aliases for modal
  // static Future<T?> dialog<T>(BuildContext context, {required Widget child}) => modal(context, child: child);

  /// Shows a bottom sheet.
  static Future<T?> bottomSheet<T>(
    BuildContext context, {
    required Widget child,
    bool isScrollControlled = true,
    Color backgroundColor = Colors.white,
    double radius = 16,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
        ),
        child: child,
      ),
    );
  }

  /// Shows a snackbar / toast.
  /// Automatically becomes floating and width-constrained on larger screens.
  static void snack(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    double? width, // Explicit width
    EdgeInsetsGeometry? margin, // Explicit margin
  }) {
    // Responsive Default:
    // If Desktop/Tablet (>600px): strictly limit width to 400px (floating).
    // If Mobile: use full width (standard).

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth > 600;

    // Auto-calculate width for desktop if not provided
    final effectiveWidth = width ?? (isDesktop ? 400.0 : null);

    // If we have a width, we MUST use floating behavior
    final behavior = (effectiveWidth != null || margin != null)
        ? SnackBarBehavior.floating
        : SnackBarBehavior.fixed;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor ?? Colors.white),
        ),
        backgroundColor: backgroundColor ?? const Color(0xFF1E293B),
        duration: duration,
        action: action,
        behavior: behavior,
        width: effectiveWidth,
        margin: effectiveWidth == null
            ? margin
            : null, // Apply margin only if no width
      ),
    );
  }

  /// Alias for snack
  // static void toast(BuildContext context, String message) => snack(context, message);

  /// A common semantic primitive: Card.
  static Widget card({
    required Widget child,
    FxStyle style = FxStyle.none,
  }) {
    return Box(
      style: FxStyle(
        backgroundColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
        shadows: FxTokens.shadow.md,
        padding: const EdgeInsets.all(16),
      ).merge(style),
      child: child,
    );
  }

  /// A common semantic primitive: List Tile.
  static Widget listTile({
    Widget? leading,
    required Widget title,
    Widget? subtitle,
    Widget? trailing,
    FxStyle style = FxStyle.none,
    VoidCallback? onTap,
  }) {
    return Fx.row(
      alignItems: CrossAxisAlignment.center,
      style: const FxStyle(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ).merge(style),
      children: [
        if (leading != null) leading.margin(0, md: 0, lg: 0), // Just to use padding/margin if needed, let's use spacing manually
        if (leading != null) Fx.gap(12),
        Fx.expand(child: Fx.col(
          alignItems: CrossAxisAlignment.start,
          gap: 4,
          children: [
            title,
            if (subtitle != null) subtitle,
          ],
        )),
        if (trailing != null) Fx.gap(12),
        if (trailing != null) trailing,
      ],
    ).onTapSafe(() { if(onTap != null) onTap(); });
  }

  /// App Bar wrapper.
  static PreferredSizeWidget appBar({
    String? title,
    Widget? titleWidget,
    List<Widget>? actions,
    Widget? leading,
    Color? backgroundColor,
    Color? foregroundColor,
    double? elevation,
    bool centerTitle = true,
  }) {
    return AppBar(
      title:
          titleWidget ??
          (title != null
              ? Text(title, style: const TextStyle(fontWeight: FontWeight.w600))
              : null),
      actions: actions,
      leading: leading,
      backgroundColor: backgroundColor ?? Colors.white,
      foregroundColor: foregroundColor ?? Colors.black,
      elevation: elevation ?? 0,
      centerTitle: centerTitle,
      scrolledUnderElevation: 0,
    );
  }

  /// Custom Bottom Navigation Bar.
  /// Uses FxBottomBar for a unique pill-style animated design.
  static Widget bottomNav({
    required int currentIndex,
    required ValueChanged<int> onTap,
    required List<BottomNavigationBarItem> items,
    Color? selectedItemColor,
    Color? unselectedItemColor,
    Color? backgroundColor,
    double? elevation,
    FxStyle? containerStyle, // New parameter for custom styling
  }) {
    // Map standard items to custom items
    final customItems = items.map((item) {
      if (item.icon is Icon) {
        return FxBottomBarItem(
          icon: (item.icon as Icon).icon,
          activeIcon: (item.activeIcon is Icon)
              ? (item.activeIcon as Icon).icon
              : null,
          label: item.label ?? '',
        );
      }
      return FxBottomBarItem(
        iconWidget: item.icon,
        activeIconWidget: item.activeIcon,
        label: item.label ?? '',
      );
    }).toList();

    return FxBottomBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: customItems,
      activeColor: selectedItemColor,
      baseColor: unselectedItemColor,
      containerStyle: containerStyle,
    );
  }

  /// Custom Sidebar / Drawer wrapper.
  static Widget drawer({
    required Widget child,
    double width = 304,
    Color? backgroundColor,
  }) {
    return Drawer(
      width: width,
      backgroundColor: backgroundColor ?? Colors.white,
      child: child,
    );
  }

  /// Custom Dropdown.
  static Widget dropdown<T>({
    T? value,
    Flux<T>? signal,
    required List<T> items,
    ValueChanged<T?>? onChanged,
    String Function(T)? itemLabel,
    Widget Function(T)? itemBuilder,
    String? placeholder,
    FxStyle style = FxStyle.none,
    FxStyle dropdownStyle = FxStyle.none,
    Color? iconColor,
    String? className,
    FxResponsiveStyle? responsive,
  }) {
    return FxDropdown<T>(
      value: value,
      signal: signal,
      items: items,
      onChanged: onChanged,
      itemLabel: itemLabel,
      itemBuilder: itemBuilder,
      placeholder: placeholder,
      style: style,
      dropdownStyle: dropdownStyle,
      iconColor: iconColor,
      className: className,
      responsive: responsive,
    );
  }

  // --- Inputs (Phase 5) ---

  static Widget input({
    required Flux<String> signal,
    String? placeholder,
    String? label,
    IconData? icon,
    bool obscureText = false,
    List<Validator<String>>? validators,
    TextInputType? keyboardType,
    int? maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
    FocusNode? focusNode,
    VoidCallback? onSubmitted,
    FxStyle style = FxStyle.none,
    TextStyle? textStyle,
    InputDecoration? decoration,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
    bool passwordToggle = false,
  }) {
    return FxTextField(
      signal: signal,
      placeholder: placeholder,
      label: label,
      icon: icon,
      suffixIcon: suffixIcon,
      onSuffixTap: onSuffixTap,
      passwordToggle: passwordToggle,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
      validators: validators,
      style: style,
      textStyle: textStyle,
      decoration: decoration,
    );
  }

  /// Form container for grouping inputs.
  /// Automatically handles validation and keyboard dismissal.
  static Widget form({
    Widget? child,
    List<Widget>? children,
    FluxForm? form,
    VoidCallback? onSubmit,
    bool autoValidate = true,
    bool closeKeyboardOnTap = true,
  }) {
    return FxForm(
      form: form,
      onSubmit: onSubmit,
      autoValidate: autoValidate,
      closeKeyboardOnTap: closeKeyboardOnTap,
      child: child,
      children: children,
    );
  }

  /// Reactive API fetcher.

  /// Reactive API fetcher.
  /// Returns an async signal with built-in state management.
  static AsyncFlux<T> fetch<T>(
    Future<T> Function() task, {
    T? initialValue,
    int retries = 0,
    Duration retryDelay = const Duration(seconds: 1),
    Duration? debounce,
    Duration? timeout,
    void Function(Object, StackTrace?)? onError,
    void Function(T)? onSuccess,
  }) {
    return asyncFlux(
      task,
      initialValue: initialValue,
      config: AsyncConfig(
        retries: retries,
        retryDelay: retryDelay,
        debounce: debounce,
        timeout: timeout,
        onError: onError,
        onSuccess: onSuccess != null ? (data) => onSuccess(data as T) : null,
      ),
    );
  }

  static Widget password({
    required Flux<String> signal,
    String? placeholder = 'Password',
    String? label,
    IconData? icon = Icons.lock_outline,
    FxStyle style = FxStyle.none,
  }) {
    return input(
      signal: signal,
      placeholder: placeholder,
      label: label,
      icon: icon,
      style: style,
      obscureText: true,
      passwordToggle: true,
    );
  }

  static Widget checkbox({required Flux<bool> signal, String? label}) {
    final cb = FxCheckbox(signal: signal);
    if (label != null) {
      return row(children: [cb, text(label).textSm()], gap: 8);
    }
    return cb;
  }

  static Widget switcher({required Flux<bool> signal}) {
    return Fx(
      () => Switch(value: signal.value, onChanged: (v) => signal.value = v),
    );
  }

  // --- Avatars & Badges ---

  static Widget avatar({
    String? image,
    String? fallback,
    FxAvatarSize size = FxAvatarSize.md,
    FxAvatarShape shape = FxAvatarShape.circle,
    VoidCallback? onTap,
    FxStyle style = FxStyle.none,
    String? className,
    FxResponsiveStyle? responsive,
  }) {
    return FxAvatar(
      image: image,
      fallback: fallback,
      size: size,
      shape: shape,
      onTap: onTap,
      style: style,
      className: className,
      responsive: responsive,
    );
  }

  static Widget badge({
    required Widget child,
    String? label,
    Color? color,
    Offset offset = const Offset(-4, -4),
    FxStyle style = FxStyle.none,
    String? className,
    FxResponsiveStyle? responsive,
  }) {
    return FxBadge(
      label: label,
      color: color,
      offset: offset,
      style: style,
      className: className,
      responsive: responsive,
      child: child,
    );
  }

  // --- Utilities ---

  /// Staggers a list of widgets with a delay.
  /// Ideal for entrance animations.
  static List<Widget> stagger(
    List<Widget> children, {
    double interval = 0.05,
    Offset slide = const Offset(0, 20),
    double fade = 0.0,
  }) {
    return List.generate(children.length, (index) {
      return children[index].animate(
        delay: index * interval,
        slide: slide,
        fade: fade,
      );
    });
  }

  /// Async UI Builder
  static Widget async<T>(
    AsyncFlux<T> signal, {
    required Widget Function() loading,
    required Widget Function(Object error) error,
    required Widget Function(T data) data,
  }) {
    return signal.on(loading: loading, data: data, error: error);
  }

  // Navigation
  static Future<T?> to<T>(String route, {Object? arguments, String? scope}) =>
      FluxyRouter.to<T>(route, arguments: arguments, scope: scope);
  static Future<T?> go<T>(String route, {Object? arguments, String? scope}) =>
      FluxyRouter.to<T>(route, arguments: arguments, scope: scope);
  static void back<T>([T? result, String? scope]) =>
      FluxyRouter.back<T>(result, scope);

  /// Executes an async operation with automatic retry logic.
  static Future<T> retry<T>(
    Future<T> Function() operation, {
    int? retries,
    Duration? delay,
    String? label,
  }) => FluxyDataGuard.retry(operation, retries: retries, delay: delay, label: label);

  /// Stale-While-Revalidate pattern for data fetching.
  static Future<void> swr<T>({
    required Future<T?> local,
    required Future<T> remote,
    required void Function(T data) onData,
    void Function(dynamic error)? onError,
  }) => FluxyDataGuard.swr(local: local, remote: remote, onData: onData, onError: onError);

  /// Alias for Vertical Layout (Column).
  static Widget column({
    required List<Widget> children,
    MainAxisAlignment justify = MainAxisAlignment.start,
    CrossAxisAlignment items = CrossAxisAlignment.center,
    double gap = 0,
    FxStyle style = FxStyle.none,
    MainAxisSize size = MainAxisSize.max,
  }) => col(
    children: children,
    justify: justify,
    alignItems: items,
    gap: gap,
    style: style,
    size: size,
  );
}

/// Helper class for Fx.grid factory pattern.
class _FxGridHelper {
  const _FxGridHelper();

  /// Standard grid with fixed column count.
  /// [columns] - Number of columns (default 2).
  /// [gap] - Spacing between items.
  /// [childAspectRatio] - Aspect ratio of grid items (width/height).
  FxGrid call({
    required List<Widget> children,
    int? columns = 2,
    double gap = 0,
    FxStyle style = FxStyle.none,
    double childAspectRatio = 1.0,
  }) => FxGrid(
    columns: columns,
    gap: gap,
    style: style,
    childAspectRatio: childAspectRatio,
    children: children,
  );

  /// Auto-responsive grid that fills as many columns as possible.
  /// [minItemWidth] - Minimum width of each item.
  FxGrid auto({
    required List<Widget> children,
    required double minItemWidth,
    double gap = 0,
    FxStyle style = FxStyle.none,
    double childAspectRatio = 1.0,
  }) => FxGrid.auto(
    minItemWidth: minItemWidth,
    gap: gap,
    style: style,
    childAspectRatio: childAspectRatio,
    children: children,
  );

  /// Breakpoint-based grid.
  /// [xs], [sm], [md], [lg], [xl] - Column counts for each breakpoint.
  FxGrid responsive({
    required List<Widget> children,
    int? xs,
    int? sm,
    int? md,
    int? lg,
    int? xl,
    double gap = 0,
    FxStyle style = FxStyle.none,
    double childAspectRatio = 1.0,
    bool shrinkWrap = true,
    ScrollPhysics? physics,
  }) => FxGrid.responsive(
    xs: xs,
    sm: sm,
    md: md,
    lg: lg,
    xl: xl,
    gap: gap,
    style: style,
    childAspectRatio: childAspectRatio,
    shrinkWrap: shrinkWrap,
    physics: physics,
    children: children,
  );

  FxGrid cards({
    required List<Widget> children,
    double gap = 16,
    double childAspectRatio = 0.8,
  }) => FxGrid.cards(
    gap: gap,
    childAspectRatio: childAspectRatio,
    children: children,
  );

  FxGrid gallery({
    required List<Widget> children,
    double gap = 4,
    int columns = 3,
  }) => FxGrid.gallery(
    gap: gap,
    columns: columns,
    children: children,
  );

  FxGrid feed({
    required List<Widget> children,
    double gap = 16,
  }) => FxGrid(
    columns: 1,
    gap: gap,
    children: children,
  );

  /// Specialized grid for dashboards.
  FxGrid dashboard({
    required List<Widget> children,
    double gap = 20,
    double childAspectRatio = 1.0,
  }) => FxGrid.responsive(
    xs: 1,
    sm: 2,
    md: 3,
    lg: 4,
    gap: gap,
    childAspectRatio: childAspectRatio,
    children: children,
  );
}

class _FxState extends State<Fx> with ReactiveSubscriberMixin {
  bool _isThrottledWarning = false;

  @override
  String? get debugName => widget.label ?? 'FxBuilder';

  @override
  void notify() {
    if (!mounted) return;

    final now = DateTime.now();
    if (lastRebuildTime != null) {
      final diff = now.difference(lastRebuildTime!);
      if (diff.inSeconds < 1) {
        rebuildCount++;
        if (rebuildCount > 10 && !_isThrottledWarning) {
          _isThrottledWarning = true;
          // Flash warning in console too
          debugPrint("Fluxy [Profiler] Warning: '$debugName' is rebuilding too frequently (>10/s)!");
        }
      } else {
        rebuildCount = 0;
        _isThrottledWarning = false;
      }
    }
    lastRebuildTime = now;
    
    setState(() {});
  }

  @override
  void dispose() {
    clearDependencies();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FluxyStateGuard.recordRebuild(this);
    FluxyObservability.recordRebuild(debugName ?? 'Anonymous');
    FluxyReactiveContext.push(this);
    final prevContext = FluxyReactiveContext.currentContext;
    FluxyReactiveContext.currentContext = context;
    try {
      final child = widget.builder();
      
      // VITAL FIX: If the builder returns a Sliver, we cannot wrap it in 
      // FluxyRenderGuard because it currently uses a RenderProxyBox.
      // RenderBox parents cannot host RenderSliver children.
      bool isSliver = child is SliverToBoxAdapter || 
                     child is SliverList || 
                     child is SliverGrid || 
                     child is SliverPadding ||
                     child is SliverAppBar ||
                     child is SliverPersistentHeader ||
                     child is SliverFillRemaining ||
                     child is SliverFixedExtentList ||
                     child is SliverPrototypeExtentList;

      Widget content = isSliver ? child : FluxyRenderGuard(child: child);
      
      // Flash Warning Badge if rebuilding too fast (Debug only)
      if (!kReleaseMode && _isThrottledWarning) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.red, width: 2)),
              child: content,
            ),
            Positioned(
              top: -10, right: -10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                child: const Text('SLOW', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      }
      
      return content;
    } finally {
      FluxyReactiveContext.currentContext = prevContext;
      FluxyReactiveContext.pop();
    }
  }
}

// --- Helper Classes ---

class _FxToastHelper {
  const _FxToastHelper();

  void call(
    String message, {
    FxToastType type = FxToastType.info,
    Duration duration = const Duration(seconds: 3),
    FxToastPosition position = FxToastPosition.bottom,
  }) {
    FxOverlay.showToast(
      message,
      type: type,
      duration: duration,
      position: position,
    );
  }

  void success(String message) => call(message, type: FxToastType.success);
  void error(String message) => call(message, type: FxToastType.error);
  void info(String message) => call(message, type: FxToastType.info);
  void warning(String message) => call(message, type: FxToastType.warning);
}

class _FxLoaderHelper {
  const _FxLoaderHelper();

  void show({String? label, bool blocking = true}) =>
      FxOverlay.showLoader(label: label, blocking: blocking);
  void hide() => FxOverlay.hideLoader();

  /// Returns a shimmer widget for skeleton screens.
  Widget shimmer({double? width, double? height, double? radius}) =>
      FxShimmer(width: width, height: height, borderRadius: radius != null ? BorderRadius.circular(radius) : null);
}

class _FxDialogHelper {
  const _FxDialogHelper();

  // Basic show proxy
  Future<T?> show<T>({required Widget child, bool barrierDismissible = true}) {
    final context = FluxyRouter.navigatorKey.currentContext;
    if (context == null) return Future.value(null);
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => child,
    );
  }

  Future<void> alert({
    required String title,
    required String content,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    return show(
      child: AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Fx.back();
              onPressed?.call();
            },
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  Future<bool> confirm({
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool autoBack = true,
  }) async {
    final result = await show<bool>(
      child: AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Fx.back(false),
            child: Text(cancelText, style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(onPressed: () => Fx.back(true), child: Text(confirmText)),
        ],
      ),
    );
    return result ?? false;
  }
}
class _FxCondHelper {
  const _FxCondHelper();

  /// Simple boolean condition builder.
  Widget call(Flux<bool> signal, Widget trueChild,
          [Widget falseChild = const SizedBox.shrink()]) =>
      Fx(() => signal.value ? trueChild : falseChild);

  /// Multiple conditions. The first one that is true wins.
  Widget multiple(Map<dynamic, Widget> cases,
      {Widget fallback = const SizedBox.shrink()}) {
    return Fx(() {
      for (var entry in cases.entries) {
        final cond = entry.key;
        if (cond is Flux<bool> && cond.value) return entry.value;
        if (cond is Flux<dynamic> && cond.value != null && cond.value != false) {
          return entry.value;
        }
        if (cond is bool && cond) return entry.value;
      }
      return fallback;
    });
  }

  /// Switches based on a signal's value.
  Widget switcher<T>(Flux<T> signal, Map<T, Widget> cases,
      {Widget fallback = const SizedBox.shrink()}) {
    return Fx(() => cases[signal.value] ?? fallback);
  }
}

/// Platform services helper for accessing modular packages.
class _FxPlatformHelper {
  const _FxPlatformHelper();
  
  /// Access to authentication services.
  dynamic get auth => _getSafe('auth', 'fluxy_auth');

  /// Access to camera functionality.
  dynamic get camera => _getSafe('camera', 'fluxy_camera'); 
  
  /// Access to notification services.
  dynamic get notifications => _getSafe('notifications', 'fluxy_notifications');

  /// Access to storage services.
  dynamic get storage => _getSafe('storage', 'fluxy_storage');

  /// Access to permission management.
  dynamic get permissions => _getSafe('permissions', 'fluxy_permissions');

  /// Access to analytics services.
  dynamic get analytics => _getSafe('analytics', 'fluxy_analytics');

  /// Access to biometric authentication.
  dynamic get biometric => _getSafe('biometric', 'fluxy_biometric');

  /// Access to connectivity services.
  dynamic get connectivity => _getSafe('connectivity', 'fluxy_connectivity');

  /// Access to platform utilities.
  dynamic get platform => _getSafe('platform', 'fluxy_platform');

  /// Access to OTA services.
  dynamic get ota => _getSafe('ota', 'fluxy_ota');

  /// Access to sensory haptic feedback.
  dynamic get haptic => _getSafe('haptic', 'fluxy_haptics');

  /// Access to industrial logging and auditing.
  dynamic get logger => _getSafe('logger', 'fluxy_logger');

  /// Access to device environment awareness.
  dynamic get device => _getSafe('device', 'fluxy_device');

  /// Safely retrieves a plugin by name with helpful diagnostics if missing.
  dynamic _getSafe(String shortName, String pluginName) {
    final plugin = FluxyPluginEngine.findByName(pluginName);
    if (plugin == null && kDebugMode) {
      debugPrint(
        '┌──────────────────────────────────────────────────────────┐',
      );
      debugPrint(
        '│ [Sys] [Platform] MODULE MISSING: $shortName              │',
      );
      debugPrint(
        '├──────────────────────────────────────────────────────────┤',
      );
      debugPrint(
        '│ You are trying to use Fx.platform.$shortName, but the      │',
      );
      debugPrint(
        '│ module is not registered in fluxy_registry.dart.         │',
      );
      debugPrint(
        '│                                                          │',
      );
      debugPrint(
        '│ FIX: Run "fluxy doctor" to re-sync your registry.        │',
      );
      debugPrint(
        '└──────────────────────────────────────────────────────────┘',
      );
    }
    return plugin;
  }
}
