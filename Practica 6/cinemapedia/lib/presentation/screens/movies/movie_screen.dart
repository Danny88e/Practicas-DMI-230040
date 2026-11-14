import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';

import 'package:cinemapedia/config/constants/app_localizations.dart';
import 'package:cinemapedia/config/helpers/human_formats.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:cinemapedia/presentation/widgets/widgets.dart';

class MovieScreen extends ConsumerStatefulWidget {
  static const name = 'movie-screen';
  final String movieId;

  const MovieScreen({
    super.key,
    required this.movieId,
  });

  @override
  MovieScreenState createState() => MovieScreenState();
}

class MovieScreenState extends ConsumerState<MovieScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(movieInfoProvider.notifier).loadMovie(widget.movieId);
    ref.read(actorsByMovieProvider.notifier).loadActors(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    final Movie? movie = ref.watch(movieInfoProvider)[widget.movieId];

    if (movie == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          _CustomSliverAppBar(movie: movie),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _MovieDetails(movie: movie),
              childCount: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _MovieDetails extends ConsumerWidget {
  final Movie movie;

  const _MovieDetails({required this.movie});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final textStyles = Theme.of(context).textTheme;
    final currentLang = ref.watch(languageProvider);
    final contentType = ref.watch(contentTypeProvider);
    final isMovies = contentType == 'movie';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título, Póster, Sinopsis, Rating y Clasificación por edad
        _TitleAndOverview(
          movie: movie,
          size: size,
          textStyles: textStyles,
          langCode: currentLang,
        ),

        // Géneros de la película / serie
        _Genres(movie: movie),

        // Reparto de actores
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            AppLocalizations.get('cast', currentLang),
            style: textStyles.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        ActorsByMovie(movieId: movie.id.toString()),

        // Tráiler oficial de YouTube
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            AppLocalizations.get('trailer', currentLang),
            style: textStyles.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        VideosFromMovie(movieId: movie.id),

        // Elementos similares
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
          child: Text(
            isMovies
                ? AppLocalizations.get('similar', currentLang)
                : AppLocalizations.get('similar_series', currentLang),
            style: textStyles.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SimilarMovies(movieId: movie.id),
      ],
    );
  }
}

class _Genres extends StatelessWidget {
  final Movie movie;

  const _Genres({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.start,
          spacing: 6,
          runSpacing: 4,
          children: [
            ...movie.genreIds.map(
              (gender) => Chip(
                label: Text(gender, style: const TextStyle(fontSize: 12)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TitleAndOverview extends StatelessWidget {
  final Movie movie;
  final Size size;
  final TextTheme textStyles;
  final String langCode;

  const _TitleAndOverview({
    required this.movie,
    required this.size,
    required this.textStyles,
    required this.langCode,
  });

  @override
  Widget build(BuildContext context) {
    final ageRating = AppLocalizations.getAgeRating(movie.voteAverage, langCode);
    final isRTL = langCode == 'ar';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Póster ampliado
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              movie.posterPath,
              width: size.width * 0.32,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress != null) {
                  return Container(
                    width: size.width * 0.32,
                    height: (size.width * 0.32) * 1.5,
                    color: Colors.black12,
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                }
                return FadeIn(child: child);
              },
              errorBuilder: (_, __, ___) => Container(
                width: size.width * 0.32,
                height: 160,
                color: Colors.grey.shade900,
                child: const Icon(Icons.movie_outlined, size: 40, color: Colors.white24),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Título, Descripción, Fecha de estreno y Clasificación
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Título
                Text(
                  movie.title,
                  style: textStyles.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                ),

                const SizedBox(height: 6),

                // Fila: Rating + Badge de Clasificación de edad localizada
                Row(
                  children: [
                    MovieRating(voteAverage: movie.voteAverage),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade800,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        ageRating,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Fecha de estreno
                Row(
                  children: [
                    Text(
                      AppLocalizations.get('premiere', langCode),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      HumanFormats.shortDate(movie.releaseDate),
                      style: const TextStyle(fontSize: 13, color: Colors.white70),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Sinopsis completa (con soporte RTL para Árabe)
                Text(
                  movie.overview.isNotEmpty ? movie.overview : 'No overview available.',
                  style: textStyles.bodyMedium,
                  textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final isFavoriteProvider = FutureProvider.family.autoDispose((ref, int movieId) {
  final localStorageRepository = ref.watch(localStorageRepositoryProvider);
  return localStorageRepository.isMovieFavorite(movieId);
});

class _CustomSliverAppBar extends ConsumerWidget {
  final Movie movie;

  const _CustomSliverAppBar({required this.movie});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavoriteFuture = ref.watch(isFavoriteProvider(movie.id));
    final size = MediaQuery.of(context).size;
    final scaffoldBackgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return SliverAppBar(
      backgroundColor: Colors.black,
      expandedHeight: size.height * 0.7,
      foregroundColor: Colors.white,
      actions: [
        // Botón de corazón para alternar favoritos con persistencia
        IconButton(
          onPressed: () async {
            await ref.read(favoriteMoviesProvider.notifier).toggleFavorite(movie);
            ref.invalidate(isFavoriteProvider(movie.id));
          },
          icon: isFavoriteFuture.when(
            loading: () => const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            data: (isFavorite) => isFavorite
                ? const Icon(Icons.favorite_rounded, color: Colors.red, size: 28)
                : const Icon(Icons.favorite_border, size: 28),
            error: (_, __) => const Icon(Icons.favorite_border, size: 28),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(bottom: 0),
        title: _CustomGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.7, 1.0],
          colors: [
            Colors.transparent,
            scaffoldBackgroundColor,
          ],
        ),
        background: Stack(
          children: [
            SizedBox.expand(
              child: Image.network(
                movie.posterPath,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress != null) return const SizedBox();
                  return FadeIn(child: child);
                },
                errorBuilder: (_, __, ___) => Container(color: Colors.black87),
              ),
            ),

            // Gradiente para icono de favoritos
            const _CustomGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              stops: [0.0, 0.25],
              colors: [
                Colors.black54,
                Colors.transparent,
              ],
            ),

            // Gradiente para flecha de retroceso
            const _CustomGradient(
              begin: Alignment.topLeft,
              stops: [0.0, 0.3],
              colors: [
                Colors.black87,
                Colors.transparent,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomGradient extends StatelessWidget {
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final List<double> stops;
  final List<Color> colors;

  const _CustomGradient({
    this.begin = Alignment.centerLeft,
    this.end = Alignment.centerRight,
    required this.stops,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: begin,
            end: end,
            stops: stops,
            colors: colors,
          ),
        ),
      ),
    );
  }
}
