import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/presentation/providers/discovery_provider.dart';
import 'package:toktik/presentation/providers/favorites_provider.dart';
import 'package:toktik/presentation/widgets/video/youtube_player_widget.dart';
import 'package:toktik/services/local_storage_service.dart';

/// Pantalla de reproducción completa de un video de YouTube.
class YoutubePlayerScreen extends StatefulWidget {
  final VideoPost video;

  const YoutubePlayerScreen({super.key, required this.video});

  @override
  State<YoutubePlayerScreen> createState() => _YoutubePlayerScreenState();
}

class _YoutubePlayerScreenState extends State<YoutubePlayerScreen> {
  late bool _isLiked;

  @override
  void initState() {
    super.initState();
    _isLiked = LocalStorageService.isLiked(widget.video.id) || widget.video.isLiked;
  }

  Future<void> _toggleLike() async {
    final discoveryProvider = context.read<DiscoveryProvider>();
    final favoritesProvider = context.read<FavoritesProvider>();

    setState(() {
      _isLiked = !_isLiked;
    });

    await discoveryProvider.toggleLike(widget.video);
    favoritesProvider.loadFavorites();
  }

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
          widget.video.caption,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              color: _isLiked ? Colors.redAccent : Colors.white,
            ),
            tooltip: _isLiked ? 'Quitar de favoritos' : 'Agregar a favoritos',
            onPressed: _toggleLike,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Reproductor YouTube ─────────────────────────────────────
          YoutubePlayerWidget(videoId: widget.video.videoUrl, autoPlay: true),

          // ── Descripción expandible ──────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.video.caption,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.remove_red_eye_outlined,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${widget.video.views} vistas',
                          style: const TextStyle(color: Colors.grey)),
                      const SizedBox(width: 16),
                      const Icon(Icons.favorite_border,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${widget.video.likes} likes',
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  if (widget.video.description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(widget.video.description),
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
