import '../dsl/fx.dart';

/// Legacy shim for FxHaptic that delegates to the modular fluxy_haptics plugin.
/// This ensures backward compatibility for plugins that expect FxHaptic to be in core.
class FxHaptic {
  static void light() => Fx.haptic?.light();
  static void medium() => Fx.haptic?.medium();
  static void heavy() => Fx.haptic?.heavy();
  static void selection() => Fx.haptic?.selection();
  static void error() => Fx.haptic?.error();
  static void success() => Fx.haptic?.success();
}
