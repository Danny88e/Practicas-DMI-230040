import 'package:flutter/material.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/presentation/widgets/video/video_background.dart';
import 'package:video_player/video_player.dart';

/// Reproductor de video a pantalla completa.
///
/// Punto 1 — Play/Pause: Botón visible en el centro cuando está pausado.
///   Tap en cualquier parte del video para alternar.
/// Punto 3 — Sonido: Botón 🔊/🔇 en la esquina superior derecha.
///
/// Soporta:
///   - Videos locales (assets):  source == VideoSource.local
///   - Videos de red (MP4):      source == VideoSource.pexels | pixabay
class FullScreenPlayer extends StatefulWidget {
  final VideoPost videoPost;

  const FullScreenPlayer({
    super.key,
    required this.videoPost,
  });

  @override
  State<FullScreenPlayer> createState() => _FullScreenPlayerState();
}

class _FullScreenPlayerState extends State<FullScreenPlayer>
    with AutomaticKeepAliveClientMixin {
  late VideoPlayerController controller;
  bool _isMuted = true;
  bool _initialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    final url = widget.videoPost.videoUrl;
    if (widget.videoPost.source == VideoSource.local) {
      controller = VideoPlayerController.asset(url);
    } else {
      controller = VideoPlayerController.networkUrl(Uri.parse(url));
    }
    controller
      ..setVolume(0) // Inicia en silencio
      ..setLooping(true)
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _initialized = true);
          controller.play();
        }
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        controller.play();
      }
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      controller.setVolume(_isMuted ? 0 : 1);
    });
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
              alignment: Alignment.center,
              children: [
                // ── Video ──────────────────────────────────────────────
                VideoPlayer(controller),

                // ── Gradiente oscuro en la parte inferior ──────────────
                VideoBackground(stops: const [0.8, 1.0]),

                // ── Botón Play/Pause (PUNTO 1) ─────────────────────────
                // Solo visible cuando está pausado; desaparece al reanudar
                ValueListenableBuilder<VideoPlayerValue>(
                  valueListenable: controller,
                  builder: (_, value, __) {
                    return AnimatedOpacity(
                      opacity: value.isPlaying ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    );
                  },
                ),

                // ── Botón de Sonido (PUNTO 3) ──────────────────────────
                Positioned(
                  top: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: (e) {}, // consume tap sin toggle play/pause
                    child: InkWell(
                      onTap: _toggleMute,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isMuted ? Icons.volume_off : Icons.volume_up,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}