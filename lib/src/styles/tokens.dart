import 'package:flutter/widgets.dart';

/// Design tokens for the Fluxy design system.
class FxTokens {
  static const space = _SpaceTokens();
  static const radius = _RadiusTokens();
  static const font = _FontTokens();
  static const shadow = _ShadowTokens();
  static const colors = _ColorTokens();
}

class _SpaceTokens {
  const _SpaceTokens();
  double get zero => 0;
  double get xs => 4;
  double get sm => 8;
  double get md => 12;
  double get lg => 16;
  double get xl => 24;
  double get xxl => 32;
  double get xxxl => 48;
  double get x4l => 64;
  double get x5l => 80;
  double get x6l => 96;

  // Numeric aliases for cleaner DSL
  double n(double value) => value;
}

class _RadiusTokens {
  const _RadiusTokens();
  double get none => 0;
  double get xs => 2;
  double get sm => 4;
  double get md => 6;
  double get lg => 8;
  double get xl => 12;
  double get xxl => 16;
  double get xxxl => 24;
  double get full => 9999;
}

class _FontTokens {
  const _FontTokens();
  double get xs => 12;
  double get sm => 14;
  double get base => 16;
  double get md => 16;
  double get lg => 18;
  double get xl => 20;
  double get xxl => 24;
  double get xxxl => 30;
  double get x4l => 36;
  double get x5l => 48;
  double get x6l => 60;
}

class _ShadowTokens {
  const _ShadowTokens();
  List<BoxShadow> get none => [];
  List<BoxShadow> get sm => [
    BoxShadow(color: Color(0x0D000000), offset: Offset(0, 1), blurRadius: 2),
  ];
  List<BoxShadow> get md => [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -1,
    ),
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -1,
    ),
  ];
  List<BoxShadow> get lg => [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 10),
      blurRadius: 15,
      spreadRadius: -3,
    ),
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -2,
    ),
  ];
  List<BoxShadow> get xl => [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 20),
      blurRadius: 25,
      spreadRadius: -5,
    ),
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 10),
      blurRadius: 10,
      spreadRadius: -5,
    ),
  ];
}

class _ColorTokens {
  const _ColorTokens();
  Color get white => const Color(0xFFFFFFFF);
  Color get black => const Color(0xFF000000);
  Color get transparent => const Color(0x00000000);

  // Slate (Tailwind-style)
  Color get slate50 => const Color(0xFFF8FAFC);
  Color get slate100 => const Color(0xFFF1F5F9);
  Color get slate200 => const Color(0xFFE2E8F0);
  Color get slate300 => const Color(0xFFCBD5E1);
  Color get slate400 => const Color(0xFF94A3B8);
  Color get slate500 => const Color(0xFF64748B);
  Color get slate600 => const Color(0xFF475569);
  Color get slate700 => const Color(0xFF334155);
  Color get slate800 => const Color(0xFF1E293B);
  Color get slate900 => const Color(0xFF0F172A);

  // Blue
  Color get blue50 => const Color(0xFFEFF6FF);
  Color get blue500 => const Color(0xFF3B82F6);
  Color get blue600 => const Color(0xFF2563EB);
  Color get blue700 => const Color(0xFF1D4ED8);
}
