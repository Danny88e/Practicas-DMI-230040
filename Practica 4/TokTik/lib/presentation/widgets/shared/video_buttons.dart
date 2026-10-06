import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:toktik/config/helpers/human_formats.dart';
import 'package:toktik/domain/entities/video_post.dart';

/// Botones laterales de interacción de cada video.
///
/// PUNTO 5 — Me gusta: Corazón vacío/relleno con contador. Gestiona estado local
///   para respuesta inmediata, y propaga al provider vía [onLikeToggle].
/// PUNTO 4 — Vistas: Muestra el contador actualizado del video.
class VideoButtons extends StatefulWidget {
  final VideoPost video;
  final Future<void> Function(VideoPost)? onLikeToggle;

  const VideoButtons({
    super.key,
    required this.video,
    this.onLikeToggle,
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
    _isLiked = widget.video.isLiked;
    _likes = widget.video.likes;
  }

  @override
  void didUpdateWidget(VideoButtons oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Actualiza si el video cambió desde fuera (ej: al volver de Favoritos)
    if (oldWidget.video.id != widget.video.id) {
      _isLiked = widget.video.isLiked;
      _likes = widget.video.likes;
    }
  }

  Future<void> _handleLikeTap() async {
    setState(() {
      _isLiked = !_isLiked;
      _likes = _isLiked ? _likes + 1 : (_likes - 1).clamp(0, 999999999);
    });
    await widget.onLikeToggle?.call(
      widget.video.copyWith(isLiked: _isLiked, likes: _likes),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Like (PUNTO 5) ───────────────────────────────────────────
        _LikeButton(
          isLiked: _isLiked,
          likes: _likes,
          onTap: _handleLikeTap,
        ),

        const SizedBox(height: 20),

        // ── Vistas (PUNTO 4) ──────────────────────────────────────────
        _IconInfo(
          iconData: Icons.remove_red_eye_outlined,
          value: widget.video.views,
        ),

        const SizedBox(height: 20),

        // ── Disco animado ─────────────────────────────────────────────
        SpinPerfect(
          infinite: true,
          duration: const Duration(seconds: 5),
          child: const _IconInfo(iconData: Icons.play_circle_outline, value: 0),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

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