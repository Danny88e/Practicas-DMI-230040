import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cinemapedia/config/constants/app_localizations.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:cinemapedia/presentation/widgets/widgets.dart';

class FavoritesView extends ConsumerStatefulWidget {
  const FavoritesView({super.key});

  @override
  FavoritesViewState createState() => FavoritesViewState();
}

class FavoritesViewState extends ConsumerState<FavoritesView> with AutomaticKeepAliveClientMixin {
  bool isLastPage = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadNextPage();
  }

  void loadNextPage() async {
    if (isLoading || isLastPage) return;
    isLoading = true;

    final movies = await ref.read(favoriteMoviesProvider.notifier).loadNextPage();
    isLoading = false;

    if (movies.isEmpty) {
      isLastPage = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final favoriteMovies = ref.watch(favoriteMoviesProvider).values.toList();
    final currentLang = ref.watch(languageProvider);

    // Estado vacío cuando no hay películas/series favoritas guardadas
    if (favoriteMovies.isEmpty) {
      final colors = Theme.of(context).colorScheme;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.favorite_outline_sharp, size: 68, color: colors.primary),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.get('no_favorites_title', currentLang),
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colors.primary),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.get('no_favorites_msg', currentLang),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 24),
              // Botón de acceso directo para empezar a buscar
              FilledButton.tonalIcon(
                onPressed: () => context.go('/home/0'),
                icon: const Icon(Icons.search),
                label: Text(AppLocalizations.get('start_searching', currentLang)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: MovieMasonry(
        loadNextPage: loadNextPage,
        movies: favoriteMovies,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
