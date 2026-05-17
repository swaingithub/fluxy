import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../dsl/fx.dart';

/// The easiest Audio Player for Fluxy.
/// Simple one-liner for background music or sound effects.
class FxAudio extends StatefulWidget {
  final String url;
  final bool autoPlay;
  final bool loop;
  final double volume;
  final Widget? child; // Custom UI if needed

  const FxAudio({
    super.key,
    required this.url,
    this.autoPlay = true,
    this.loop = false,
    this.volume = 1.0,
    this.child,
  });

  @override
  State<FxAudio> createState() => _FxAudioState();
}

class _FxAudioState extends State<FxAudio> {
  late AudioPlayer _player;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initialize();
  }

  Future<void> _initialize() async {
    final isNetwork = widget.url.startsWith('http');
    final source = isNetwork ? UrlSource(widget.url) : AssetSource(widget.url);
    
    await _player.setSource(source);
    await _player.setVolume(widget.volume);
    if (widget.loop) await _player.setReleaseMode(ReleaseMode.loop);
    if (widget.autoPlay) await _player.resume();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ?? const SizedBox.shrink();
  }
}
