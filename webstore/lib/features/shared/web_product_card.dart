import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';

/// A premium, dynamic product card designed for Fluxy Web.
/// Highly adjustable with built-in hover effects and responsive behavior.
class WebProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback? onTap;
  final VoidCallback? onAction;
  final String actionLabel;
  final double width;
  final double? height;
  final double? aspectRatio;
  final bool isCollection; // New flag for collection view

  const WebProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAction,
    this.actionLabel = 'Quick Add',
    this.width = 260,
    this.height,
    this.aspectRatio = 1.1,
    this.isCollection = false,
  });

  @override
  Widget build(BuildContext context) {
    final price = product['price'] is num ? product['price'] : 0.0;
    final formattedPrice = '\$${price.toStringAsFixed(price % 1 == 0 ? 0 : 2)}';
    final name = product['name'] ?? 'Unknown';
    final category = product['category'] ?? (isCollection ? 'VOL. ${product['tag'] ?? '00'}' : '');

    return Fx.box(
      onTap: onTap,
      style: FxStyle(
        width: width,
        height: height,
        backgroundColor: Colors.white,
        borderRadius: BorderRadius.circular(24),
        padding: const EdgeInsets.all(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        shadows: FxTokens.shadow.sm,
        transition: const Duration(milliseconds: 250),
        cursor: SystemMouseCursors.click,
        hover: FxStyle(
          transformScale: 1.02,
          shadows: FxTokens.shadow.lg,
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
      ),
      child: Fx.col(
        size: MainAxisSize.min,
        alignItems: CrossAxisAlignment.start,
        children: [
          /// IMAGE SECTION
          AspectRatio(
            aspectRatio: aspectRatio!,
            child: Fx.image(
              product['image'],
              width: double.infinity,
              fit: BoxFit.cover,
              radius: 18,
            ),
          ),

          Fx.gap(18),

          /// INFO SECTION
          Fx.row(
            alignItems: CrossAxisAlignment.start,
            children: [
              Fx.expand(
                child: Fx.text(name).tw('text-[17px] font-bold text-slate-900 leading-tight'),
              ),
              if (!isCollection) ...[
                Fx.hgap(12),
                Fx.box(
                  style: const FxStyle(padding: EdgeInsets.only(top: 2)),
                  child: Fx.text(formattedPrice).tw('text-[17px] font-bold text-blue-500'),
                ),
              ],
            ],
          ),

          Fx.gap(6),

          /// SUBTITLE / CATEGORY / TAG
          if (category.isNotEmpty)
            Fx.text(category).tw('text-sm font-semibold text-slate-400 tracking-wide'),

          Fx.gap(24),

          /// ACTION BUTTON
          if (onAction != null || isCollection)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FxButton(
                onTap: onAction ?? onTap ?? () {},
                isRounded: true,
                style: const FxStyle(
                  backgroundColor: Color(0xFFF8FAFC),
                  transition: Duration(milliseconds: 200),
                  hover: FxStyle(backgroundColor: Color(0xFFE2E8F0)),
                ),
                child: Fx.text(isCollection ? 'Explore Collection' : actionLabel).tw('text-[14px] font-bold text-slate-900'),
              ),
            ),
        ],
      ),
    );
  }
}
