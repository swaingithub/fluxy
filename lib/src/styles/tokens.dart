
import 'package:flutter/widgets.dart';

/// Design tokens for the Fluxy design system.
class FxTokens {
  static const space = _SpaceTokens();
  static const radius = _RadiusTokens();
  static const font = _FontTokens();
  static const shadow = _ShadowTokens();
}

class _SpaceTokens {
  const _SpaceTokens();
  double get xs => 4;
  double get sm => 8;
  double get md => 12;
  double get lg => 16;
  double get xl => 20;
  double get xxl => 24; // 2xl
  double get xxxl => 32; // 3xl
}

class _RadiusTokens {
  const _RadiusTokens();
  double get xs => 4;
  double get sm => 8;
  double get md => 12;
  double get lg => 16;
  double get xl => 24;
  double get full => 9999;
}

class _FontTokens {
  const _FontTokens();
  double get xs => 12;
  double get sm => 14;
  double get md => 16;
  double get lg => 18;
  double get xl => 22;
  double get xxl => 28;
  double get xxxl => 36;
}

class _ShadowTokens {
  const _ShadowTokens();
  List<BoxShadow> get sm => [
    BoxShadow(color: Color(0x0D000000), offset: Offset(0, 1), blurRadius: 2),
  ];
  List<BoxShadow> get md => [
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 4), blurRadius: 6, spreadRadius: -1),
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 2), blurRadius: 4, spreadRadius: -1),
  ];
  List<BoxShadow> get lg => [
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 10), blurRadius: 15, spreadRadius: -3),
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 4), blurRadius: 6, spreadRadius: -2),
  ];
  List<BoxShadow> get xl => [
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 20), blurRadius: 25, spreadRadius: -5),
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 10), blurRadius: 10, spreadRadius: -5),
  ];
}
