import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toktik/config/theme/app_theme.dart';
import 'package:toktik/presentation/providers/discover_provider.dart';
import 'package:toktik/presentation/widgets/shared/video_scrollable_view.dart';

/// Pestaña "For You" — feed principal de videos.
/// Muestra videos locales + Pexels + Pixabay en un PageView vertical.
class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final discoverProvider = context.watch<DiscoverProvider>();
    final season = AppTheme.currentSeason;

    String seasonLabel = '';
    if (season == AppSeason.halloween) seasonLabel = ' 🎃 Feliz Halloween';
    if (season == AppSeason.christmas) seasonLabel = ' 🎄 Feliz Navidad';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícono dinámico según la temporada
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                AppTheme.currentAppIcon,
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.play_circle, color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'TokTik$seasonLabel',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: discoverProvider.initialLoading
          ? const Center(
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : discoverProvider.videos.isEmpty
              ? const Center(
                  child: Text('No hay videos disponibles.',
                      style: TextStyle(color: Colors.white)))
              : VideoScrollableView(
                  videos: discoverProvider.videos,
                  onLikeToggle: (video) => discoverProvider.toggleLike(video),
                  onViewIncrement: (videoId) =>
                      discoverProvider.incrementViews(videoId),
                ),
    );
  }
}