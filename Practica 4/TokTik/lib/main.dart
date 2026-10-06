import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toktik/config/theme/app_theme.dart';
import 'package:toktik/infrastructure/datasources/pexels_datasource_impl.dart';
import 'package:toktik/infrastructure/datasources/pixabay_datasource_impl.dart';
import 'package:toktik/infrastructure/datasources/youtube_datasource_impl.dart';
import 'package:toktik/infrastructure/repositories/video_posts_repository_impl.dart';
import 'package:toktik/presentation/providers/discover_provider.dart';
import 'package:toktik/presentation/providers/discovery_provider.dart';
import 'package:toktik/presentation/providers/favorites_provider.dart';
import 'package:toktik/presentation/screens/home/home_screen.dart';
import 'package:toktik/services/local_storage_service.dart';

/// Punto de entrada principal de TokTik.
/// Inicializa LocalStorageService (SharedPreferences) antes de la UI.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa persistencia local (SharedPreferences)
  await LocalStorageService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ── Datasources de APIs externas ──────────────────────────────────────
    final pexelsDs = PexelsDataSource();
    final pixabayDs = PixabayDataSource();
    final youtubeDs = YoutubeDataSource();

    // ── Repositorio para For You (Pexels + Pixabay) ───────────────────────
    final forYouRepository = VideoPostsRepositoryImpl(
      datasources: [pexelsDs, pixabayDs],
    );

    return MultiProvider(
      providers: [
        // Feed "For You": local + Pexels + Pixabay
        ChangeNotifierProvider(
          lazy: false,
          create: (_) =>
              DiscoverProvider(videosRepository: forYouRepository)..loadNextPage(),
        ),

        // Feed "Discovery": YouTube
        ChangeNotifierProvider(
          create: (_) => DiscoveryProvider(youtubeDataSource: youtubeDs),
        ),

        // Favoritos: desde SharedPreferences
        ChangeNotifierProvider(
          create: (_) => FavoritesProvider()..loadFavorites(),
        ),
      ],
      child: MaterialApp(
        title: 'TokTik',
        debugShowCheckedModeBanner: false,
        // El tema cambia automáticamente según la fecha del sistema
        theme: AppTheme().getTheme(),
        home: const HomeScreen(),
      ),
    );
  }
}
