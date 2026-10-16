import 'package:flutter/material.dart';
import 'package:toktik/domain/entities/video_post.dart';

/// Widget que muestra el título y descripción de un video con opción "Ver más / Ver menos".
///
/// PUNTO 2 — Descripción y "Ver más":
///   - Muestra el caption (título) siempre visible.
///   - Si la descripción supera [_maxChars] caracteres, muestra solo el inicio.
///   - Botón "Ver más" para expandir la descripción completa.
///   - Botón "Ver menos" para contraerla nuevamente.
class VideoDescription extends StatefulWidget {
  final VideoPost video;

  const VideoDescription({super.key, required this.video});

  @override
  State<VideoDescription> createState() => _VideoDescriptionState();
}

class _VideoDescriptionState extends State<VideoDescription> {
  bool _isExpanded = false;

  // Número máximo de caracteres antes de mostrar "Ver más"
  static const int _maxChars = 80;

  bool get _hasLongDescription =>
      (widget.video.description).length > _maxChars;

  String get _truncated =>
      '${widget.video.description.substring(0, _maxChars)}...';

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          shadows: [const Shadow(blurRadius: 4, color: Colors.black54)],
        );

    final bodyStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white70,
          shadows: [const Shadow(blurRadius: 3, color: Colors.black54)],
        );

    final linkStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Título / Caption ─────────────────────────────────────────
        Text(
          widget.video.caption,
          style: titleStyle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        // ── Descripción (si existe) ───────────────────────────────────
        if (widget.video.description.isNotEmpty) ...[
          const SizedBox(height: 4),
          if (_hasLongDescription && _isExpanded)
            // Sección con desplazamiento vertical cuando está expandida
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 130),
              child: RawScrollbar(
                thumbVisibility: true,
                thumbColor: Colors.white54,
                radius: const Radius.circular(4),
                thickness: 3,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      widget.video.description,
                      style: bodyStyle,
                    ),
                  ),
                ),
              ),
            )
          else
            Text(
              _hasLongDescription ? _truncated : widget.video.description,
              style: bodyStyle,
            ),

          // ── Botón (... más / Ver menos) ───────────────────────────
          if (_hasLongDescription) ...[
            const SizedBox(height: 2),
            GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Text(
                _isExpanded ? 'Ver menos' : '... más',
                style: linkStyle,
              ),
            ),
          ],
        ],
      ],
    );
  }
}
