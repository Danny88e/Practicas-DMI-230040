import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toktik/config/theme/app_theme.dart';
import 'package:toktik/presentation/providers/discover_provider.dart';
import 'package:toktik/presentation/widgets/shared/video_scrollable_view.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final discoverProvider = context.watch<DiscoverProvider>();
    final season = AppTheme.currentSeason;

    // Etiqueta de temporada para el título de la AppBar
    String seasonLabel = '';
    if (season == AppSeason.halloween) seasonLabel = ' 🎃 Feliz Halloween';
    if (season == AppSeason.christmas) seasonLabel = ' 🎄 Feliz Navidad';

    return Scaffold(
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
                errorBuilder: (_, __, ___) => const Icon(Icons.play_circle),
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
      extendBodyBehindAppBar: true,
      body: discoverProvider.initialLoading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : VideoScrollableView(videos: discoverProvider.videos),
    );
  }
}