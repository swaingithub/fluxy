import 'package:flutter/material.dart';
import '../../fluxy.dart';

/// Renders Fluxy Widgets from JSON Schemas.
class FluxyRenderer {
  final Map<String, dynamic> dataContext;
  final Function(String action)? onAction;

  FluxyRenderer({this.dataContext = const {}, this.onAction});

  Widget render(Map<String, dynamic> json) {
    if (json.isEmpty) return const SizedBox.shrink();

    final String type = json['type'] ?? 'box';
    final FxStyle style = FluxyStyleParser.parse(json['style']);
    final String? action = json['onTap'] ?? json['action'];

    switch (type) {
      case 'box':
        return Fx.box(
          style: style,
          onTap: action != null ? () => _handleAction(action) : null,
          child: _renderSingleChild(json) ?? const SizedBox.shrink(),
          children: _renderChildren(json),
        );

      case 'text':
        final textWidget = Fx.text(
          _interpolate(json['data'] ?? ''),
          style: style,
        );
        if (action != null) {
          return GestureDetector(
            onTap: () => _handleAction(action),
            child: textWidget,
          );
        }
        return textWidget;

      case 'button':
        return Fx.box(
          onTap: () => _handleAction(action ?? ''),
          style: style,
          child:
              _renderSingleChild(json) ??
              Fx.text(_interpolate(json['label'] ?? 'Click')),
        );

      case 'image':
        final url = _interpolate(json['url'] ?? '');
        return Fx.image(
          url,
          width: style.width,
          height: style.height,
          radius: style.borderRadius is BorderRadius
              ? (style.borderRadius as BorderRadius).topLeft.x
              : 0,
          // Simplified implementation for radius extraction
          fit: _parseBoxFit(json['fit']),
        );

      case 'row':
        return Fx.row(
          children: _renderChildren(json),
          style: style,
          gap: (json['gap'] as num?)?.toDouble(),
        );

      case 'column':
        return Fx.column(
          children: _renderChildren(json),
          style: style,
          gap: (json['gap'] as num?)?.toDouble(),
        );

      case 'hero':
        final tag = _interpolate(json['tag'] ?? '');
        return Fx.hero(
          tag: tag,
          child: _renderSingleChild(json) ?? const SizedBox.shrink(),
        );

      default:
        return Text(
          'Unknown Type: $type',
          style: const TextStyle(color: Colors.red),
        );
    }
  }

  // --- Internals ---

  List<Widget> _renderChildren(Map<String, dynamic> json) {
    if (json['children'] is List) {
      return (json['children'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => render(e))
          .toList();
    }
    return [];
  }

  Widget? _renderSingleChild(Map<String, dynamic> json) {
    if (json['child'] is Map<String, dynamic>) {
      return render(json['child']);
    }
    return null;
  }

  void _handleAction(String action) {
    if (action.isEmpty) return;

    if (onAction != null) {
      onAction!(action);
      return;
    }

    // Default Action Parser
    if (action.startsWith('navigate:')) {
      final route = action.substring(9);
      FluxyRouter.to(route);
    } else if (action.startsWith('print:')) {
      debugPrint('[FluxyRemote]: ${action.substring(6)}');
    } else if (action == 'back') {
      FluxyRouter.back();
    }
  }

  String _interpolate(String text) {
    if (!text.contains('{')) return text;
    return text.replaceAllMapped(RegExp(r'\{(\w+(?:\.\w+)*)\}'), (match) {
      final key = match.group(1)!;
      return _getValue(key)?.toString() ?? match.group(0)!;
    });
  }

  dynamic _getValue(String path) {
    final keys = path.split('.');
    dynamic current = dataContext;
    for (final key in keys) {
      if (current is Map && current.containsKey(key)) {
        current = current[key];
      } else {
        return null;
      }
    }
    return current;
  }

  BoxFit _parseBoxFit(String? fit) {
    switch (fit) {
      case 'contain':
        return BoxFit.contain;
      case 'cover':
        return BoxFit.cover;
      case 'fill':
        return BoxFit.fill;
      case 'fitWidth':
        return BoxFit.fitWidth;
      case 'fitHeight':
        return BoxFit.fitHeight;
      default:
        return BoxFit.cover;
    }
  }
}

/// A widget that fetches and renders remote UI.
class FxRemoteView extends StatefulWidget {
  final String path;
  final Widget? placeholder;
  final Widget Function(dynamic error)? errorBuilder;
  final Map<String, dynamic> data;

  const FxRemoteView({
    super.key,
    required this.path,
    this.placeholder,
    this.errorBuilder,
    this.data = const {},
  });

  @override
  State<FxRemoteView> createState() => _FxRemoteViewState();
}

class _FxRemoteViewState extends State<FxRemoteView> {
  late Future<Map<String, dynamic>?> _fetchFuture;

  @override
  void initState() {
    super.initState();
    _fetchFuture = FluxyRemote.getJson(widget.path);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.placeholder ??
              const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return widget.errorBuilder?.call(snapshot.error) ??
              Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return widget.errorBuilder?.call('No Data') ??
              const Text('Asset not found');
        }

        return FluxyRenderer(dataContext: widget.data).render(snapshot.data!);
      },
    );
  }
}
