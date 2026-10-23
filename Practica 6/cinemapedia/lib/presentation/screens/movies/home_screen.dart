import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentation/providers/movies/movies_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  static const name = 'home-screen';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movies = ref.watch(nowPlayingMoviesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cinemapedia')),
      body: movies.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 40),
                const SizedBox(height: 12),
                Text(
                  'No se pudieron cargar las películas.\n$error',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(nowPlayingMoviesProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
        data: (movieList) => movieList.isEmpty
            ? const Center(child: Text('No hay películas disponibles.'))
            : ListView.separated(
                itemCount: movieList.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) =>
                    _MovieTile(movie: movieList[index]),
              ),
      ),
    );
  }
}

class _MovieTile extends StatelessWidget {
  const _MovieTile({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: movie.posterPath == 'no-poster'
          ? const SizedBox(width: 48, child: Icon(Icons.movie_outlined))
          : Image.network(
              movie.posterPath,
              width: 48,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox(width: 48, child: Icon(Icons.movie_outlined)),
            ),
      title: Text(movie.title),
      subtitle: Text(
        movie.overview.isEmpty ? 'Sin descripción disponible.' : movie.overview,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
