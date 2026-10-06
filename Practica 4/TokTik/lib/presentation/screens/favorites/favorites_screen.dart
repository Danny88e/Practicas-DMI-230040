import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/presentation/providers/discover_provider.dart';
import 'package:toktik/presentation/providers/favorites_provider.dart';
import 'package:toktik/presentation/screens/discovery/youtube_player_screen.dart';
import 'package:toktik/presentation/widgets/video/fullscreen_player.dart';

/// Pestaña "Favoritos" — muestra los videos que el usuario ha marcado con ❤️.
///
/// PUNTO 8 — Favoritos: Lista los videos guardados desde SharedPreferences.
/// Si se quita el like, el video desaparece de la lista.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>().favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite, color: Colors.red),
            SizedBox(width: 8),
            Text('Favoritos', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: favorites.isEmpty
          ? _EmptyFavorites()
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 20),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final video = favorites[index];
                return _FavoriteCard(
                  video: video,
                  onTap: () => _openVideo(context, video),
                  onRemove: () => _removeFavorite(context, video.id),
                );
              },
            ),
    );
  }

  void _openVideo(BuildContext context, VideoPost video) {
    if (video.source == VideoSource.youtube) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => YoutubePlayerScreen(video: video)),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _FullscreenFavoritePlayer(video: video),
        ),
      );
    }
  }

  void _removeFavorite(BuildContext context, String videoId) {
    context.read<FavoritesProvider>().removeFavorite(videoId);
    // Sincroniza el estado del like en el feed principal
    context.read<DiscoverProvider>().syncLikeFromExternal(videoId, false);
  }
}

// ─── Card de favorito ─────────────────────────────────────────────────────────

class _FavoriteCard extends StatelessWidget {
  final VideoPost video;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavoriteCard({
    required this.video,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // ── Miniatura ──────────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _VideoThumbnail(video: video),
              ),

              const SizedBox(width: 12),

              // ── Información ────────────────────────────────────────
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
                    const SizedBox(height: 4),
                    _SourceBadge(source: video.source),
                    if (video.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        video.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),

              // ── Botón quitar favorito ──────────────────────────────
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: onRemove,
                tooltip: 'Quitar de favoritos',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoThumbnail extends StatelessWidget {
  final VideoPost video;
  const _VideoThumbnail({required this.video});

  @override
  Widget build(BuildContext context) {
    if (video.thumbnailUrl != null && video.thumbnailUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: video.thumbnailUrl!,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        placeholder: (_, __) =>
            Container(width: 80, height: 80, color: Colors.grey[900]),
        errorWidget: (_, __, ___) => _FallbackThumb(source: video.source),
      );
    }
    return _FallbackThumb(source: video.source);
  }
}

class _FallbackThumb extends StatelessWidget {
  final VideoSource source;
  const _FallbackThumb({required this.source});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (source) {
      case VideoSource.youtube:
        icon = Icons.smart_display;
        break;
      case VideoSource.pexels:
      case VideoSource.pixabay:
        icon = Icons.cloud;
        break;
      default:
        icon = Icons.video_file;
    }
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[850],
      child: Icon(icon, size: 36, color: Colors.grey[600]),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  final VideoSource source;
  const _SourceBadge({required this.source});

  @override
  Widget build(BuildContext context) {
    final Map<VideoSource, (String, Color)> info = {
      VideoSource.local: ('Local', Colors.green),
      VideoSource.youtube: ('YouTube', Colors.red),
      VideoSource.pexels: ('Pexels', Colors.teal),
      VideoSource.pixabay: ('Pixabay', Colors.purple),
    };
    final (label, color) = info[source] ?? ('Desconocido', Colors.grey);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

// ─── Estado vacío ─────────────────────────────────────────────────────────────

class _EmptyFavorites extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite_border, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Aún no tienes favoritos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Presiona ❤️ en cualquier video\npara guardarlo aquí',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

// ─── Reproductor fullscreen para favoritos locales/Pexels/Pixabay ────────────

class _FullscreenFavoritePlayer extends StatelessWidget {
  final VideoPost video;
  const _FullscreenFavoritePlayer({required this.video});

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
      body: FullScreenPlayer(videoPost: video),
    );
  }
}
