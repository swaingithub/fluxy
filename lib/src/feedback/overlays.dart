import 'package:flutter/material.dart';
import '../routing/fluxy_router.dart'; // FxRouter.navigatorKey

/// Manages global overlay entries like toasts, loaders, and snackbars.
class FxOverlay {
  static final GlobalKey<NavigatorState> _navigatorKey =
      FluxyRouter.navigatorKey;

  static OverlayEntry? _loadingEntry;
  static final List<_ToastEntry> _activeToasts = [];

  /// Displays a global loading overlay.
  static void showLoader({
    bool blocking = true,
    Color? color,
    Widget? customLoader,
    String? label,
  }) {
    if (_loadingEntry != null) return; // Already showing

    _loadingEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Barrier
            if (blocking)
              ModalBarrier(dismissible: false, color: color ?? Colors.black54),

            Center(
              child:
                  customLoader ??
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.white),
                      if (label != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
            ),
          ],
        );
      },
    );

    _navigatorKey.currentState?.overlay?.insert(_loadingEntry!);
  }

  /// Hides the global loading overlay.
  static void hideLoader() {
    _loadingEntry?.remove();
    _loadingEntry = null;
  }

  /// Shows a toast notification.
  static void showToast(
    String message, {
    FxToastType type = FxToastType.info,
    Duration duration = const Duration(seconds: 3),
    FxToastPosition position = FxToastPosition.bottom,
    VoidCallback? onTap,
    Widget? icon,
    Color? backgroundColor,
    Color? textColor,
  }) {
    final entry = _createToastEntry(
      message: message,
      type: type,
      duration: duration,
      position: position,
      onTap: onTap,
      icon: icon,
      backgroundColor: backgroundColor,
      textColor: textColor,
    );

    _navigatorKey.currentState?.overlay?.insert(entry.overlayEntry);
    _activeToasts.add(entry);

    // Auto-remove after duration
    Future.delayed(duration, () {
      _removeToast(entry);
    });
  }

  static _ToastEntry _createToastEntry({
    required String message,
    required FxToastType type,
    required Duration duration,
    required FxToastPosition position,
    VoidCallback? onTap,
    Widget? icon,
    Color? backgroundColor,
    Color? textColor,
  }) {
    late OverlayEntry overlayEntry;

    // Determine colors
    final bg = backgroundColor ?? type.backgroundColor;
    final text = textColor ?? type.textColor;
    final ic = icon ?? type.icon;

    overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        backgroundColor: bg,
        textColor: text,
        icon: ic,
        position: position,
        onTap: () {
          onTap?.call();
          _removeToastByEntry(overlayEntry);
        },
      ),
    );

    return _ToastEntry(overlayEntry);
  }

  static void _removeToast(_ToastEntry entry) {
    if (_activeToasts.contains(entry)) {
      entry.overlayEntry.remove();
      _activeToasts.remove(entry);
    }
  }

  static void _removeToastByEntry(OverlayEntry overlayEntry) {
    final entry = _activeToasts.firstWhere(
      (e) => e.overlayEntry == overlayEntry,
      orElse: () => _ToastEntry(overlayEntry),
    );
    _removeToast(entry);
  }
}

enum FxToastType {
  success(
    Color(0xFF22C55E),
    Colors.white,
    Icon(Icons.check_circle, color: Colors.white, size: 20),
  ),
  error(
    Color(0xFFEF4444),
    Colors.white,
    Icon(Icons.error, color: Colors.white, size: 20),
  ),
  warning(
    Color(0xFFF59E0B),
    Colors.black,
    Icon(Icons.warning, color: Colors.black, size: 20),
  ),
  info(
    Color(0xFF3B82F6),
    Colors.white,
    Icon(Icons.info, color: Colors.white, size: 20),
  );

  final Color backgroundColor;
  final Color textColor;
  final Widget icon;

  const FxToastType(this.backgroundColor, this.textColor, this.icon);
}

enum FxToastPosition { top, bottom, center }

class _ToastEntry {
  final OverlayEntry overlayEntry;
  _ToastEntry(this.overlayEntry);
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final Widget icon;
  final FxToastPosition position;
  final VoidCallback onTap;

  const _ToastWidget({
    required this.message,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
    required this.position,
    required this.onTap,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    // Slide direction based on position
    final beginOffset = widget.position == FxToastPosition.top
        ? const Offset(0, -1)
        : (widget.position == FxToastPosition.bottom
              ? const Offset(0, 1)
              : const Offset(0, 0.5));

    _slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Alignment alignment;
    switch (widget.position) {
      case FxToastPosition.top:
        alignment = Alignment.topCenter;
        break;
      case FxToastPosition.bottom:
        alignment = Alignment.bottomCenter;
        break;
      case FxToastPosition.center:
        alignment = Alignment.center;
        break;
    }

    return SafeArea(
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Material(
            color: Colors.transparent,
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _animation,
                child: GestureDetector(
                  onTap: widget.onTap,
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    constraints: const BoxConstraints(
                      maxWidth: 400,
                    ), // Responsive constraint
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        widget.icon,
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            widget.message,
                            style: TextStyle(
                              color: widget.textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
