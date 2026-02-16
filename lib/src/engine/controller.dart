import 'package:flutter/foundation.dart';
import '../reactive/signal.dart';

/// The base class for all Fluxy Controllers.
/// Controllers hold the business logic and state for a specific feature or view.
abstract class FluxController {
  final List<Flux> _managedFluxes = [];
  bool _initialized = false;

  /// Called when the controller is first created and injected into the DI system.
  @mustCallSuper
  void onInit() {
    _initialized = true;
  }

  /// Called after the widget is rendered on screen.
  void onReady() {}

  /// Called when the controller is being removed from memory.
  /// Automatically disposes of all fluxes registered via `addFlux`.
  @mustCallSuper
  void onDispose() {
    for (var flux in _managedFluxes) {
      flux.dispose();
    }
    _managedFluxes.clear();
  }

  /// Internal helper to track fluxes for automatic disposal.
  @protected
  T track<T extends Flux>(T flux) {
    _managedFluxes.add(flux);
    return flux;
  }

  bool get isInitialized => _initialized;
}
