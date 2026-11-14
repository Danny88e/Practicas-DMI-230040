import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cinemapedia/config/constants/app_languages.dart';
import 'package:cinemapedia/config/constants/app_localizations.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentation/delegates/search_movie_delegate.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';

class CustomAppbar extends ConsumerWidget {
  const CustomAppbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(context).textTheme.titleMedium;
    final currentLang = ref.watch(languageProvider);
    final currentFlag = AppLanguages.getByCode(currentLang)['flag'] ?? '🌍';

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              // Botón de menú hamburguesa (abre SideMenu Drawer)
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  tooltip: AppLocalizations.get('settings', currentLang),
                ),
              ),

              // Logo de la aplicación desde assets/logos/
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  'assets/logos/Cinemapedia_logo.png',
                  height: 28,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.movie_outlined, color: colors.primary),
                ),
              ),
              const SizedBox(width: 8),

              // Nombre de la App con matrícula del estudiante
              Expanded(
                child: Text(
                  AppLocalizations.get('app_title', currentLang),
                  style: titleStyle?.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Indicador de idioma / Bandera activa (toca para abrir el menú)
              Builder(
                builder: (context) => Tooltip(
                  message: AppLocalizations.get('language', currentLang),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Scaffold.of(context).openDrawer(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Text(
                        currentFlag,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ),
              ),

              // Botón de búsqueda en tiempo real
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: AppLocalizations.get('search_hint', currentLang),
                onPressed: () {
                  final searchedMovies = ref.read(searchedMoviesProvider);
                  final searchQuery = ref.read(searchQueryProvider);

                  showSearch<Movie?>(
                    query: searchQuery,
                    context: context,
                    delegate: SearchMovieDelegate(
                      initialMovies: searchedMovies,
                      searchMovies: ref.read(searchedMoviesProvider.notifier).searchMoviesByQuery,
                    ),
                  ).then((movie) {
                    if (movie == null) return;
                    context.push('/home/0/movie/${movie.id}');
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
