import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'dart:ui';
import 'dart:convert';
import '../reactive/signal.dart';
import '../di/fluxy_di.dart';
import '../networking/fluxy_http.dart';

/// The Fluxy Debug Inspector & DevTools (Premium Version).
/// Provides real-time visibility into Fluxes, DI Registry, and Network.
class FluxyDevTools extends StatefulWidget {
  final Widget child;

  const FluxyDevTools({super.key, required this.child});

  @override
  State<FluxyDevTools> createState() => _FluxyDevToolsState();
}

class _FluxyDevToolsState extends State<FluxyDevTools> {
  final List<String> _logs = [];
  bool _isOpen = false;
  Widget? _activeDialog;
  Timer? _refreshTimer;
  int _activeTab = 0;
  final _rebuildNotifier = ValueNotifier<int>(0);
  double _fps = 60.0;
  
  // Select Mode State
  Offset _fabOffset = const Offset(20, 80); // Increased bottom offset to avoid NavBars
  
  // Search & Filter State
  String _fluxSearchQuery = "";
  String _diSearchQuery = "";
  String _networkSearchQuery = "";
  
  // Track last changed signal for flashing effect
  String? _lastChangedSignalId;
  Timer? _flashTimer;
  
  // DevTools internal state
  final GlobalKey<ScaffoldMessengerState> _messengerKey = GlobalKey<ScaffoldMessengerState>();
  String _timelineSearchQuery = "";
  bool _isTimelinePaused = false;
  bool _isAutoRefreshEnabled = true;

  void _showSnackBar(String message, {bool isError = false}) {
    _messengerKey.currentState?.clearSnackBars();
    _messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white, fontSize: 12)),
        backgroundColor: isError ? Colors.redAccent.withValues(alpha: 0.9) : const Color(0xFF1E293B).withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 160), // Adjusted to stay above new FAB position
      ),
    );
  }

  String _prettifyJson(dynamic body) {
    if (body == null || body == "") return "Empty";
    try {
      if (body is String) {
        final decoded = jsonDecode(body);
        return const JsonEncoder.withIndent('  ').convert(decoded);
      }
      return const JsonEncoder.withIndent('  ').convert(body);
    } catch (_) {
      return body.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    _setupTimeline();
    WidgetsBinding.instance.addTimingsCallback(_onTimings);
  }

  // Helper to trigger a rebuild of the overlay content
  @override
  void setState(VoidCallback fn) {
    fn();
    if (mounted) _rebuildNotifier.value++;
  }
  
  // Also keep a _rebuild alias if used elsewhere
  void _rebuild([VoidCallback? fn]) {
    if (fn != null) fn();
    if (mounted) _rebuildNotifier.value++;
  }

  // ... (setState, _rebuild, _onTimings, _setupTimeline, dispose) ...
  // The original content had a comment here, implying these methods exist elsewhere.
  // For the purpose of this edit, I'm assuming _onTimings, _setupTimeline, dispose
  // and other methods like _toggleOpen, _buildPanelHeader, _buildTabBar, _buildTabContent
  // are defined later in the class, as they are referenced.
  // The provided snippet also had a partial `_onTimings` and then `@override Widget build`.
  // I'm correcting this to assume `_onTimings` is a full method and `build` follows.

  void _onTimings(List<FrameTiming> timings) {
    if (timings.isEmpty) return;
    
    // Average last few frames
    double totalDuration = 0;
    for (var timing in timings) {
      totalDuration += timing.totalSpan.inMilliseconds;
    }
    final avgDuration = totalDuration / timings.length;
    
    final newFps = 1000 / (avgDuration > 0 ? avgDuration : 16.6);
    
    // Only update if change is significant to avoid UI spam
    if ((newFps - _fps).abs() > 2) {
      if (mounted) {
         _rebuild(() {
           _fps = newFps.clamp(0.0, 60.0);
         });
      }
    }
  }

  void _setupTimeline() {
    FluxyReactiveContext.onFluxUpdate = (flux, value) {
      if (mounted) {
        final f = flux as Flux;
        // Schedule the update
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _rebuild(() {
              if (_isTimelinePaused) return;

              _lastChangedSignalId = f.id;
              _flashTimer?.cancel();
              _flashTimer = Timer(const Duration(milliseconds: 500), () {
                if (mounted) setState(() => _lastChangedSignalId = null);
              });

              final timestamp = DateTime.now().toString().split(' ').last.split('.').first;
              _logs.insert(0, "[$timestamp] [UPDATE] ${f.label ?? f.id.substring(0, 8)} -> $value");
              if (_logs.length > 200) _logs.removeLast();
            });
          }
        });
      }
    };
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeTimingsCallback(_onTimings);
    _refreshTimer?.cancel();
    _rebuildNotifier.dispose();
    super.dispose();
  }

  void _toggleOpen() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        if (_isAutoRefreshEnabled) {
          _refreshTimer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
            if (mounted) _rebuild();
          });
        }
      } else {
        _activeDialog = null;
        _refreshTimer?.cancel();
      }
    });
  }



  // Update build to include selection layer
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Theme(
        data: ThemeData.dark(useMaterial3: true).copyWith(
          scaffoldBackgroundColor: Colors.transparent,
          colorScheme: const ColorScheme.dark(primary: Colors.blue),
        ),
        child: Localizations(
          locale: const Locale('en', 'US'),
          delegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          child: ScaffoldMessenger(
            key: _messengerKey,
            child: Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (context) => ValueListenableBuilder<int>(
                  valueListenable: _rebuildNotifier,
                  child: widget.child, 
                  builder: (context, _, child) {
                    return Stack(
                      children: [
                        child!,
                        


                        if (_isOpen) ...[
                          _buildBlurBackground(),
                          _buildPanel(),
                        ],
                        if (_activeDialog != null) _buildDialogOverlay(),
                        _buildFab(),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
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

  Widget _buildDialogOverlay() {
    return Positioned.fill(
      child: Stack(
        children: [
          // Barrier
          GestureDetector(
            onTap: () => setState(() => _activeDialog = null),
            child: Container(color: Colors.black54),
          ),
          // Dialog Content
          Center(
             child: Material(
               color: Colors.transparent,
               child: _activeDialog,
             ),
          ),
        ],
      ),
    );
  }

  Widget _buildFab() {
    return Positioned(
      right: _fabOffset.dx,
      bottom: _fabOffset.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          _rebuild(() {
            _fabOffset = Offset(
              (_fabOffset.dx - details.delta.dx).clamp(10, 400),
              (_fabOffset.dy - details.delta.dy).clamp(10, 800),
            );
          });
        },
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
      ),
    );
  }

  Widget _buildPanel() {
    return Positioned(
      bottom: 90,
      right: 20,
      left: 20,
      top: 100,
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.85), // Higher transparency for glass effect
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 40,
                offset: const Offset(0, 24),
              ),
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.05),
                blurRadius: 20,
                spreadRadius: -10,
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  children: [
                    _buildPanelHeader(),
                    _buildTabBar(),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.02),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: KeyedSubtree(
                          key: ValueKey<int>(_activeTab),
                          child: _buildTabContent(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPanelHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.bolt_rounded, color: Color(0xFF3B82F6), size: 18),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Fluxy Inspector",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white, 
                          fontWeight: FontWeight.w700, 
                          fontSize: 15,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Row(
                        children: [
                          const Text(
                            "v0.2.2",
                            style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 8),
                      // FPS Display
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: (_fps > 50 ? Colors.green : (_fps > 30 ? Colors.orange : Colors.red)).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.speed_rounded, 
                              size: 8, 
                              color: _fps > 50 ? Colors.greenAccent : (_fps > 30 ? Colors.orangeAccent : Colors.redAccent)
                            ),
                            const SizedBox(width: 3),
                            Text(
                              "${_fps.toStringAsFixed(0)} FPS", 
                              style: TextStyle(
                                color: _fps > 50 ? Colors.greenAccent : (_fps > 30 ? Colors.orangeAccent : Colors.redAccent),
                                fontSize: 9, 
                                fontWeight: FontWeight.bold,
                                fontFamily: "monospace"
                              )
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                        child: const Text("LIVE", style: TextStyle(color: Colors.greenAccent, fontSize: 8, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
          Row(
            children: [
              IconButton(
                onPressed: () => _showHelpDialog(),
                icon: const Icon(Icons.help_outline_rounded, color: Colors.white38, size: 20),
                tooltip: "What is this?",
              ),
              IconButton(
                onPressed: () => setState(() => _logs.clear()),
                icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white38, size: 20),
                tooltip: "Clear Logs",
              ),
              IconButton(
                onPressed: _toggleOpen,
                icon: const Icon(Icons.close_rounded, color: Colors.white38, size: 20),
                tooltip: "Close DevTools",
              ),
            ],
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
    final signals = FluxRegistry.all.where((s) {
      if (_fluxSearchQuery.isEmpty) return true;
      final query = _fluxSearchQuery.toLowerCase();
      final label = s.label?.toLowerCase() ?? "";
      return label.contains(query) || s.id.contains(query);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: TextField(
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(
                hintText: "Search Fluxes or Tags...",
                hintStyle: TextStyle(color: Colors.white24),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search_rounded, color: Colors.blueAccent, size: 20),
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (val) => setState(() => _fluxSearchQuery = val),
            ),
          ),
        ),
        Expanded(
          child: signals.isEmpty
              ? _buildEmpty("No matching fluxes found")
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: signals.length,
                  itemBuilder: (context, index) {
                    final signal = signals[index];
                    final isHighlighted = _lastChangedSignalId == signal.id;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isHighlighted 
                            ? Colors.blue.withValues(alpha: 0.15) 
                            : Colors.white.withValues(alpha: 0.02),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isHighlighted 
                              ? Colors.blue.withValues(alpha: 0.4) 
                              : Colors.white.withValues(alpha: 0.05)
                        ),
                      ),
                      child: _buildEditableFluxItem(signal),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEditableFluxItem(Flux signal) {
    final isComputed = signal is FluxComputed;
    final value = signal.toString();
    // Try to infer type for editing
    final dynamic rawValue = (signal as dynamic).value;
    final isBool = rawValue is bool;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      signal.label ?? "Flux #${signal.id.substring(signal.id.length - 6)}",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          "ID: ${signal.id.substring(0, 8)}...",
                          style: const TextStyle(color: Colors.white38, fontSize: 10),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _showConsumerDetail(signal),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.people_alt_rounded, size: 8, color: Colors.blueAccent),
                                const SizedBox(width: 4),
                                Text(
                                  "${signal.subscribers.length} Consumers",
                                  style: const TextStyle(color: Colors.blueAccent, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isComputed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.purple.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                  child: const Text("COMPUTED", style: TextStyle(color: Colors.purpleAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                )
              else if (isBool)
                Transform.scale(
                  scale: 0.7,
                  child: Switch(
                    value: rawValue,
                    onChanged: (val) {
                      (signal as dynamic).value = val;
                      setState(() {});
                    },
                    activeColor: Colors.blue,
                    activeTrackColor: Colors.blue.withValues(alpha: 0.3),
                    inactiveThumbColor: Colors.white24,
                    inactiveTrackColor: Colors.white10,
                  ),
                )
              else
                InkWell(
                  onTap: () => _showEditDialog(signal),
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)),
                     child: const Icon(Icons.edit, size: 14, color: Colors.blue),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(6)),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: isBool ? (rawValue ? Colors.greenAccent : Colors.redAccent) : const Color(0xFF10B981),
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 14, color: Colors.white24),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: value));
                    _showSnackBar("Value copied to clipboard");
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showConsumerDetail(Flux signal) {
    setState(() {
      _activeDialog = AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.analytics_rounded, color: Colors.blue),
            const SizedBox(width: 12),
            const Text("Rebuild Profiler", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Consumers of '${signal.label ?? signal.id}':", style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 16),
            if (signal.consumerNames.isEmpty)
              const Text("No active listeners", style: TextStyle(color: Colors.white38, fontSize: 12))
            else
              ...signal.consumerNames.map((name) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.bolt_rounded, color: Colors.orangeAccent, size: 14),
                    const SizedBox(width: 8),
                    Text(name, style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'monospace')),
                  ],
                ),
              )),
          ],
        ),
        actions: [
          TextButton(onPressed: () => setState(() => _activeDialog = null), child: const Text("Close")),
        ],
      );
    });
  }

  void _showEditDialog(Flux signal) {
    if (signal is FluxComputed) return;
    
    final TextEditingController controller = TextEditingController(text: signal.toString());
    
    setState(() {
      _activeDialog = AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Edit Flux Value", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Enter new value",
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() => _activeDialog = null),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              try {
                final text = controller.text.trim();
                dynamic newValue;
                
                // Smart Parsing
                if (text.toLowerCase() == 'true') newValue = true;
                else if (text.toLowerCase() == 'false') newValue = false;
                else if (int.tryParse(text) != null) newValue = int.parse(text);
                else if (double.tryParse(text) != null) newValue = double.parse(text);
                else if (text.startsWith('[') || text.startsWith('{')) {
                   // Generic attempt for list/map if simple
                   newValue = text; 
                } else newValue = text;
                
                (signal as dynamic).value = newValue;
                _rebuild(() {
                  _activeDialog = null;
                });
              } catch (e) {
                // Silently fail or could add a shaking animation
              }
            },
            child: const Text("Update", style: TextStyle(color: Colors.blue)),
          ),
        ],
      );
    });
  }

  void _showHelpDialog() {
    setState(() {
      _activeDialog = AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.school, color: Colors.blue),
            SizedBox(width: 10),
            Text("DevTools Guide", style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GuideItem(
              icon: Icons.label,
              title: "Labels Matter",
              desc: "Use flux(0, label: 'Count') to give your signals a readable name.",
            ),
            SizedBox(height: 16),
            _GuideItem(
              icon: Icons.edit,
              title: "Live Editing",
              desc: "Tap the pencil icon or toggle switches to update app state in real-time.",
            ),
            SizedBox(height: 16),
            _GuideItem(
              icon: Icons.bolt,
              title: "Computed Flux",
              desc: "Purple badges indicate read-only values derived from other fluxes.",
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() => _activeDialog = null),
            child: const Text("Got it!", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
        ],
      );
    });
  }

  Widget _buildDIList() {
    final registry = FluxyDI.activeRegistry;
    final entries = registry.entries.where((e) {
      if (_diSearchQuery.isEmpty) return true;
      final query = _diSearchQuery.toLowerCase();
      final key = e.key.toLowerCase();
      final type = e.value['type'].toString().toLowerCase();
      return key.contains(query) || type.contains(query);
    }).toList();

    if (registry.isEmpty) return _buildEmpty("DI Registry is empty");

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: TextField(
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(
                hintText: "Search DI Items by key or type...",
                hintStyle: TextStyle(color: Colors.white24),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.hub_rounded, color: Colors.blueAccent, size: 20),
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (val) => setState(() => _diSearchQuery = val),
            ),
          ),
        ),
        Expanded(
          child: entries.isEmpty
              ? _buildEmpty("No DI items found")
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final key = entry.key;
                    final data = entry.value;
                    final scope = data['scope'] as String;
                    
                    return _buildItemWrapper(
                      title: key,
                      subtitle: "Scope: ${scope.toUpperCase()} | Tag: ${data['tag'] ?? 'None'}",
                      value: data['type'],
                      badge: data['isInitialized'] ? "ACTIVE" : "LAZY",
                      badgeColor: data['isInitialized'] ? Colors.green : Colors.orange,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildNetworkList() {
    final history = FluxyHttp.history.where((log) {
      if (_networkSearchQuery.isEmpty) return true;
      final query = _networkSearchQuery.toLowerCase();
      return log.url.toLowerCase().contains(query) || 
             log.statusCode.toString().contains(query) ||
             log.method.toLowerCase().contains(query);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: TextField(
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(
                hintText: "Search URL, Status, or Method...",
                hintStyle: TextStyle(color: Colors.white24),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.wifi_rounded, color: Colors.blueAccent, size: 20),
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (val) => setState(() => _networkSearchQuery = val),
            ),
          ),
        ),
        Expanded(
          child: history.isEmpty 
              ? _buildEmpty("No network activity found")
              : ListView.builder(
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
                ),
        ),
      ],
    );
  }

  void _showNetworkDetail(FxNetworkLog log) {
    setState(() {
      _activeDialog = AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Request Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 16),
                _buildDetailRow("URL", log.url),
                _buildDetailRow("Method", log.method),
                _buildDetailRow("Status", log.statusCode.toString()),
                _buildDetailRow("Duration", "${log.duration.inMilliseconds}ms"),
                const SizedBox(height: 16),
                const Text("Request Body", style: TextStyle(color: Colors.white54, fontSize: 12)),
                _buildCodeBlock(_prettifyJson(log.requestBody)),
                const SizedBox(height: 16),
                const Text("Response Body", style: TextStyle(color: Colors.white54, fontSize: 12)),
                _buildCodeBlock(_prettifyJson(log.responseBody)),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() => _activeDialog = null),
            child: const Text("Close", style: TextStyle(color: Colors.blue)),
          ),
        ],
      );
    });
  }

  Widget _buildTimeline() {
    final filteredLogs = _logs.where((log) {
      if (_timelineSearchQuery.isEmpty) return true;
      return log.toLowerCase().contains(_timelineSearchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    decoration: const InputDecoration(
                      hintText: "Search logs...",
                      hintStyle: TextStyle(color: Colors.white24, fontSize: 12),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search_rounded, color: Colors.blueAccent, size: 16),
                    ),
                    onChanged: (val) => setState(() => _timelineSearchQuery = val),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildIconButton(
                icon: _isTimelinePaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                onPressed: () => setState(() => _isTimelinePaused = !_isTimelinePaused),
                color: _isTimelinePaused ? Colors.greenAccent : Colors.orangeAccent,
                tooltip: _isTimelinePaused ? "Resume" : "Pause",
              ),
              const SizedBox(width: 4),
              _buildIconButton(
                icon: Icons.delete_outline_rounded,
                onPressed: () => setState(() => _logs.clear()),
                color: Colors.redAccent,
                tooltip: "Clear",
              ),
            ],
          ),
        ),
        Expanded(
          child: filteredLogs.isEmpty ? _buildEmpty("Timeline is quiet...") : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredLogs.length,
            itemBuilder: (context, index) {
              final log = filteredLogs[index];
              final isUpdate = log.contains("[UPDATE]");
              final isNetwork = log.contains("[NETWORK]");
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isUpdate ? Icons.refresh_rounded : (isNetwork ? Icons.http_rounded : Icons.info_outline_rounded),
                      size: 14,
                      color: isUpdate ? Colors.blueAccent : (isNetwork ? Colors.purpleAccent : Colors.white38),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        log,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onPressed, required Color color, String? tooltip}) {
    return Tooltip(
      message: tooltip ?? "",
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 16, color: color),
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
      decoration: BoxDecoration(
        color: Colors.black38, 
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Stack(
        children: [
          Text(
            code, 
            style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontFamily: 'monospace')
          ),
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              icon: const Icon(Icons.copy_rounded, size: 14, color: Colors.white24),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                _showSnackBar("Code block copied to clipboard");
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(String message) {
    return Center(child: Text(message, style: const TextStyle(color: Colors.white24)));
  }
}

class _GuideItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _GuideItem({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white54, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}
