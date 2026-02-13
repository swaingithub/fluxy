
import 'package:flutter/material.dart';
import '../styles/style.dart';
import '../styles/tokens.dart'; // Tokens
import 'modifiers.dart'; // Extension
import '../widgets/box.dart';
import '../widgets/text_box.dart';
import '../widgets/flex_box.dart';
import '../widgets/stack_box.dart';
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
import '../widgets/grid_box.dart';
import '../widgets/table.dart';
import '../reactive/forms.dart';

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

  // --- Theme Management ---
  
  /// Toggles between light and dark mode.
  static void toggleTheme() => FxTheme.toggle();
  
  /// Checks if the current theme is dark.
  static bool get isDarkMode => FxTheme.isDarkMode;

  /// Sets the theme mode.
  static void setThemeMode(ThemeMode mode) => FxTheme.setMode(mode);

  // --- Responsive Layouts ---

  /// Builds a widget based on screen size breakpoints.
  static Widget responsive({
    required WidgetBuilder mobile,
    WidgetBuilder? tablet,
    WidgetBuilder? desktop,
  }) {
    return Builder(builder: (context) {
      final width = MediaQuery.of(context).size.width;
      if (width >= 1024 && desktop != null) return desktop(context);
      if (width >= 600 && tablet != null) return tablet(context);
      return mobile(context);
    });
  }

  /// A structured layout helper for responsive designs.
  /// Similar to responsive() but with semantic names.
  static Widget layout({
    required WidgetBuilder mobile,
    WidgetBuilder? desktop,
  }) => responsive(mobile: mobile, tablet: desktop, desktop: desktop);

  /// Advanced Grid Layout.
  static Widget grid({
    required List<Widget> children,
    int? columns,
    double gap = 0,
    FxStyle style = FxStyle.none,
    FxResponsiveStyle? responsive,
  }) {
    // Note: GridBox implementation handles responsive columns natively via style
    return GridBox(
      children: children,
      style: style.merge(FxStyle(gap: gap)),
      responsive: responsive,
      // If explicit columns provided, we might need to handle it or rely on style.
      // GridBox currently relies on style.gridCols. 
      // We can map `columns` to a style override if needed, 
      // but standard usage is .gridCols(3).
    );
  }

  // --- Core Primitives ---

  /// A reactive text element. 
  /// Supports: Fx.text("Hello").font.lg.bold
  static Widget text(dynamic data, {FxStyle style = FxStyle.none, String? className, FxResponsiveStyle? responsive}) {
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

  /// Horizontal layout (Row).
  /// Supports: Fx.row(children: [...]).gap.md
  static Widget row({
    required List<Widget> children,
    FxStyle style = FxStyle.none,
    String? className,
    FxResponsiveStyle? responsive,
    double? gap,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  }) {
    return FlexBox(
      direction: Axis.horizontal,
      style: style.merge(FxStyle(gap: gap, justifyContent: mainAxisAlignment, alignItems: crossAxisAlignment)),
      className: className,
      responsive: responsive,
      children: children,
    );
  }

  /// Vertical layout (Column).
  /// Supports: Fx.col(children: [...]).gap.md
  static Widget col({
    required List<Widget> children,
    FxStyle style = FxStyle.none,
    String? className,
    FxResponsiveStyle? responsive,
    double? gap,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  }) {
    return FlexBox(
      direction: Axis.vertical,
      style: style.merge(FxStyle(gap: gap, justifyContent: mainAxisAlignment, alignItems: crossAxisAlignment)),
      className: className,
      responsive: responsive,
      children: children,
    );
  }

  /// Alias for col
  static Widget column({
    required List<Widget> children,
    FxStyle style = FxStyle.none,
    String? className,
    FxResponsiveStyle? responsive,
    double? gap,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  }) => col(
    children: children,
    style: style,
    className: className,
    responsive: responsive,
    gap: gap,
    mainAxisAlignment: mainAxisAlignment,
    crossAxisAlignment: crossAxisAlignment,
  );
  
  /// Stack layout.
  static Widget stack({
    required List<Widget> children,
    FxStyle style = FxStyle.none,
    AlignmentGeometry? alignment,
  }) {
    return StackBox(
      style: style.merge(FxStyle(alignment: alignment)),
      children: children,
    );
  }

  /// Data Table.
  static Widget table<T>({
    required List<T> data,
    required List<FxTableColumn<T>> columns,
    bool striped = true,
    VoidCallback? onRowTap,
  }) {
    return FxTable<T>(
      data: data,
      columns: columns,
      striped: striped,
      onRowTap: onRowTap,
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
      child: SingleChildScrollView(
        scrollDirection: direction,
        child: child,
      ),
    );
  }

  /// Icon primitive.
  static Widget icon(IconData icon, {
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
  static Widget image(String src, {
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
  static Widget hero({
    required String tag,
    required Widget child,
  }) {
    return Hero(tag: tag, child: child);
  }

  // --- Buttons (Phase 5) ---

  static FxButton button(String label, {VoidCallback? onTap}) => primaryButton(label, onTap: onTap);

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
    return FxButton(
      label: label,
      onTap: onTap,
      variant: FxButtonVariant.text,
    );
  }

  // --- Overlays & Feedback ---

  /// Shows a modal dialog.
  /// Shows a modal dialog.
  /// Automatically constrains width on desktop/tablet for a better UX.
  static Future<T?> modal<T>(BuildContext context, {
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
  static Future<T?> dialog<T>(BuildContext context, {required Widget child}) => modal(context, child: child);

  /// Shows a bottom sheet.
  static Future<T?> bottomSheet<T>(BuildContext context, {
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
  static void snack(BuildContext context, String message, {
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
        content: Text(message, style: TextStyle(color: textColor ?? Colors.white)),
        backgroundColor: backgroundColor ?? const Color(0xFF1E293B),
        duration: duration,
        action: action,
        behavior: behavior,
        width: effectiveWidth,
        margin: effectiveWidth == null ? margin : null, // Apply margin only if no width
      ),
    );
  }
  
  /// Alias for snack
  static void toast(BuildContext context, String message) => snack(context, message);

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
      title: titleWidget ?? (title != null ? Text(title, style: const TextStyle(fontWeight: FontWeight.w600)) : null),
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
          activeIcon: (item.activeIcon is Icon) ? (item.activeIcon as Icon).icon : null,
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
    );
  }

  // --- Inputs (Phase 5) ---

  static Widget input({
    required Signal<String> signal,
    String? placeholder,
    bool obscureText = false,
    List<Validator<String>>? validators, // New validators support
  }) {
    // Attach validators if provided
    if (validators != null && signal is FluxField<String>) {
      for (final v in validators) {
        signal.addRule(v);
      }
    }
    
    return FxTextField(
      signal: signal,
      placeholder: placeholder,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: placeholder,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  /// Form container for grouping inputs.
  static Widget form({
    required Widget child,
    FluxForm? form, // Optional binding to a FluxForm
    VoidCallback? onSubmit,
  }) {
    return Builder(builder: (context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          child,
          // We could auto-inject a submit button or handle enter key globally here
        ],
      );
    });
  }
  
  static Widget password({
    required Signal<String> signal,
    String? placeholder = "Password",
  }) {
    return input(signal: signal, placeholder: placeholder, obscureText: true);
  }

  static Widget checkbox({
    required Signal<bool> signal,
    String? label,
  }) {
    final cb = FxCheckbox(signal: signal);
    if (label != null) {
      return row(children: [cb, text(label).textSm()], gap: 8);
    }
    return cb;
  }
  
  static Widget switcher({
    required Signal<bool> signal,
  }) {
    return Fx(() => Switch(
      value: signal.value, 
      onChanged: (v) => signal.value = v
    ));
  }

  // --- Avatars & Badges ---

  static Widget avatar({
    String? image,
    String? fallback,
    FxAvatarSize size = FxAvatarSize.md,
    FxAvatarShape shape = FxAvatarShape.circle,
    VoidCallback? onTap,
  }) {
    return FxAvatar(
      image: image,
      fallback: fallback,
      size: size,
      shape: shape,
      onTap: onTap,
    );
  }

  static Widget badge({
    required Widget child,
    String? label,
    Color? color,
    Offset offset = const Offset(-4, -4),
  }) {
    return FxBadge(
      child: child,
      label: label,
      color: color,
      offset: offset,
    );
  }

  // --- Utilities ---

  /// Staggers a list of widgets with a delay.
  static List<Widget> stagger(List<Widget> children, {double interval = 0.05, double initialDelay = 0}) {
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
  static Future<T?> to<T>(String route, {Object? arguments, String? scope}) => FluxyRouter.to<T>(route, arguments: arguments, scope: scope);
  static Future<T?> go<T>(String route, {Object? arguments, String? scope}) => FluxyRouter.to<T>(route, arguments: arguments, scope: scope);
  static void back<T>([T? result, String? scope]) => FluxyRouter.back<T>(result, scope);
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
