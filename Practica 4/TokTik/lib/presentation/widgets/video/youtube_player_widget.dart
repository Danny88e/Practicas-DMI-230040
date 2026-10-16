import 'dart:async';

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// Reproductor embebido de YouTube usando youtube_player_flutter.
/// Solo funciona en Android e iOS (no web).
///
/// [videoId] es el ID de YouTube (ej: "dQw4w9WgXcQ"), almacenado en VideoPost.videoUrl.
class YoutubePlayerWidget extends StatefulWidget {
  final String videoId;
  final bool autoPlay;

  const YoutubePlayerWidget({
    super.key,
    required this.videoId,
    this.autoPlay = false,
  });

  @override
  State<YoutubePlayerWidget> createState() => _YoutubePlayerWidgetState();
}

class _YoutubePlayerWidgetState extends State<YoutubePlayerWidget> {
  late YoutubePlayerController _controller;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: widget.autoPlay,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_controller.close());
    super.dispose();
  }

  Future<void> _toggleMute() async {
    final isMuted = !_isMuted;
    setState(() => _isMuted = isMuted);
    if (isMuted) {
      await _controller.mute();
    } else {
      await _controller.unMute();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        YoutubePlayer(controller: _controller, aspectRatio: 16 / 9),
        Positioned(
          top: 12,
          right: 12,
          child: Material(
            color: Colors.black.withValues(alpha: 0.72),
            shape: const CircleBorder(),
            child: IconButton(
              onPressed: _toggleMute,
              tooltip: _isMuted ? 'Activar sonido' : 'Silenciar video',
              color: Colors.white,
              icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up),
            ),
          ),
        ),
      ],
    );
  }
}
