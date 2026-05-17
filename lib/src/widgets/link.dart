import 'package:flutter/material.dart';
import '../styles/style.dart';
import '../dsl/fx.dart';
import 'box.dart';
import '../routing/fluxy_router.dart';

class FxLink extends StatelessWidget {
  final dynamic label; // Accepts String or Widget
  final VoidCallback? onTap;
  final String? to; 
  final FxStyle style;
  final String? className;
  final FxResponsiveStyle? responsive;

  const FxLink({
    super.key,
    required this.label,
    this.onTap,
    this.to,
    this.style = FxStyle.none,
    this.className,
    this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    return Box(
      onTap: onTap ?? (to != null ? () => FluxyRouter.to(to!) : null),
      style: const FxStyle(
        cursor: SystemMouseCursors.click,
        transition: Duration(milliseconds: 200),
        hover: FxStyle(opacity: 0.7), // Default subtle hover for web links
      ).merge(style),
      className: className,
      responsive: responsive,
      child: label is Widget ? label as Widget : Fx.text(label),
    );
  }
}

class FxNavLink extends StatelessWidget {
  final dynamic label; // Accepts String or Widget
  final String to;
  final FxStyle style;
  final FxStyle activeStyle;
  final String? className;
  final String? activeClassName;

  const FxNavLink({
    super.key,
    required this.label,
    required this.to,
    this.style = FxStyle.none,
    this.activeStyle = FxStyle.none,
    this.className,
    this.activeClassName,
  });

  @override
  Widget build(BuildContext context) {
    // Current route inference based on native Flutter navigator
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final isActive = currentRoute == to;

    return Box(
      onTap: () => FluxyRouter.to(to),
      style: const FxStyle(
        cursor: SystemMouseCursors.click,
        transition: Duration(milliseconds: 200),
        hover: FxStyle(opacity: 0.7),
      ).merge(style).merge(isActive ? activeStyle : FxStyle.none),
      className: isActive ? (activeClassName ?? className) : className,
      child: label is Widget ? label as Widget : Fx.text(label),
    );
  }
}
