import 'package:flutter/material.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/presentation/widgets/shared/video_buttons.dart';
import 'package:toktik/presentation/widgets/video/fullscreen_player.dart';
import 'package:toktik/presentation/widgets/video/video_description.dart';

/// Feed vertical de videos (estilo TikTok / Reels).
///
/// PUNTO 1 - Play/Pause: Boton central animado, toca el video para alternar.
/// PUNTO 3 - Sonido: Boton en columna lateral derecha; estado compartido via
///   [ValueNotifier] con [FullScreenPlayer].
/// PUNTO 4 - Vistas: Llama a [onViewIncrement] cada vez que el usuario
///   pasa a un nuevo video (onPageChanged).
/// PUNTO 5 - Likes: Conecta VideoButtons con [onLikeToggle] del provider.
class VideoScrollableView extends StatefulWidget {
  final List<VideoPost> videos;
  final Future<void> Function(VideoPost)? onLikeToggle;
  final Future<void> Function(String videoId)? onViewIncrement;

  const VideoScrollableView({
    super.key,
    required this.videos,
    this.onLikeToggle,
    this.onViewIncrement,
  });

  @override
  State<VideoScrollableView> createState() => _VideoScrollableViewState();
}

class _VideoScrollableViewState extends State<VideoScrollableView> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  /// Estado de mute compartido entre todos los videos del feed.
  /// true = muteado (valor inicial).
  final ValueNotifier<bool> _isMutedNotifier = ValueNotifier(true);

  /// Estado de reproduccion del video actual.
  final ValueNotifier<bool> _isPlayingNotifier = ValueNotifier(true);

  /// Controla si el botón central play/pause es visible.
  /// Se muestra siempre al pausar, y se oculta 1.5s después de reanudar.
  final ValueNotifier<bool> _showCenterButton = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    // Ocultar el botón central 1.5s después de que el video arranque
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && _isPlayingNotifier.value) {
        _showCenterButton.value = false;
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _isMutedNotifier.dispose();
    _isPlayingNotifier.dispose();
    _showCenterButton.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    final newVal = !_isPlayingNotifier.value;
    _isPlayingNotifier.value = newVal;
    _showCenterButton.value = true;
    if (newVal) {
      // Si se reanuda, ocultar el botón después de 1.5s
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted && _isPlayingNotifier.value) {
          _showCenterButton.value = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      itemCount: widget.videos.length,
      onPageChanged: (index) {
        setState(() => _currentIndex = index);
        // PUNTO 4: Incrementa vistas al ver un nuevo video
        final video = widget.videos[index];
        widget.onViewIncrement?.call(video.id);
        // Reinicia play al cambiar de video
        _isPlayingNotifier.value = true;
        _showCenterButton.value = true;
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted && _isPlayingNotifier.value) {
            _showCenterButton.value = false;
          }
        });
      },
      itemBuilder: (context, index) {
        final videoPost = widget.videos[index];

        return Stack(
          children: [
            // Reproductor de video a pantalla completa
            // GestureDetector aquí maneja el tap en áreas fuera del botón central
            GestureDetector(
              onTap: _togglePlayPause,
              child: SizedBox.expand(
                child: FullScreenPlayer(
                  videoPost: videoPost,
                  isMutedNotifier: _isMutedNotifier,
                  isPlayingNotifier: _isPlayingNotifier,
                  isActive: index == _currentIndex,
                ),
              ),
            ),

            // Botón Play/Pause central (Punto 1 y Requisito del profesor)
            // Se muestra siempre al pausar; se oculta 1.5s después de reanudar.
            Center(
              child: ValueListenableBuilder<bool>(
                valueListenable: _showCenterButton,
                builder: (_, showBtn, __) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: _isPlayingNotifier,
                    builder: (_, isPlaying, __) {
                      return AnimatedOpacity(
                        opacity: showBtn ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: IgnorePointer(
                          ignoring: !showBtn,
                          child: GestureDetector(
                            onTap: _togglePlayPause,
                            child: Container(
                              width: 74,
                              height: 74,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.55),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.85),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.35),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Icon(
                                isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 44,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Botones laterales derecha (like + vistas + mute + disco)
            Positioned(
              bottom: 100,
              right: 12,
              child: VideoButtons(
                video: videoPost,
                onLikeToggle: widget.onLikeToggle,
                isMutedNotifier: _isMutedNotifier,
              ),
            ),

            // Descripcion y "Ver mas" en la esquina inferior
            Positioned(
              bottom: 100,
              left: 16,
              right: 90,
              child: VideoDescription(video: videoPost),
            ),
          ],
        );
      },
    );
  }
}
