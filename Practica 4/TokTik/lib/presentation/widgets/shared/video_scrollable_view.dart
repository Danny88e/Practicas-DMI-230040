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

  /// Estado de mute compartido entre todos los videos del feed.
  /// true = muteado (valor inicial).
  final ValueNotifier<bool> _isMutedNotifier = ValueNotifier(true);

  /// Estado de reproduccion del video actual.
  final ValueNotifier<bool> _isPlayingNotifier = ValueNotifier(true);

  @override
  void dispose() {
    _pageController.dispose();
    _isMutedNotifier.dispose();
    _isPlayingNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      itemCount: widget.videos.length,
      onPageChanged: (index) {
        // PUNTO 4: Incrementa vistas al ver un nuevo video
        final video = widget.videos[index];
        widget.onViewIncrement?.call(video.id);
        // Reinicia play al cambiar de video
        _isPlayingNotifier.value = true;
      },
      itemBuilder: (context, index) {
        final videoPost = widget.videos[index];

        return Stack(
          children: [
            // Reproductor de video a pantalla completa
            SizedBox.expand(
              child: FullScreenPlayer(
                videoPost: videoPost,
                isMutedNotifier: _isMutedNotifier,
                isPlayingNotifier: _isPlayingNotifier,
              ),
            ),

            // Boton Play/Pause central (PUNTO 1)
            // Superpuesto sobre el video; visible solo al pausar
            Center(
              child: ValueListenableBuilder<bool>(
                valueListenable: _isPlayingNotifier,
                builder: (_, isPlaying, __) {
                  return GestureDetector(
                    onTap: () =>
                        _isPlayingNotifier.value = !_isPlayingNotifier.value,
                    child: AnimatedOpacity(
                      opacity: isPlaying ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ),
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
