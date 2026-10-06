import 'package:flutter/material.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/presentation/widgets/video/youtube_player_widget.dart';

/// Pantalla de reproducción completa de un video de YouTube.
class YoutubePlayerScreen extends StatelessWidget {
  final VideoPost video;

  const YoutubePlayerScreen({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          video.caption,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Reproductor YouTube ─────────────────────────────────────
          YoutubePlayerWidget(videoId: video.videoUrl, autoPlay: true),

          // ── Descripción expandible ──────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.caption,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.remove_red_eye_outlined,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${video.views} vistas',
                          style: const TextStyle(color: Colors.grey)),
                      const SizedBox(width: 16),
                      const Icon(Icons.favorite_border,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${video.likes} likes',
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  if (video.description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(video.description),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
