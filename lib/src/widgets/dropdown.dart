import 'package:flutter/material.dart';
import '../styles/style.dart';
import '../widgets/box.dart';
import '../reactive/signal.dart';

class FxDropdown<T> extends StatefulWidget {
  final T? value;
  final Signal<T>? signal;
  final List<T> items;
  final ValueChanged<T?>? onChanged;
  final String Function(T)? itemLabel;
  final Widget Function(T)? itemBuilder;
  final String? placeholder;
  final FxStyle style;
  final FxStyle dropdownStyle;
  final Color? iconColor;

  const FxDropdown({
    super.key,
    this.value,
    this.signal,
    required this.items,
    this.onChanged,
    this.itemLabel,
    this.itemBuilder,
    this.placeholder,
    this.style = FxStyle.none,
    this.dropdownStyle = FxStyle.none,
    this.iconColor,
  }) : assert(value != null || signal != null, "Either value or signal must be provided");

  @override
  State<FxDropdown<T>> createState() => _FxDropdownState<T>();
}

class _FxDropdownState<T> extends State<FxDropdown<T>> with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  Effect? _subscription;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _expandAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    
    if (widget.signal != null) {
      _subscription = effect(() {
        widget.signal!.value; // Track dependency
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _subscription?.dispose();
    _animationController.dispose();
    _overlayEntry?.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward();
    setState(() => _isOpen = true);
  }

  void _closeDropdown() {
    _animationController.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      setState(() => _isOpen = false);
    });
  }

  T? get _currentValue => widget.signal?.value ?? widget.value;

  void _handleSelect(T item) {
    if (widget.signal != null) {
      widget.signal!.value = item;
    }
    widget.onChanged?.call(item);
    _closeDropdown();
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Global tap to close
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeDropdown,
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0.0, size.height + 5.0),
              child: Material(
                elevation: 4,
                color: Colors.transparent,
                child: SizeTransition(
                  axisAlignment: 1,
                  sizeFactor: _expandAnimation,
                  child: Box(
                    style: widget.dropdownStyle.merge(FxStyle(
                      backgroundColor: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      // shadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                      padding: const EdgeInsets.symmetric(vertical: 4),
                    )),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: widget.items.map((item) {
                        final isSelected = item == _currentValue;
                        return InkWell(
                          onTap: () => _handleSelect(item),
                          hoverColor: Colors.grey.withOpacity(0.05),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            color: isSelected ? Colors.blue.withOpacity(0.08) : Colors.transparent,
                            child: widget.itemBuilder != null
                              ? widget.itemBuilder!(item)
                              : Text(
                                  widget.itemLabel?.call(item) ?? item.text,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isSelected ? Colors.blue : Colors.black87,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Box(
          style: widget.style.merge(FxStyle(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _isOpen ? Colors.blue : Colors.grey.shade300),
            backgroundColor: Colors.white,
          )),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _currentValue != null 
                  ? (widget.itemLabel?.call(_currentValue!) ?? _currentValue!.text)
                  : (widget.placeholder ?? "Select..."),
                style: TextStyle(
                  fontSize: 14,
                  color: _currentValue != null ? Colors.black87 : Colors.grey.shade400,
                ),
              ),
              RotationTransition(
                turns: Tween(begin: 0.0, end: 0.5).animate(_expandAnimation),
                child: Icon(Icons.keyboard_arrow_down_rounded, 
                  color: widget.iconColor ?? (_isOpen ? Colors.blue : Colors.grey.shade600),
                  size: 20
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

extension on Object? {
  String get text => toString();
}

