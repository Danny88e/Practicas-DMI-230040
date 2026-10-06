import 'package:flutter/material.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/presentation/widgets/shared/video_buttons.dart';
import 'package:toktik/presentation/widgets/video/fullscreen_player.dart';
import 'package:toktik/presentation/widgets/video/video_description.dart';

/// Feed vertical de videos (estilo TikTok / Reels).
///
/// PUNTO 4 — Vistas: Llama a [onViewIncrement] cada vez que el usuario
///   pasa a un nuevo video (onPageChanged).
/// PUNTO 5 — Likes: Conecta VideoButtons con [onLikeToggle] del provider.
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

  @override
  void dispose() {
    _pageController.dispose();
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
      },
      itemBuilder: (context, index) {
        final videoPost = widget.videos[index];

        return Stack(
          children: [
            // ── Reproductor de video a pantalla completa ────────────
            SizedBox.expand(
              child: FullScreenPlayer(videoPost: videoPost),
            ),

            // ── Botones laterales (like + vistas + disco) ───────────
            Positioned(
              bottom: 100,
              right: 12,
              child: VideoButtons(
                video: videoPost,
                onLikeToggle: widget.onLikeToggle,
              ),
            ),

            // ── Descripción y "Ver más" en la esquina inferior ──────
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
