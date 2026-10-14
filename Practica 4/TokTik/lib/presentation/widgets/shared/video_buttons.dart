import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:toktik/config/helpers/human_formats.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/services/local_storage_service.dart';

/// Botones laterales de interaccion de cada video.
///
/// PUNTO 5 - Me gusta: Corazon vacio/relleno con contador. Gestiona estado local
///   para respuesta inmediata, y propaga al provider via [onLikeToggle].
/// PUNTO 4 - Vistas: Muestra el contador actualizado del video.
/// PUNTO 3 - Sonido: Boton que alterna el estado de mute compartido
///   via [isMutedNotifier] con [FullScreenPlayer].
class VideoButtons extends StatefulWidget {
  final VideoPost video;
  final Future<void> Function(VideoPost)? onLikeToggle;

  /// Notifier compartido con el reproductor para controlar el mute.
  final ValueNotifier<bool>? isMutedNotifier;

  const VideoButtons({
    super.key,
    required this.video,
    this.onLikeToggle,
    this.isMutedNotifier,
  });

  @override
  State<VideoButtons> createState() => _VideoButtonsState();
}

class _VideoButtonsState extends State<VideoButtons> {
  late bool _isLiked;
  late int _likes;

  @override
  void initState() {
    super.initState();
    _isLiked = LocalStorageService.isLiked(widget.video.id) || widget.video.isLiked;
    _likes = LocalStorageService.getLikes(widget.video.id) ?? widget.video.likes;
  }

  @override
  void didUpdateWidget(VideoButtons oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.video.id != widget.video.id ||
        oldWidget.video.isLiked != widget.video.isLiked ||
        oldWidget.video.likes != widget.video.likes) {
      _isLiked = LocalStorageService.isLiked(widget.video.id) || widget.video.isLiked;
      _likes = LocalStorageService.getLikes(widget.video.id) ?? widget.video.likes;
    }
  }

  Future<void> _handleLikeTap() async {
    final nextLiked = !_isLiked;
    final nextLikes = nextLiked ? _likes + 1 : (_likes - 1).clamp(0, 999999999);
    setState(() {
      _isLiked = nextLiked;
      _likes = nextLikes;
    });
    final updatedVideo = widget.video.copyWith(isLiked: nextLiked, likes: nextLikes);
    await widget.onLikeToggle?.call(updatedVideo);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Like (PUNTO 5)
        _LikeButton(
          isLiked: _isLiked,
          likes: _likes,
          onTap: _handleLikeTap,
        ),

        const SizedBox(height: 20),

        // Vistas (PUNTO 4)
        _IconInfo(
          iconData: Icons.remove_red_eye_outlined,
          value: widget.video.views,
        ),

        const SizedBox(height: 20),

        // Boton Mute/Unmute (PUNTO 3)
        if (widget.isMutedNotifier != null) ...[
          _MuteButton(isMutedNotifier: widget.isMutedNotifier!),
          const SizedBox(height: 20),
        ],

        // Disco animado
        SpinPerfect(
          infinite: true,
          duration: const Duration(seconds: 5),
          child: const _IconInfo(iconData: Icons.play_circle_outline, value: 0),
        ),
      ],
    );
  }
}

class _LikeButton extends StatelessWidget {
  final bool isLiked;
  final int likes;
  final VoidCallback onTap;

  const _LikeButton({
    required this.isLiked,
    required this.likes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              key: ValueKey(isLiked),
              color: isLiked ? Colors.red : Colors.white,
              size: 30,
            ),
          ),
        ),
        if (likes > 0)
          Text(
            HumanFormats.humanReadbleNumber(likes.toDouble()),
            style: const TextStyle(color: Colors.white),
          ),
      ],
    );
  }
}

class _MuteButton extends StatelessWidget {
  final ValueNotifier<bool> isMutedNotifier;

  const _MuteButton({required this.isMutedNotifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isMutedNotifier,
      builder: (_, isMuted, __) {
        return GestureDetector(
          onTap: () => isMutedNotifier.value = !isMutedNotifier.value,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Column(
              key: ValueKey(isMuted),
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isMuted ? Colors.white24 : Colors.white10,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isMuted ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isMuted ? 'Mudo' : 'Sonido',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _IconInfo extends StatelessWidget {
  final IconData iconData;
  final int value;

  const _IconInfo({required this.iconData, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(iconData, color: Colors.white, size: 30),
        if (value > 0)
          Text(
            HumanFormats.humanReadbleNumber(value.toDouble()),
            style: const TextStyle(color: Colors.white),
          ),
      ],
    );
  }
}
