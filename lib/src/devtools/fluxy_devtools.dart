import 'package:flutter/material.dart';
import '../reactive/signal.dart';

/// The Fluxy Debug Inspector & DevTools.
class FluxyDevTools extends StatefulWidget {
  final Widget child;

  const FluxyDevTools({super.key, required this.child});

  static void show(BuildContext context) {
     // Implementation to show devtools as an overlay if needed, 
     // but here we use it as a wrapper.
  }

  @override
  State<FluxyDevTools> createState() => _FluxyDevToolsState();
}

class _FluxyDevToolsState extends State<FluxyDevTools> {
  final List<String> _logs = [];
  final Map<String, Signal> _registry = {};
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    FluxyReactiveContext.onSignalUpdate = (signal, value) {
      _registry[signal.id] = signal;
      setState(() {
        _logs.insert(0, "[UPDATE] ${signal.label ?? signal.id} -> $value");
        if (_logs.length > 50) _logs.removeLast();
      });
    };
    
    FluxyReactiveContext.onSignalRead = (signal) {
      _registry[signal.id] = signal;
    };
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isOpen) _buildOverlay(),
        _buildFab(),
      ],
    );
  }

  Widget _buildFab() {
    return Positioned(
      right: 16,
      bottom: 16,
      child: FloatingActionButton(
        mini: true,
        backgroundColor: const Color(0xFF2563EB),
        onPressed: () => setState(() => _isOpen = !_isOpen),
        child: Icon(_isOpen ? Icons.close : Icons.bug_report, color: Colors.white),
      ),
    );
  }

  Widget _buildOverlay() {
    return Material(
      // ignore: deprecated_member_use
      color: Colors.black.withOpacity(0.8),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: "Signals Graph"),
                        Tab(text: "Timeline Logs"),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildSignalGraph(),
                          _buildTimelineLogs(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Fluxy DevTools", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.white70),
            onPressed: () => setState(() => _logs.clear()),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineLogs() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _logs.length,
      itemBuilder: (context, index) => Text(
        _logs[index],
        style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontFamily: 'monospace'),
      ),
    );
  }

  Widget _buildSignalGraph() {
    final signals = _registry.values.toList();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: signals.length,
      itemBuilder: (context, index) {
        final signal = signals[index];
        final subsCount = signal.subscribers.length;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    signal.label ?? signal.id,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "VAL: ${signal.toString()}",
                      style: const TextStyle(color: Colors.blueAccent, fontSize: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "Subscribers: $subsCount | Dependencies: tracked automatically",
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ],
          ),
        );
      },
    );
  }
}
