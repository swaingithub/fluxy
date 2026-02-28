import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../error_pipeline.dart';
import '../../dsl/fx.dart';

/// A professional error boundary that prevents app-wide crashes.
/// In production, it shows a user-friendly recovery UI.
class FluxyErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget? fallback;

  const FluxyErrorBoundary({
    super.key, 
    required this.child, 
    this.fallback,
  });

  @override
  State<FluxyErrorBoundary> createState() => _FluxyErrorBoundaryState();
}

class _FluxyErrorBoundaryState extends State<FluxyErrorBoundary> {
  Object? _error;

  @override
  void initState() {
    super.initState();
    // Hook into global error pipeline
    FluxyError.onError(_handleExternalError);
  }

  void _handleExternalError(Object error, StackTrace? stack) {
    if (mounted && _error == null) {
      setState(() {
        _error = error;
      });
    }
  }

  @override
  void activate() {
    super.activate();
    _reset();
  }

  void _reset() {
    setState(() {
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.fallback ?? _DefaultErrorView(
        error: _error!,
        onRetry: _reset,
      );
    }

    try {
      return widget.child;
    } catch (e, stack) {
      _handleExternalError(e, stack);
      return const SizedBox.shrink();
    }
  }
}

class _DefaultErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _DefaultErrorView({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Fx.center(
          child: Fx.col(
            size: MainAxisSize.min,
            gap: 20,
            children: [
              const Icon(Icons.privacy_tip_outlined, size: 60, color: Colors.orange),
              Fx.text('Stability Recovery Active').font.xl2().bold(),
              Fx.text('Our real-time engine caught a mismatch and is preventing a crash.')
                  .textAlign(TextAlign.center).muted().px(40),
              if (kDebugMode)
                Fx.box(
                  style: FxStyle(
                    backgroundColor: Colors.grey.shade100,
                    padding: const EdgeInsets.all(12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Fx.text(error.toString()).font.xs().color(Colors.red),
                ),
              Fx.primaryButton('ATTEMPT RECOVERY', onTap: onRetry)
                  .w(220).background(Colors.black),
              Fx.textButton('Exit Application', onTap: () => Navigator.of(context).maybePop()),
            ],
          ),
        ),
      ),
    );
  }
}
