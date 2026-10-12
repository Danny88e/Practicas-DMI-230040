import 'package:flutter/material.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/presentation/widgets/video/video_background.dart';
import 'package:video_player/video_player.dart';

/// Reproductor de video a pantalla completa.
///
/// Punto 1 - Play/Pause: El toque en el video alterna reproduccion.
///   El icono central de play/pause es controlado desde [VideoScrollableView].
/// Punto 3 - Sonido: Estado de mute expuesto via [isMutedNotifier].
///   El boton de mute esta en la columna lateral ([VideoButtons]).
///
/// Soporta:
///   - Videos locales (assets):  source == VideoSource.local
///   - Videos de red (MP4):      source == VideoSource.pexels | pixabay
class FullScreenPlayer extends StatefulWidget {
  final VideoPost videoPost;

  /// Notifier que expone si el video esta muteado (true = mudo).
  final ValueNotifier<bool> isMutedNotifier;

  /// Notifier que expone si el video esta reproduciendo.
  final ValueNotifier<bool> isPlayingNotifier;

  const FullScreenPlayer({
    super.key,
    required this.videoPost,
    required this.isMutedNotifier,
    required this.isPlayingNotifier,
  });

  @override
  State<FullScreenPlayer> createState() => _FullScreenPlayerState();
}

class _FullScreenPlayerState extends State<FullScreenPlayer>
    with AutomaticKeepAliveClientMixin {
  late VideoPlayerController controller;
  bool _initialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initController();
    widget.isMutedNotifier.addListener(_onMuteChanged);
    widget.isPlayingNotifier.addListener(_onPlayingChanged);
  }

  void _initController() {
    final url = widget.videoPost.videoUrl;
    if (widget.videoPost.source == VideoSource.local) {
      controller = VideoPlayerController.asset(url);
    } else {
      controller = VideoPlayerController.networkUrl(Uri.parse(url));
    }
    controller
      ..setVolume(widget.isMutedNotifier.value ? 0 : 1)
      ..setLooping(true)
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _initialized = true);
          controller.play();
          widget.isPlayingNotifier.value = true;
        }
      });
  }

  void _onMuteChanged() {
    if (!mounted || !_initialized) return;
    controller.setVolume(widget.isMutedNotifier.value ? 0 : 1);
  }

  void _onPlayingChanged() {
    if (!mounted || !_initialized) return;
    if (widget.isPlayingNotifier.value) {
      controller.play();
    } else {
      controller.pause();
    }
  }

  @override
  void dispose() {
    widget.isMutedNotifier.removeListener(_onMuteChanged);
    widget.isPlayingNotifier.removeListener(_onPlayingChanged);
    controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    widget.isPlayingNotifier.value = !widget.isPlayingNotifier.value;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (!_initialized) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
      );
    }

    return GestureDetector(
      onTap: _togglePlayPause,
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.value.size.width,
            height: controller.value.size.height,
            child: Stack(
              children: [
                VideoPlayer(controller),
                VideoBackground(stops: const [0.8, 1.0]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
