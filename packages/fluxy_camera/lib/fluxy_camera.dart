import 'dart:async';
import 'package:camera/camera.dart' as cam;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FLUXY CAMERA PLUGIN  v3
// Architecture: FluxyPlugin + ChangeNotifier
//   - Plugin manages hardware lifecycle (open/close/capture/control)
//   - ChangeNotifier drives all UI rebuilds (no flux signals in plugin)
//   - UI widget is a clean StatefulWidget with ListenableBuilder
// ─────────────────────────────────────────────────────────────────────────────

class FluxyCameraPlugin extends FluxyPlugin with ChangeNotifier {
  @override
  String get name => 'fluxy_camera';

  @override
  List<String> get permissions => ['camera', 'microphone'];

  // ── Internal State ──────────────────────────────────────────────────────────
  List<cam.CameraDescription> _cameras = [];
  cam.CameraController?       _controller;
  cam.FlashMode               _flashMode     = cam.FlashMode.off;
  cam.XFile?                  _lastImage;
  Uint8List?                  _thumbnailBytes;
  double                      _zoomLevel     = 1.0;
  double                      _minZoom       = 1.0;
  double                      _maxZoom       = 8.0;
  double                      _exposureOffset = 0.0;
  Offset?                     _focusPoint;
  bool                        _isOpen        = false;
  bool                        _isCapturing   = false;
  bool                        _isScanning    = false;
  int                         _activeCamIdx  = 0;
  int                         _consumerCount = 0;
  Timer?                      _focusTimer;
  Completer<void>?            _discoveryDone;

  // ── Public Getters ──────────────────────────────────────────────────────────
  List<cam.CameraDescription> get cameras        => _cameras;
  cam.CameraController?       get controller     => _controller;
  cam.FlashMode               get flashMode      => _flashMode;
  cam.XFile?                  get lastImage      => _lastImage;
  Uint8List?                  get thumbnailBytes => _thumbnailBytes;
  double                      get zoomLevel      => _zoomLevel;
  double                      get minZoom        => _minZoom;
  double                      get maxZoom        => _maxZoom;
  double                      get exposureOffset => _exposureOffset;
  Offset?                     get focusPoint     => _focusPoint;
  bool                        get isOpen         => _isOpen;
  bool                        get isCapturing    => _isCapturing;
  bool                        get isScanning     => _isScanning;
  int                         get activeCamIdx   => _activeCamIdx;

  // ── Plugin Lifecycle ─────────────────────────────────────────────────────────

  @override
  FutureOr<void> onRegister() async {
    _discoveryDone = Completer<void>();
    try {
      _cameras = await cam.availableCameras();
      debugPrint('[IO] [CAM] Found ${_cameras.length} hardware module(s).');
    } catch (e) {
      debugPrint('[IO] [CAM] [FATAL] Hardware discovery failed | Error: $e');
    } finally {
      _discoveryDone!.complete();
    }
  }

  @override
  FutureOr<void> onDispose() async {
    _focusTimer?.cancel();
    final ctrl = _controller;
    _controller = null;
    _isOpen = false;
    try { await ctrl?.dispose(); } catch (_) {}
  }

  // ── Resource Management (Reference-Counted) ──────────────────────────────────

  /// Call from initState. Opens hardware on first consumer.
  Future<void> open({
    int cameraIndex = 0,
    cam.ResolutionPreset resolution = cam.ResolutionPreset.high,
  }) async {
    _consumerCount++;

    // If already streaming, nothing to do
    if (_isOpen && _controller != null) return;

    // Wait for camera list if discovery is still in progress
    if (_discoveryDone != null && !_discoveryDone!.isCompleted) {
      await _discoveryDone!.future;
    }

    // Fallback discovery if plugin was never registered
    if (_cameras.isEmpty) {
      try { _cameras = await cam.availableCameras(); } catch (_) {}
    }

    if (_cameras.isEmpty) {
      debugPrint('[IO] [CAM] [ERROR] No optical hardware detected.');
      return;
    }

    final idx = cameraIndex.clamp(0, _cameras.length - 1);
    _activeCamIdx = idx;
    await _initController(idx, resolution: resolution);
  }

  /// Call from dispose. Releases hardware when last consumer exits.
  Future<void> close() async {
    _consumerCount = (_consumerCount - 1).clamp(0, 999);
    if (_consumerCount == 0) await _releaseController();
  }

  /// Force-release (e.g. app paused).
  Future<void> forceClose() async {
    _consumerCount = 0;
    await _releaseController();
  }

  // ── Controls ────────────────────────────────────────────────────────────────

  Future<void> flip() async {
    if (_cameras.length < 2) return;
    FxHaptic.light();
    final next = (_activeCamIdx + 1) % _cameras.length;
    _activeCamIdx = next;
    await _initController(next);
  }

  Future<void> setFlash(cam.FlashMode mode) async {
    if (_controller == null || !_isOpen) return;
    try {
      await _controller!.setFlashMode(mode);
      _flashMode = mode;
      notifyListeners();
    } catch (_) {}
  }

  void cycleFlash() {
    const modes = cam.FlashMode.values;
    setFlash(modes[(_flashMode.index + 1) % modes.length]);
  }

  Future<void> setZoom(double level) async {
    if (_controller == null || !_isOpen) return;
    try {
      final clamped = level.clamp(_minZoom, _maxZoom);
      await _controller!.setZoomLevel(clamped);
      _zoomLevel = clamped;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> applyZoomScale(double scale, double baseZoom) =>
      setZoom(baseZoom * scale);

  Future<void> focus(Offset normalized) async {
    if (_controller == null || !_isOpen) return;
    try {
      await _controller!.setFocusPoint(normalized);
      _focusPoint = normalized;
      notifyListeners();
      _focusTimer?.cancel();
      _focusTimer = Timer(const Duration(seconds: 2), () {
        _focusPoint = null;
        notifyListeners();
      });
    } catch (_) {}
  }

  Future<void> setExposure(double offset) async {
    if (_controller == null || !_isOpen) return;
    try {
      await _controller!.setExposureOffset(offset);
      _exposureOffset = offset;
      notifyListeners();
    } catch (_) {}
  }

  void toggleScanning() {
    _isScanning = !_isScanning;
    notifyListeners();
  }

  // ── Capture ──────────────────────────────────────────────────────────────────

  Future<cam.XFile?> capture() async {
    if (_controller == null || !_isOpen) return null;
    if (_controller!.value.isTakingPicture || _isCapturing) return null;

    _isCapturing = true;
    notifyListeners();
    FxHaptic.medium();

    try {
      await Future.delayed(const Duration(milliseconds: 80));
      final file = await _controller!.takePicture();
      _lastImage = file;
      _isCapturing = false;
      notifyListeners();

      // Non-blocking thumbnail load
      unawaited(_loadThumbnail(file));
      return file;
    } catch (e) {
      debugPrint('[IO] [CAM] [ERROR] Capture pipeline interruption | Error: $e');
      _isCapturing = false;
      notifyListeners();
      return null;
    }
  }

  // ── Widget Builders ──────────────────────────────────────────────────────────

  /// Bare reactive preview. Works standalone in any widget tree.
  Widget preview() => _CameraPreviewWidget(plugin: this);

  /// Full Zen Camera UI — one line, complete experience.
  Widget fullView({
    VoidCallback? onGalleryTap,
    Function(cam.XFile)? onCaptured,
  }) =>
      _FluxyCameraFullView(
        plugin: this,
        onGalleryTap: onGalleryTap,
        onCaptured: onCaptured,
      );

  // ── Private ──────────────────────────────────────────────────────────────────

  Future<void> _initController(
    int index, {
    cam.ResolutionPreset resolution = cam.ResolutionPreset.high,
  }) async {
    // Mark closed so UI shows loading immediately
    _isOpen = false;
    notifyListeners();

    // Dispose old with a settle delay to avoid Android camera2 crash
    final old = _controller;
    _controller = null;
    if (old != null) {
      try { await old.dispose(); } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 200));
    }

    final desc = _cameras[index];
    final ctrl = cam.CameraController(
      desc,
      resolution,
      enableAudio: false,
      imageFormatGroup: cam.ImageFormatGroup.jpeg,
    );
    _controller = ctrl;

    try {
      await ctrl.initialize();
      _minZoom = await ctrl.getMinZoomLevel();
      _maxZoom = await ctrl.getMaxZoomLevel();
      _zoomLevel = 1.0;
      _exposureOffset = 0.0;
      try { await ctrl.setFlashMode(_flashMode); } catch (_) {}
      _isOpen = true;
      debugPrint('[IO] [CAM] [READY] ${desc.lensDirection.name.toUpperCase()} optical stage active.');
    } catch (e) {
      _isOpen = false;
      debugPrint('[IO] [CAM] [FATAL] Stage initialization failed | Error: $e');
    }

    notifyListeners();
  }

  Future<void> _releaseController() async {
    _isOpen = false;
    _focusTimer?.cancel();
    final ctrl = _controller;
    _controller = null;
    notifyListeners();
    try { await ctrl?.dispose(); } catch (_) {}
    debugPrint('[IO] [CAM] Optical hardware released.');
  }

  Future<void> _loadThumbnail(cam.XFile file) async {
    try {
      _thumbnailBytes = await file.readAsBytes();
      notifyListeners();
    } catch (_) {}
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PREVIEW WIDGET
// A clean StatefulWidget. Listens to plugin via ListenableBuilder.
// ─────────────────────────────────────────────────────────────────────────────

class _CameraPreviewWidget extends StatelessWidget {
  final FluxyCameraPlugin plugin;
  const _CameraPreviewWidget({required this.plugin});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: plugin,
      builder: (context, _) {
        final ctrl = plugin.controller;

        if (!plugin.isOpen || ctrl == null) {
          return const _CameraLoadingWidget();
        }

        return ValueListenableBuilder<cam.CameraValue>(
          valueListenable: ctrl,
          builder: (context, value, _) {
            if (!value.isInitialized) return const _CameraLoadingWidget();
            if (value.hasError) {
              return _CameraErrorWidget(message: value.errorDescription);
            }

            final pvSize = value.previewSize;
            if (pvSize == null) return const _CameraLoadingWidget();

            // Android returns landscape previewSize — swap for portrait fill
            return SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: pvSize.height,
                  height: pvSize.width,
                  child: cam.CameraPreview(ctrl),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FULL ZEN CAMERA UI
// ─────────────────────────────────────────────────────────────────────────────

class _FluxyCameraFullView extends StatefulWidget {
  final FluxyCameraPlugin plugin;
  final VoidCallback? onGalleryTap;
  final Function(cam.XFile)? onCaptured;

  const _FluxyCameraFullView({
    required this.plugin,
    this.onGalleryTap,
    this.onCaptured,
  });

  @override
  State<_FluxyCameraFullView> createState() => _FluxyCameraFullViewState();
}

class _FluxyCameraFullViewState extends State<_FluxyCameraFullView>
    with WidgetsBindingObserver {
  double _baseZoom = 1.0;
  bool   _showGrid = false;

  FluxyCameraPlugin get p => widget.plugin;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    p.open(); // acquire reference
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    p.close(); // release reference
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      p.forceClose();
    } else if (state == AppLifecycleState.resumed) {
      p.open(cameraIndex: p.activeCamIdx);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: ListenableBuilder(
        listenable: p,
        builder: (context, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // ① Preview + Gestures
              GestureDetector(
                onScaleStart: (_) => _baseZoom = p.zoomLevel,
                onScaleUpdate: (d) => p.applyZoomScale(d.scale, _baseZoom),
                onTapDown: (d) {
                  final nx = (d.localPosition.dx / size.width).clamp(0.05, 0.95);
                  final ny = (d.localPosition.dy / size.height).clamp(0.05, 0.95);
                  p.focus(Offset(nx, ny));
                },
                child: p.preview(),
              ),

              // ② Rule-of-Thirds Grid
              if (_showGrid)
                IgnorePointer(child: CustomPaint(painter: _GridPainter(), size: size)),

              // ③ Scanning Overlay
              if (p.isScanning)
                const IgnorePointer(child: _ScanOverlay()),

              // ④ Focus Ring
              if (p.focusPoint != null)
                Positioned(
                  left: p.focusPoint!.dx * size.width - 28,
                  top:  p.focusPoint!.dy * size.height - 28,
                  child: const IgnorePointer(child: _FocusRing()),
                ),

              // ⑤ Shutter flash
              if (p.isCapturing)
                IgnorePointer(
                  child: Container(
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),

              // ⑥ Top Bar
              Positioned(
                top: 0, left: 0, right: 0,
                child: SafeArea(
                  child: _TopBar(
                    plugin: p,
                    flashIcon: _flashIcon(p.flashMode),
                    flashLabel: _flashLabel(p.flashMode),
                  ),
                ),
              ),

              // ⑦ Bottom Controls
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: SafeArea(
                  child: _BottomControls(
                    plugin: p,
                    showGrid: _showGrid,
                    onToggleGrid: () => setState(() => _showGrid = !_showGrid),
                    onCaptured: widget.onCaptured,
                    onGalleryTap: widget.onGalleryTap,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static IconData _flashIcon(cam.FlashMode m) => switch (m) {
    cam.FlashMode.off    => Icons.flash_off_rounded,
    cam.FlashMode.auto   => Icons.flash_auto_rounded,
    cam.FlashMode.always => Icons.flash_on_rounded,
    cam.FlashMode.torch  => Icons.flashlight_on_rounded,
  };

  static String _flashLabel(cam.FlashMode m) => switch (m) {
    cam.FlashMode.off    => 'OFF',
    cam.FlashMode.auto   => 'AUTO',
    cam.FlashMode.always => 'ON',
    cam.FlashMode.torch  => 'TORCH',
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// SUB-COMPONENTS
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final FluxyCameraPlugin plugin;
  final IconData flashIcon;
  final String   flashLabel;

  const _TopBar({required this.plugin, required this.flashIcon, required this.flashLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.72), Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _IconLabel(
            icon: flashIcon,
            label: flashLabel,
            active: plugin.flashMode != cam.FlashMode.off,
            onTap: plugin.cycleFlash,
          ),
          Text(
            plugin.isScanning ? 'SCANNER' : 'CAMERA',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 3.5,
            ),
          ),
          _IconLabel(
            icon: Icons.document_scanner_rounded,
            label: 'SCAN',
            active: plugin.isScanning,
            onTap: plugin.toggleScanning,
          ),
        ],
      ),
    );
  }
}

class _BottomControls extends StatelessWidget {
  final FluxyCameraPlugin plugin;
  final bool showGrid;
  final VoidCallback onToggleGrid;
  final Function(cam.XFile)? onCaptured;
  final VoidCallback? onGalleryTap;

  const _BottomControls({
    required this.plugin,
    required this.showGrid,
    required this.onToggleGrid,
    this.onCaptured,
    this.onGalleryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withValues(alpha: 0.75), Colors.transparent],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Zoom pills
          _ZoomPills(plugin: plugin),
          const SizedBox(height: 24),

          // Main row: gallery | shutter | flip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _GalleryThumb(bytes: plugin.thumbnailBytes, onTap: onGalleryTap),
              _ShutterButton(
                capturing: plugin.isCapturing,
                scanning: plugin.isScanning,
                onTap: () async {
                  final file = await plugin.capture();
                  if (file != null) {
                    onCaptured?.call(file);
                    FxOverlay.showToast('Saved!', type: FxToastType.success);
                  }
                },
              ),
              _CircleIcon(icon: Icons.flip_camera_ios_rounded, onTap: plugin.flip),
            ],
          ),
          const SizedBox(height: 16),

          // Grid toggle pill
          GestureDetector(
            onTap: onToggleGrid,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: showGrid ? Colors.amber.withValues(alpha: 0.15) : Colors.white10,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: showGrid ? Colors.amber : Colors.white24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(showGrid ? Icons.grid_on : Icons.grid_off,
                      color: showGrid ? Colors.amber : Colors.white38, size: 13),
                  const SizedBox(width: 6),
                  Text('Grid',
                      style: TextStyle(
                          color: showGrid ? Colors.amber : Colors.white38,
                          fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _IconLabel({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.amber : Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 9, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 54, height: 54,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white10,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}

class _ShutterButton extends StatelessWidget {
  final bool capturing, scanning;
  final VoidCallback onTap;
  const _ShutterButton({required this.capturing, required this.scanning, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: capturing ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: capturing ? 70 : 78, height: capturing ? 70 : 78,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3.5),
        ),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: capturing ? 50 : 62, height: capturing ? 50 : 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scanning ? Colors.blue : Colors.white,
            ),
            child: capturing
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black45),
                  )
                : scanning
                    ? const Icon(Icons.qr_code_scanner, color: Colors.white, size: 26)
                    : null,
          ),
        ),
      ),
    );
  }
}

class _ZoomPills extends StatelessWidget {
  final FluxyCameraPlugin plugin;
  const _ZoomPills({required this.plugin});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [1.0, 2.0, 5.0].map((z) {
        final active = (plugin.zoomLevel - z).abs() < 0.4;
        return GestureDetector(
          onTap: () => plugin.setZoom(z),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
            decoration: BoxDecoration(
              color: active ? Colors.white : Colors.white10,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: active ? Colors.transparent : Colors.white24),
            ),
            child: Text('${z.toStringAsFixed(0)}×',
                style: TextStyle(
                    color: active ? Colors.black : Colors.white54,
                    fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        );
      }).toList(),
    );
  }
}

class _GalleryThumb extends StatelessWidget {
  final Uint8List? bytes;
  final VoidCallback? onTap;
  const _GalleryThumb({this.bytes, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 54, height: 54,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white30, width: 1.5),
          color: Colors.white10,
        ),
        child: bytes != null
            ? Image.memory(bytes!, fit: BoxFit.cover)
            : const Icon(Icons.photo_library_outlined, color: Colors.white38, size: 22),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OVERLAYS
// ─────────────────────────────────────────────────────────────────────────────

class _CameraLoadingWidget extends StatelessWidget {
  const _CameraLoadingWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          CircularProgressIndicator(color: Colors.white24, strokeWidth: 2),
          SizedBox(height: 14),
          Text('Opening camera…',
              style: TextStyle(color: Colors.white38, fontSize: 13)),
        ]),
      ),
    );
  }
}

class _CameraErrorWidget extends StatelessWidget {
  final String? message;
  const _CameraErrorWidget({this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.no_photography_outlined, color: Colors.red, size: 38),
          const SizedBox(height: 10),
          Text(message ?? 'Camera unavailable',
              style: const TextStyle(color: Colors.white54, fontSize: 13)),
        ]),
      ),
    );
  }
}

// Focus ring — spring-in + fade
class _FocusRing extends StatefulWidget {
  const _FocusRing();

  @override
  State<_FocusRing> createState() => _FocusRingState();
}

class _FocusRingState extends State<_FocusRing> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale, _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _scale = Tween<double>(begin: 1.5, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _opacity = Tween<double>(begin: 1.0, end: 0.5).animate(_ctrl);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Opacity(
        opacity: _opacity.value,
        child: Transform.scale(
          scale: _scale.value,
          child: Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.amber, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: SizedBox(
                width: 4, height: 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Scanning overlay with laser
class _ScanOverlay extends StatefulWidget {
  const _ScanOverlay();

  @override
  State<_ScanOverlay> createState() => _ScanOverlayState();
}

class _ScanOverlayState extends State<_ScanOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    const boxSize = 260.0;
    final bL = (size.width - boxSize) / 2;
    final bT = (size.height - boxSize) / 2;

    return Stack(children: [
      // Dark vignette using BlendMode
      ColorFiltered(
        colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.55), BlendMode.srcOut),
        child: Stack(children: [
          Container(decoration: const BoxDecoration(color: Colors.black, backgroundBlendMode: BlendMode.dstOut)),
          Positioned(
            left: bL, top: bT,
            child: Container(
              width: boxSize, height: boxSize,
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ]),
      ),

      // Corner brackets
      Positioned(
        left: bL, top: bT,
        child: CustomPaint(size: const Size(boxSize, boxSize), painter: _CornerPainter()),
      ),

      // Laser
      AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Positioned(
          left: bL + 10,
          top: bT + 10 + (_ctrl.value * (boxSize - 20)),
          child: Container(
            width: boxSize - 20, height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.transparent, Colors.blue.shade300, Colors.transparent
              ]),
              boxShadow: [
                BoxShadow(color: Colors.blue.withValues(alpha: 0.6), blurRadius: 10),
              ],
            ),
          ),
        ),
      ),

      Positioned(
        bottom: size.height / 2 - boxSize / 2 - 48,
        left: 0, right: 0,
        child: const Center(
          child: Text('Align within frame',
              style: TextStyle(color: Colors.white60, fontSize: 12, letterSpacing: 0.8)),
        ),
      ),
    ]);
  }
}

// Rule-of-thirds grid
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white.withValues(alpha: 0.22)..strokeWidth = 0.8;
    canvas.drawLine(Offset(size.width / 3, 0), Offset(size.width / 3, size.height), p);
    canvas.drawLine(Offset(size.width * 2 / 3, 0), Offset(size.width * 2 / 3, size.height), p);
    canvas.drawLine(Offset(0, size.height / 3), Offset(size.width, size.height / 3), p);
    canvas.drawLine(Offset(0, size.height * 2 / 3), Offset(size.width, size.height * 2 / 3), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Corner bracket painter for scanner
class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const len = 22.0;
    const r = 14.0;
    // TL
    canvas.drawLine(const Offset(r, 0), const Offset(r + len, 0), p);
    canvas.drawLine(const Offset(0, r), const Offset(0, r + len), p);
    // TR
    canvas.drawLine(Offset(s.width - r - len, 0), Offset(s.width - r, 0), p);
    canvas.drawLine(Offset(s.width, r), Offset(s.width, r + len), p);
    // BL
    canvas.drawLine(Offset(r, s.height), Offset(r + len, s.height), p);
    canvas.drawLine(Offset(0, s.height - r - len), Offset(0, s.height - r), p);
    // BR
    canvas.drawLine(Offset(s.width - r - len, s.height), Offset(s.width - r, s.height), p);
    canvas.drawLine(Offset(s.width, s.height - r - len), Offset(s.width, s.height - r), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
