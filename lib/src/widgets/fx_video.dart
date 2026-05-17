import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../dsl/fx.dart';

/// The easiest Video Player for Fluxy.
/// Automatically handles initialization, playback, and disposal.
class FxVideo extends StatefulWidget {
  final String url;
  final bool autoPlay;
  final bool loop;
  final bool isMuted;
  final double? videoWidth;
  final double? videoHeight;
  final double? aspectRatio;
  final String? poster; // Thumbnail image
  final bool showControls;
  final Widget? overlay; // Custom content on top
  final VoidCallback? onPlay;
  final VoidCallback? onPause;
  final VoidCallback? onFinished;
  final BoxFit fit;
  final double radius;

  const FxVideo({
    super.key,
    required this.url,
    this.autoPlay = true,
    this.loop = true,
    this.isMuted = true,
    this.videoWidth,
    this.videoHeight,
    this.aspectRatio,
    this.poster,
    this.showControls = false,
    this.overlay,
    this.onPlay,
    this.onPause,
    this.onFinished,
    this.fit = BoxFit.cover,
    this.radius = 0,
  });

  @override
  State<FxVideo> createState() => _FxVideoState();
}

class _FxVideoState extends State<FxVideo> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _isHovering = false;
  bool _showPoster = true;

  @override
  void initState() {
    super.initState();
    final isNetwork = widget.url.startsWith('http');
    
    _controller = isNetwork 
        ? VideoPlayerController.networkUrl(Uri.parse(widget.url))
        : VideoPlayerController.asset(widget.url);

    _controller.initialize().then((_) {
      if (!mounted) return;
      
      _controller.setVolume(widget.isMuted ? 0 : 1);
      _controller.setLooping(widget.loop);
      
      _controller.addListener(() {
        if (_controller.value.position >= _controller.value.duration && !widget.loop) {
          widget.onFinished?.call();
        }
        if (_controller.value.isPlaying && _showPoster) {
          setState(() => _showPoster = false);
        }
      });

      setState(() => _initialized = true);
      
      if (widget.autoPlay) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _controller.play();
            widget.onPlay?.call();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_controller.value.isPlaying) {
      _controller.pause();
      widget.onPause?.call();
    } else {
      _controller.play();
      widget.onPlay?.call();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Fx.box(
        onTap: _togglePlay,
        style: FxStyle(
          width: widget.videoWidth,
          height: widget.videoHeight,
          borderRadius: BorderRadius.circular(widget.radius),
          clipBehavior: Clip.antiAlias,
          cursor: SystemMouseCursors.click,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. THE VIDEO
            if (_initialized)
              AspectRatio(
                aspectRatio: widget.aspectRatio ?? _controller.value.aspectRatio,
                child: FittedBox(
                  fit: widget.fit,
                  clipBehavior: Clip.hardEdge,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              )
            else
              Fx.center(child: const CircularProgressIndicator(strokeWidth: 2)),

            // 2. POSTER IMAGE
            if (widget.poster != null && _showPoster)
              Positioned.fill(
                child: Fx.image(widget.poster!, fit: widget.fit),
              ),

            // 3. CUSTOM OVERLAY
            if (widget.overlay != null)
              Positioned.fill(child: widget.overlay!),

            // 4. SUPREME CONTROLS
            if (widget.showControls && _initialized)
              AnimatedOpacity(
                opacity: _isHovering || !_controller.value.isPlaying ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      _controller.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 64,
                    ),
                  ),
                ),
              ),

            // 5. PROGRESS LINE (Apple Style)
            if (widget.showControls && _initialized)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                    playedColor: Fx.primary,
                    bufferedColor: Colors.white24,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
