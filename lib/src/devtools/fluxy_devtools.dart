import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:ui';
import '../reactive/signal.dart';
import '../di/fluxy_di.dart';
import '../networking/fluxy_http.dart';

/// The Fluxy Debug Inspector & DevTools (Premium Version).
/// Provides real-time visibility into Signals, DI Registry, and Network.
class FluxyDevTools extends StatefulWidget {
  final Widget child;

  const FluxyDevTools({super.key, required this.child});

  @override
  State<FluxyDevTools> createState() => _FluxyDevToolsState();
}

class _FluxyDevToolsState extends State<FluxyDevTools> {
  final List<String> _logs = [];
  bool _isOpen = false;
  Timer? _refreshTimer;
  int _activeTab = 0;

  @override
  void initState() {
    super.initState();
    _setupTimeline();
  }

  void _setupTimeline() {
    FluxyReactiveContext.onFluxUpdate = (flux, value) {
      if (mounted) {
        setState(() {
          _logs.insert(0, "[UPDATE] ${flux.label ?? flux.id} -> $value");
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
        _refreshTimer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
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
        if (_isOpen) ...[
          _buildBlurBackground(),
          _buildPanel(),
        ],
        _buildFab(),
      ],
    );
  }

  Widget _buildBlurBackground() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: _toggleOpen,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(color: Colors.black.withValues(alpha: 0.3)),
        ),
      ),
    );
  }

  Widget _buildFab() {
    return Positioned(
      right: 20,
      bottom: 20,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggleOpen,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Icon(
              _isOpen ? Icons.close : Icons.bug_report_rounded,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPanel() {
    return Positioned(
      bottom: 90,
      right: 20,
      left: 20,
      top: 100,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 40,
              offset: const Offset(0, 20),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            children: [
              _buildPanelHeader(),
              _buildTabBar(),
              Expanded(child: _buildTabContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPanelHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.bolt, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Fluxy Inspector",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    "v0.1.11 - Debug Engine",
                    style: TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: () => setState(() => _logs.clear()),
            icon: const Icon(Icons.delete_sweep_outlined, color: Colors.white38),
            tooltip: "Clear Logs",
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ["Fluxes", "DI Container", "Network", "Timeline"];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final isSelected = _activeTab == index;
          return GestureDetector(
            onTap: () => setState(() => _activeTab = index),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? Colors.blue : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                tabs[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white38,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_activeTab) {
      case 0: return _buildFluxList();
      case 1: return _buildDIList();
      case 2: return _buildNetworkList();
      case 3: return _buildTimeline();
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildFluxList() {
    final signals = FluxRegistry.all;
    if (signals.isEmpty) return _buildEmpty("No active fluxes");

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: signals.length,
      itemBuilder: (context, index) {
        final signal = signals[index];
        final isComputed = signal is FluxComputed;
        return _buildItemWrapper(
          title: signal.label ?? "Flux #${signal.id.substring(0, 5)}",
          subtitle: "ID: ${signal.id} | Subs: ${signal.subscribers.length}",
          value: signal.toString(),
          badge: isComputed ? "COMPUTED" : "SIGNAL",
          badgeColor: isComputed ? Colors.purple : Colors.blue,
        );
      },
    );
  }

  Widget _buildDIList() {
    final registry = FluxyDI.activeRegistry;
    if (registry.isEmpty) return _buildEmpty("DI Registry is empty");

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: registry.length,
      itemBuilder: (context, index) {
        final key = registry.keys.elementAt(index);
        final data = registry[key]!;
        final scope = data['scope'] as String;
        
        return _buildItemWrapper(
          title: key,
          subtitle: "Scope: ${scope.toUpperCase()} | Tag: ${data['tag'] ?? 'None'}",
          value: data['type'],
          badge: data['isInitialized'] ? "ACTIVE" : "LAZY",
          badgeColor: data['isInitialized'] ? Colors.green : Colors.orange,
        );
      },
    );
  }

  Widget _buildNetworkList() {
    final history = FluxyHttp.history;
    if (history.isEmpty) return _buildEmpty("No network activity");

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final log = history[index];
        final isError = log.statusCode >= 400;
        
        return _buildItemWrapper(
          title: "${log.method} ${log.url}",
          subtitle: "${log.duration.inMilliseconds}ms | ${log.timestamp.toString().split(' ').last.split('.').first}",
          value: "Status: ${log.statusCode}",
          badge: log.statusCode.toString(),
          badgeColor: isError ? Colors.red : Colors.green,
          onTap: () => _showNetworkDetail(log),
        );
      },
    );
  }

  void _showNetworkDetail(FxNetworkLog log) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Request Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              _buildDetailRow("URL", log.url),
              _buildDetailRow("Method", log.method),
              _buildDetailRow("Status", log.statusCode.toString()),
              _buildDetailRow("Duration", "${log.duration.inMilliseconds}ms"),
              const SizedBox(height: 16),
              const Text("Request Body", style: TextStyle(color: Colors.white54, fontSize: 12)),
              _buildCodeBlock(log.requestBody?.toString() ?? "Empty"),
              const SizedBox(height: 16),
              const Text("Response Body", style: TextStyle(color: Colors.white54, fontSize: 12)),
              _buildCodeBlock(log.responseBody?.toString() ?? "Empty"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    if (_logs.isEmpty) return _buildEmpty("Timeline is quiet...");
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _logs.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          _logs[index],
          style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontFamily: 'monospace'),
        ),
      ),
    );
  }

  Widget _buildItemWrapper({
    required String title,
    required String subtitle,
    required String value,
    required String badge,
    required Color badgeColor,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text(badge, style: TextStyle(color: badgeColor, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 11)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
              child: Text(value, style: const TextStyle(color: Color(0xFF10B981), fontSize: 12, fontFamily: 'monospace')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12))),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildCodeBlock(String code) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(10)),
      child: Text(code, style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontFamily: 'monospace')),
    );
  }

  Widget _buildEmpty(String message) {
    return Center(child: Text(message, style: const TextStyle(color: Colors.white24)));
  }
}
