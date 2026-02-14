import 'package:flutter/widgets.dart';
import '../styles/style.dart';

/// The base class for all Fluxy widgets.
/// Enables "Attribute Accumulation" DSL by allowing style merging without re-wrapping.
abstract class FxWidget extends StatefulWidget {
  final String? id;
  final String? className;

  const FxWidget({super.key, this.id, this.className});

  /// The style associated with this widget.
  FxStyle get style;

  /// The responsive style associated with this widget.
  FxResponsiveStyle? get responsive;

  /// Returns a copy of this widget with the additional style merged in.
  FxWidget copyWithStyle(FxStyle additionalStyle);

  /// Returns a copy of this widget with the additional responsive style merged in.
  FxWidget copyWithResponsive(FxResponsiveStyle additionalResponsive);
}

/// A mixin to provide common functionality for FxWidget states.
mixin FxWidgetStateMixin<T extends FxWidget> on State<T> {
  // Common logic for resolving styles, etc. can go here later.
}
