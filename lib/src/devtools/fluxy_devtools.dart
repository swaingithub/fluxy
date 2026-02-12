// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'dart:async';
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
  bool _isOpen = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    FluxyReactiveContext.onSignalUpdate = (signal, value) {
      if (mounted) {
        setState(() {
          _logs.insert(0, "[UPDATE] ${signal.label ?? signal.id} -> $value");
          if (_logs.length > 50) _logs.removeLast();
        });
      }
    };
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _toggleOpen() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _refreshTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
          if (mounted) setState(() {});
        });
      } else {
        _refreshTimer?.cancel();
      }
    });
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
        onPressed: _toggleOpen,
        child: Icon(_isOpen ? Icons.close : Icons.bug_report, color: Colors.white),
      ),
    );
  }

  Widget _buildOverlay() {
    return Material(
      color: Colors.black.withOpacity(0.9),
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
                        Tab(text: "Active Signals"),
                        Tab(text: "Timeline Logs"),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildSignalList(),
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
          const Text("Fluxy DevTools 🛠️", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          Row(
            children: [
              Text('${SignalRegistry.all.length} Signals', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_sweep, color: Colors.white70),
                onPressed: () => setState(() => _logs.clear()),
              ),
            ],
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

  Widget _buildSignalList() {
    final signals = SignalRegistry.all;
    
    if (signals.isEmpty) {
      return const Center(child: Text("No active signals", style: TextStyle(color: Colors.white54)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: signals.length,
      itemBuilder: (context, index) {
        final signal = signals[index];
        final subsCount = signal.subscribers.length;
        final isComputed = signal is Computed;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isComputed ? Colors.purpleAccent.withOpacity(0.3) : Colors.blueAccent.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      signal.label ?? signal.id,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (isComputed ? Colors.purple : Colors.blue).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isComputed ? "COMPUTED" : "SIGNAL",
                      style: TextStyle(color: isComputed ? Colors.purpleAccent : Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                 width: double.infinity,
                 padding: const EdgeInsets.all(8),
                 color: Colors.black26,
                 child: Text(
                    "${signal.toString()}",
                    style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace', fontSize: 12),
                 ),
              ),
              const SizedBox(height: 4),
              Text(
                "Subscribers: $subsCount | ID: ${signal.id}",
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ],
          ),
        );
      },
    );
  }
}
