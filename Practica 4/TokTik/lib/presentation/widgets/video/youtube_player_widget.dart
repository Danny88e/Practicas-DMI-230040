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

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: YoutubePlayerFlags(
        autoPlay: widget.autoPlay,
        mute: false,
        enableCaption: false,
        hideControls: false,
        controlsVisibleAtStart: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressColors: const ProgressBarColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
        ),
      ),
      builder: (context, player) => player,
    );
  }
}
