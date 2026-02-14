import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Input Formatters
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

// Re-export specific styles/tokens for easy access if needed
export '../styles/style.dart';
export 'modifiers.dart';
import '../styles/fx_theme.dart';
import '../widgets/list_box.dart';
import '../widgets/table.dart';
import '../widgets/fx_form.dart';
import '../feedback/overlays.dart';
import '../reactive/forms.dart';
import '../layout/fx_grid.dart';
import '../layout/fx_row.dart';
import '../layout/fx_col.dart';
import '../layout/fx_stack.dart';
import '../layout/fx_layout.dart';

/// The hyper-minimal Fx API for Fluxy.
/// Designed for maximum builder velocity and zero boilerplate reactivity.
class Fx extends StatefulWidget {
  final Widget Function() builder;

  const Fx(this.builder, {super.key});

  @override
  State<Fx> createState() => _FxState();

  // --- Design Tokens ---
  // Expose global design scale: Fx.space.sm
  static const space = FxTokens.space;
  static const radius = FxTokens.radius;
  static const font = FxTokens.font;
  static const shadow = FxTokens.shadow;

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

  // --- Theme Management ---

  /// Toggles between light and dark mode.
  static void toggleTheme() => FxTheme.toggle();

  /// Checks if the current theme is dark.
  static bool get isDarkMode => FxTheme.isDarkMode;

  /// Sets the theme mode.
  static void setThemeMode(ThemeMode mode) => FxTheme.setMode(mode);

  // --- Responsive Layouts ---

  /// Advanced Layout Switcher. Automatically chooses layout based on screen size.
  static Widget layout({
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) => FxLayout(mobile: mobile, tablet: tablet, desktop: desktop);

  /// Advanced Grid Layout System.
  static const grid = _FxGridHelper();

  /// Horizontal Layout (Row).
  static Widget row({
    required List<Widget> children,
    MainAxisAlignment justify = MainAxisAlignment.start,
    CrossAxisAlignment items = CrossAxisAlignment.center,
    double gap = 0,
    FxStyle style = FxStyle.none,
    MainAxisSize size = MainAxisSize.max,
  }) => FxRow(
    children: children,
    justify: justify,
    items: items,
    gap: gap,
    style: style,
    size: size,
  );

  /// Vertical Layout (Column).
  static Widget col({
    required List<Widget> children,
    MainAxisAlignment justify = MainAxisAlignment.start,
    CrossAxisAlignment items = CrossAxisAlignment.center,
    double gap = 0,
    FxStyle style = FxStyle.none,
    MainAxisSize size = MainAxisSize.max,
  }) => FxCol(
    children: children,
    justify: justify,
    items: items,
    gap: gap,
    style: style,
    size: size,
  );

  // --- Core Primitives ---

  /// A reactive text element.
  /// Supports: Fx.text("Hello").font.lg.bold
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

  /// A reactive container.
  /// Supports: Fx.box(child: ...).pad.md
  static Widget box({
    FxStyle style = FxStyle.none,
    String? className,
    FxResponsiveStyle? responsive,
    Widget child = const SizedBox.shrink(),
    List<Widget> children = const [],
    VoidCallback? onTap,
  }) {
    return Box(
      style: style,
      className: className,
      responsive: responsive,
      child: child,
      children: children,
      onTap: onTap,
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

  /// A conditional builder.
  /// Rebuilds when the signal changes.
  static Widget cond(Signal<bool> signal, Widget trueChild, Widget falseChild) {
    return Fx(() => signal.value ? trueChild : falseChild);
  }

  /// Stack layout.
  static Widget stack({
    required List<Widget> children,
    AlignmentGeometry alignment = AlignmentDirectional.topStart,
    FxStyle style = FxStyle.none,
    StackFit fit = StackFit.loose,
  }) => FxStack(
    children: children,
    alignment: alignment,
    style: style,
    fit: fit,
  );

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

  /// Vertical list layout.
  /// Vertical list layout.
  static Widget list({
    List<Widget>? children,
    int? itemCount,
    IndexedWidgetBuilder? itemBuilder,
    FxStyle style = FxStyle.none,
    String? className,
    FxResponsiveStyle? responsive,
    double? gap,
    Axis direction = Axis.vertical,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
  }) {
    // If builder pattern is used
    if (itemCount != null && itemBuilder != null) {
      // Create a builder-based ListBox (since ListBox wrapping ListView.separated needs explicit children)
      // We can generate children if not too many, or we need to update ListBox.
      // Since Fluxy aims for "zero boilerplate", let's use ListView.separated directly here
      // wrapped in a container that handles FxStyle.
      // BUT ListBox already handles styling logic.
      // It's cleaner to update ListBox to support builder.
      // For now, let's create a ListBox.builder analog here internally or update ListBox.

      // Since modifying ListBox fully is cleaner, let's assume ListBox is updated.
      // Checking ListBox widget again... It takes required children.
      // I will update ListBox to accept optional children and builder.
      // For this replace_file_content call, I will pass builder params to ListBox
      // assuming I will update ListBox in the next step.
      return ListBox(
        children: children ?? [],
        itemCount: itemCount,
        itemBuilder: itemBuilder,
        style: style.merge(FxStyle(gap: gap)),
        className: className,
        responsive: responsive,
        scrollDirection: direction,
        physics: physics,
        shrinkWrap: shrinkWrap,
      );
    }

    return ListBox(
      children: children ?? [],
      style: style.merge(FxStyle(gap: gap)),
      className: className,
      responsive: responsive,
      scrollDirection: direction,
      physics: physics,
      shrinkWrap: shrinkWrap,
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

  /// Center layout.
  static Widget center({required Widget child}) {
    return Center(child: child);
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
  }) {
    return Box(
      style: style,
      child: SingleChildScrollView(scrollDirection: direction, child: child),
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

  /// Image primitive.
  static Widget image(
    String src, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    double radius = 0,
    String? semanticLabel,
  }) {
    final img = Image.network(
      src,
      width: width,
      height: height,
      fit: fit,
      semanticLabel: semanticLabel,
      errorBuilder: (c, o, s) => Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image, color: Colors.grey),
      ),
    );

    if (radius > 0) {
      return ClipRRect(borderRadius: BorderRadius.circular(radius), child: img);
    }
    return img;
  }

  /// Hero primitive.
  static Widget hero({required String tag, required Widget child}) {
    return Hero(tag: tag, child: child);
  }

  // --- Buttons (Phase 5) ---

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

  // --- Overlays & Feedback ---

  /// Shows a modal dialog.
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

    final screenWidth = MediaQuery.of(context).size.width;
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

  // --- Complex Structure Widgets ---

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
    Signal<T>? signal,
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
    required Signal<String> signal,
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
  }) {
    return FxTextField(
      signal: signal,
      placeholder: placeholder,
      label: label,
      icon: icon,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
      validators: validators,
    );
  }

  /// Form container for grouping inputs.
  /// Automatically handles validation and keyboard dismissal.
  static Widget form({
    required Widget child,
    FluxForm? form,
    VoidCallback? onSubmit,
    bool autoValidate = true,
    bool closeKeyboardOnTap = true,
  }) {
    return FxForm(
      child: child,
      form: form,
      onSubmit: onSubmit,
      autoValidate: autoValidate,
      closeKeyboardOnTap: closeKeyboardOnTap,
    );
  }

  /// Reactive API fetcher.
  /// Returns an async signal with built-in state management.
  static AsyncSignal<T> fetch<T>(
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
    required Signal<String> signal,
    String? placeholder = "Password",
  }) {
    return input(signal: signal, placeholder: placeholder, obscureText: true);
  }

  static Widget checkbox({required Signal<bool> signal, String? label}) {
    final cb = FxCheckbox(signal: signal);
    if (label != null) {
      return row(children: [cb, text(label).textSm()], gap: 8);
    }
    return cb;
  }

  static Widget switcher({required Signal<bool> signal}) {
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
      child: child,
      label: label,
      color: color,
      offset: offset,
      style: style,
      className: className,
      responsive: responsive,
    );
  }

  // --- Utilities ---

  /// Staggers a list of widgets with a delay.
  static List<Widget> stagger(
    List<Widget> children, {
    double interval = 0.05,
    double initialDelay = 0,
  }) {
    return children.asMap().entries.map((entry) {
      final child = entry.value;
      final index = entry.key;

      if (child is FxMotion) {
        final m = child;
        return FxMotion(
          duration: m.duration,
          curve: m.curve,
          spring: m.spring,
          delay: (m.delay ?? 0) + initialDelay + (index * interval),
          autoStart: m.autoStart,
          fade: m.fade,
          slide: m.slide,
          scale: m.scale,
          rotate: m.rotate,
          child: m.child,
        );
      }
      return child;
    }).toList();
  }

  /// Async UI Builder
  static Widget async<T>(
    AsyncSignal<T> signal, {
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
    items: items,
    gap: gap,
    style: style,
    size: size,
  );
}

/// Helper class for Fx.grid factory pattern.
class _FxGridHelper {
  const _FxGridHelper();

  FxGrid call({
    required List<Widget> children,
    int? columns = 2,
    double gap = 0,
    FxStyle style = FxStyle.none,
    double childAspectRatio = 1.0,
  }) => FxGrid(
    children: children,
    columns: columns,
    gap: gap,
    style: style,
    childAspectRatio: childAspectRatio,
  );

  FxGrid auto({
    required List<Widget> children,
    required double minItemWidth,
    double gap = 0,
    FxStyle style = FxStyle.none,
    double childAspectRatio = 1.0,
  }) => FxGrid.auto(
    children: children,
    minItemWidth: minItemWidth,
    gap: gap,
    style: style,
    childAspectRatio: childAspectRatio,
  );

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
  }) => FxGrid.responsive(
    children: children,
    xs: xs,
    sm: sm,
    md: md,
    lg: lg,
    xl: xl,
    gap: gap,
    style: style,
    childAspectRatio: childAspectRatio,
  );

  FxGrid cards({
    required List<Widget> children,
    double gap = 16,
    double childAspectRatio = 0.8,
  }) => FxGrid.cards(
    children: children,
    gap: gap,
    childAspectRatio: childAspectRatio,
  );

  FxGrid gallery({
    required List<Widget> children,
    double gap = 4,
    int columns = 3,
  }) => FxGrid.gallery(
    children: children,
    gap: gap,
    columns: columns,
  );

  FxGrid feed({
    required List<Widget> children,
    double gap = 16,
  }) => FxGrid(
    children: children,
    columns: 1,
    gap: gap,
  );

  FxGrid dashboard({
    required List<Widget> children,
    double gap = 20,
  }) => FxGrid.responsive(
    children: children,
    xs: 1,
    sm: 2,
    md: 3,
    lg: 4,
    gap: gap,
  );
}

class _FxState extends State<Fx> with ReactiveSubscriberMixin {
  @override
  void notify() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    clearDependencies();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FluxyReactiveContext.push(this);
    try {
      return widget.builder();
    } finally {
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
    String buttonText = "OK",
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
    String confirmText = "Confirm",
    String cancelText = "Cancel",
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
