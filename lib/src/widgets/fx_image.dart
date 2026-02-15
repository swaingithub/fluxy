import 'dart:ui';
import 'package:flutter/material.dart';
import '../styles/style.dart';
import '../engine/style_resolver.dart';
import '../reactive/signal.dart';
import 'fx_widget.dart';
import 'box.dart';

/// A reactive and chainable Image widget for Fluxy.
class FxImage extends FxWidget {
  final String src;
  final FxStyle style;
  final FxResponsiveStyle? responsive;
  final VoidCallback? onTap;

  const FxImage(
    this.src, {
    super.key,
    super.id,
    super.className,
    this.style = FxStyle.none,
    this.responsive,
    this.onTap,
  });

  @override
  FxImage copyWithStyle(FxStyle additionalStyle) {
    return copyWith(style: style.merge(additionalStyle));
  }

  @override
  FxImage copyWithResponsive(FxResponsiveStyle additionalResponsive) {
    return copyWith(
      responsive: responsive?.merge(additionalResponsive) ?? additionalResponsive,
    );
  }

  FxImage copyWith({
    String? src,
    FxStyle? style,
    FxResponsiveStyle? responsive,
    VoidCallback? onTap,
    String? className,
  }) {
    return FxImage(
      src ?? this.src,
      key: key,
      id: id,
      className: className ?? this.className,
      style: style ?? this.style,
      responsive: responsive ?? this.responsive,
      onTap: onTap ?? this.onTap,
    );
  }

  @override
  State<FxImage> createState() => _FxImageState();
}

class _FxImageState extends State<FxImage> with ReactiveSubscriberMixin {
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
      final s = FxStyleResolver.resolve(
        context,
        style: widget.style,
        className: widget.className,
        responsive: widget.responsive,
      );

      final actualSrc = s.imageSrc ?? widget.src;
      final isAsset = !actualSrc.startsWith('http') && !actualSrc.startsWith('file://');
      Widget image;

      if (isAsset) {
        image = Image.asset(
          actualSrc,
          width: s.width,
          height: s.height,
          fit: s.fit ?? BoxFit.cover,
          errorBuilder: (c, e, st) => s.error ?? _defaultError(s),
        );
      } else {
        image = Image.network(
          actualSrc,
          width: s.width,
          height: s.height,
          fit: s.fit ?? BoxFit.cover,
          loadingBuilder: (c, child, progress) {
            if (progress == null) return child;
            return s.loading ?? s.placeholder ?? _defaultLoading();
          },
          errorBuilder: (c, e, st) => s.error ?? _defaultError(s),
        );
      }

      // Apply Filters (Blur, Grayscale)
      if (s.imageBlur != null || (s.grayscale ?? false)) {
        ImageFilter filter = ImageFilter.blur(
          sigmaX: s.imageBlur ?? 0,
          sigmaY: s.imageBlur ?? 0,
        );

        if (s.grayscale ?? false) {
          image = ColorFiltered(
            colorFilter: const ColorFilter.matrix([
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0,      0,      0,      1, 0,
            ]),
            child: image,
          );
        }

        if (s.imageBlur != null) {
          image = ImageFiltered(imageFilter: filter, child: image);
        }
      }

      // Wrap in Box for layout/decoration (borders, shadows, etc)
      return Box(
        onTap: widget.onTap,
        style: s.copyWith(
          // Don't pass down width/height to Box if we want Image to handle it?
          // Actually Box should handle the outer constraints.
        ),
        child: image,
      );
    } finally {
      FluxyReactiveContext.pop();
    }
  }

  Widget _defaultLoading() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _defaultError(FxStyle s) {
    return Container(
      width: s.width,
      height: s.height,
      color: Colors.grey.shade100,
      child: Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade400),
    );
  }
}
