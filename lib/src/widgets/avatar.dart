import 'package:flutter/material.dart';
import '../styles/style.dart';
import '../styles/tokens.dart';
import '../widgets/box.dart';

enum FxAvatarSize { sm, md, lg, xl }
enum FxAvatarShape { circle, square, rounded }

class FxAvatar extends StatelessWidget {
  final String? image;
  final String? fallback;
  final Widget? fallbackWidget;
  final FxAvatarSize size;
  final FxAvatarShape shape;
  final FxStyle style;
  final VoidCallback? onTap;

  const FxAvatar({
    super.key,
    this.image,
    this.fallback,
    this.fallbackWidget,
    this.size = FxAvatarSize.md,
    this.shape = FxAvatarShape.circle,
    this.style = FxStyle.none,
    this.onTap,
  });

  double get _size {
    switch (size) {
      case FxAvatarSize.sm: return 32;
      case FxAvatarSize.md: return 40;
      case FxAvatarSize.lg: return 56;
      case FxAvatarSize.xl: return 80;
    }
  }

  double get _radius {
    switch (shape) {
      case FxAvatarShape.circle: return _size / 2;
      case FxAvatarShape.square: return 0;
      case FxAvatarShape.rounded: return FxTokens.radius.md;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    
    if (image != null) {
      content = Image.network(
        image!,
        width: _size,
        height: _size,
        fit: BoxFit.cover,
        errorBuilder: (c, o, s) => _buildFallback(),
      );
    } else {
      content = _buildFallback();
    }

    return Box(
      onTap: onTap,
      style: style.merge(FxStyle(
        width: _size,
        height: _size,
        borderRadius: BorderRadius.circular(_radius),
        backgroundColor: Colors.grey.shade200,
        clipBehavior: Clip.antiAlias,
        alignment: Alignment.center,
      )),
      child: content,
    );
  }

  Widget _buildFallback() {
    if (fallbackWidget != null) return fallbackWidget!;
    if (fallback != null) {
      return Text(
        fallback!.substring(0, (fallback!.length > 2 ? 2 : fallback!.length)).toUpperCase(),
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
