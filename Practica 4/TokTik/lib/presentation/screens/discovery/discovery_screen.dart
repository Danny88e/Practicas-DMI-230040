import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toktik/config/helpers/human_formats.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/presentation/providers/discovery_provider.dart';
import 'package:toktik/presentation/screens/discovery/youtube_player_screen.dart';

/// Pestaña "Discovery" — muestra videos de YouTube en formato de tarjetas.
/// Al tocar una tarjeta se abre el reproductor completo de YouTube.
class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  @override
  void initState() {
    super.initState();
    // Carga los videos de YouTube al abrir la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiscoveryProvider>().loadVideos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DiscoveryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.explore, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Discovery', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(DiscoveryProvider provider) {
    if (provider.initialLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.redAccent),
            SizedBox(height: 12),
            Text('Cargando videos de YouTube...'),
          ],
        ),
      );
    }

    if (provider.videos.isEmpty) {
      return _EmptyDiscovery(
        message: provider.errorMessage ?? 'No hay videos de YouTube disponibles.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      itemCount: provider.videos.length,
      itemBuilder: (context, index) {
        final video = provider.videos[index];
        return _YoutubeVideoCard(
          video: video,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => YoutubePlayerScreen(video: video),
            ),
          ),
          onLikeTap: () => context.read<DiscoveryProvider>().toggleLike(video),
        );
      },
    );
  }
}

// ─── Card de video de YouTube ─────────────────────────────────────────────────

class _YoutubeVideoCard extends StatelessWidget {
  final VideoPost video;
  final VoidCallback onTap;
  final VoidCallback onLikeTap;

  const _YoutubeVideoCard({
    required this.video,
    required this.onTap,
    required this.onLikeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Miniatura ────────────────────────────────────────────
            Stack(
              alignment: Alignment.center,
              children: [
                if (video.thumbnailUrl != null && video.thumbnailUrl!.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: video.thumbnailUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 200,
                      color: Colors.grey[900],
                      child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 200,
                      color: Colors.grey[850],
                      child: const Icon(Icons.video_library, size: 60),
                    ),
                  )
                else
                  Container(
                    height: 200,
                    color: Colors.grey[850],
                    child: const Icon(Icons.video_library, size: 60),
                  ),

                // ── Botón Play sobre miniatura ────────────────────────
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 36),
                ),

                // ── Badge YouTube ─────────────────────────────────────
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_arrow, color: Colors.white, size: 12),
                        SizedBox(width: 2),
                        Text('YouTube',
                            style:
                                TextStyle(color: Colors.white, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── Información del video ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video.caption,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (video.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            video.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.remove_red_eye_outlined,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              HumanFormats.humanReadbleNumber(video.views.toDouble()),
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.favorite_border,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              HumanFormats.humanReadbleNumber(video.likes.toDouble()),
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ── Botón Like ────────────────────────────────────────
                  IconButton(
                    onPressed: onLikeTap,
                    icon: Icon(
                      video.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: video.isLiked ? Colors.red : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Estado vacío ─────────────────────────────────────────────────────────────

class _EmptyDiscovery extends StatelessWidget {
  final String message;
  const _EmptyDiscovery({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.video_off_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            const Text(
              'Configura tu YouTube API Key en lib/config/api_keys.dart',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
