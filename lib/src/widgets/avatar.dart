import 'package:flutter/material.dart';
import '../styles/style.dart';
import '../styles/tokens.dart';
import '../widgets/box.dart';
import '../widgets/fx_widget.dart';

enum FxAvatarSize { sm, md, lg, xl }

enum FxAvatarShape { circle, square, rounded }

class FxAvatar extends FxWidget {
  final String? image;
  final String? fallback;
  final Widget? fallbackWidget;
  final FxAvatarSize size;
  final FxAvatarShape shape;
  final FxStyle style;
  final FxResponsiveStyle? responsive;
  final VoidCallback? onTap;

  const FxAvatar({
    super.key,
    super.id,
    super.className,
    this.image,
    this.fallback,
    this.fallbackWidget,
    this.size = FxAvatarSize.md,
    this.shape = FxAvatarShape.circle,
    this.style = FxStyle.none,
    this.responsive,
    this.onTap,
  });

  @override
  FxAvatar copyWithStyle(FxStyle additionalStyle) {
    return copyWith(style: style.merge(additionalStyle));
  }

  @override
  FxAvatar copyWithResponsive(FxResponsiveStyle additionalResponsive) {
    return copyWith(
      responsive: responsive?.merge(additionalResponsive) ?? additionalResponsive,
    );
  }

  FxAvatar copyWith({
    String? image,
    String? fallback,
    Widget? fallbackWidget,
    FxAvatarSize? size,
    FxAvatarShape? shape,
    FxStyle? style,
    FxResponsiveStyle? responsive,
    VoidCallback? onTap,
    String? className,
  }) {
    return FxAvatar(
      key: key,
      id: id,
      className: className ?? this.className,
      image: image ?? this.image,
      fallback: fallback ?? this.fallback,
      fallbackWidget: fallbackWidget ?? this.fallbackWidget,
      size: size ?? this.size,
      shape: shape ?? this.shape,
      style: style ?? this.style,
      responsive: responsive ?? this.responsive,
      onTap: onTap ?? this.onTap,
    );
  }

  @override
  State<FxAvatar> createState() => _FxAvatarState();
}

class _FxAvatarState extends State<FxAvatar> {
  double get _size {
    switch (widget.size) {
      case FxAvatarSize.sm:
        return 32;
      case FxAvatarSize.md:
        return 40;
      case FxAvatarSize.lg:
        return 56;
      case FxAvatarSize.xl:
        return 80;
    }
  }

  double get _radius {
    switch (widget.shape) {
      case FxAvatarShape.circle:
        return _size / 2;
      case FxAvatarShape.square:
        return 0;
      case FxAvatarShape.rounded:
        return FxTokens.radius.md;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (widget.image != null) {
      content = Image.network(
        widget.image!,
        width: _size,
        height: _size,
        fit: BoxFit.cover,
        errorBuilder: (c, o, s) => _buildFallback(),
      );
    } else {
      content = _buildFallback();
    }

    return Box(
      id: widget.id,
      className: widget.className,
      onTap: widget.onTap,
      responsive: widget.responsive,
      style: widget.style.merge(
        FxStyle(
          width: _size,
          height: _size,
          borderRadius: BorderRadius.circular(_radius),
          backgroundColor: Colors.grey.shade200,
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.center,
        ),
      ),
      child: content,
    );
  }

  Widget _buildFallback() {
    if (widget.fallbackWidget != null) return widget.fallbackWidget!;
    if (widget.fallback != null) {
      return Text(
        widget.fallback!
            .substring(0, (widget.fallback!.length > 2 ? 2 : widget.fallback!.length))
            .toUpperCase(),
        style: TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.bold,
          fontSize: _size * 0.4,
        ),
      );
    }
    return Icon(Icons.person, color: Colors.grey.shade400, size: _size * 0.6);
  }
}
