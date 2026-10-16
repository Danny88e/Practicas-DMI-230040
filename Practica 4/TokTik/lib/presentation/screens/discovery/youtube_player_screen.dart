import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/presentation/providers/discovery_provider.dart';
import 'package:toktik/presentation/providers/favorites_provider.dart';
import 'package:toktik/presentation/widgets/video/youtube_player_widget.dart';
import 'package:toktik/services/local_storage_service.dart';

import 'dart:math' as math;

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
    _isLiked =
        LocalStorageService.isLiked(widget.video.id) || widget.video.isLiked;
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final playerMaxHeight = constraints.maxHeight * 0.68;
          final playerWidth = math.min(
            constraints.maxWidth,
            playerMaxHeight * (16 / 9),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: SizedBox(
                  width: playerWidth,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: YoutubePlayerWidget(
                        videoId: widget.video.videoUrl,
                        autoPlay: true,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 920),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.video.caption,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 18,
                            runSpacing: 8,
                            children: [
                              _VideoStat(
                                icon: Icons.remove_red_eye_outlined,
                                label: '${widget.video.views} vistas',
                              ),
                              _VideoStat(
                                icon: Icons.favorite_border,
                                label: '${widget.video.likes} likes',
                              ),
                            ],
                          ),
                          if (widget.video.description.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Divider(color: Colors.white12),
                            const SizedBox(height: 8),
                            Text(
                              widget.video.description,
                              style: const TextStyle(
                                color: Colors.white70,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _VideoStat extends StatelessWidget {
  final IconData icon;
  final String label;

  const _VideoStat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: Colors.white60),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}
