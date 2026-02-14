import 'package:flutter/material.dart';
import 'debug_config.dart';

/// The FluxyInspector provides a visual overlay for debugging layout and performance.
class FluxyInspector extends StatefulWidget {
  final Widget child;

  const FluxyInspector({super.key, required this.child});

  @override
  State<FluxyInspector> createState() => _FluxyInspectorState();
}

class _FluxyInspectorState extends State<FluxyInspector> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (FluxyDebugConfig.isInspectorActive) _buildControlPanel(),
      ],
    );
  }

  Widget _buildControlPanel() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        color: Colors.black87,
        child: Container(
          padding: const EdgeInsets.all(12),
          width: 250,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Fluxy Inspector',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Divider(color: Colors.white24),
              _buildToggle(
                'Layout Borders',
                FluxyDebugConfig.showLayoutBorders,
                (val) =>
                    setState(() => FluxyDebugConfig.showLayoutBorders = val),
              ),
              _buildToggle(
                'Performance Overlay',
                FluxyDebugConfig.showPerformanceOverlay,
                (val) => setState(
                  () => FluxyDebugConfig.showPerformanceOverlay = val,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Press Ctrl+D to toggle',
                style: TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.blueAccent,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }
}
