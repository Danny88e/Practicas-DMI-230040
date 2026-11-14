import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cinemapedia/config/constants/app_localizations.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';

class MoviesSlideshow extends ConsumerWidget {
  final List<Movie> movies;

  const MoviesSlideshow({
    super.key,
    required this.movies,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final currentLang = ref.watch(languageProvider);

    return SizedBox(
      height: 230,
      width: double.infinity,
      child: Swiper(
        viewportFraction: 0.82,
        scale: 0.9,
        loop: false,
        autoplay: true,
        autoplayDelay: 4000,
        pagination: SwiperPagination(
          margin: const EdgeInsets.only(top: 0),
          builder: DotSwiperPaginationBuilder(
            activeColor: colors.primary,
            color: colors.secondary.withOpacity(0.4),
            size: 6.0,
            activeSize: 9.0,
          ),
        ),
        control: const SwiperControl(
          iconNext: Icons.arrow_forward_ios_rounded,
          iconPrevious: Icons.arrow_back_ios_rounded,
          size: 18,
          color: Colors.white70,
          padding: EdgeInsets.symmetric(horizontal: 4),
        ),
        itemCount: movies.length,
        itemBuilder: (context, index) => _Slide(
          movie: movies[index],
          langCode: currentLang,
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  final Movie movie;
  final String langCode;

  const _Slide({
    required this.movie,
    required this.langCode,
  });

  @override
  Widget build(BuildContext context) {
    final ageRating = AppLocalizations.getAgeRating(movie.voteAverage, langCode);
    final isRTL = langCode == 'ar';

    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Colors.black45,
          blurRadius: 10,
          offset: Offset(0, 10),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: DecoratedBox(
        decoration: decoration,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Imagen de fondo con carga fluida
              SizedBox.expand(
                child: Image.network(
                  movie.backdropPath,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress != null) {
                      return const DecoratedBox(
                        decoration: BoxDecoration(color: Colors.black12),
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    }
                    return child;
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade900,
                    child: const Center(
                      child: Icon(Icons.movie_outlined, size: 50, color: Colors.white24),
                    ),
                  ),
                ),
              ),

              // Gradiente protector para garantizar legibilidad del texto
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.45, 1.0],
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.85),
                      ],
                    ),
                  ),
                ),
              ),

              // Contenedor de texto y métricas superpuesto
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Column(
                    crossAxisAlignment:
                        isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Título en el idioma local
                      Text(
                        movie.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // Título original (si difiere del título local)
                      if (movie.originalTitle.isNotEmpty && movie.originalTitle != movie.title)
                        Text(
                          movie.originalTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                        ),

                      const SizedBox(height: 4),

                      // Fila con Estrellas (Rating) + Clasificación por edad dinámica
                      Row(
                        children: [
                          _StarRating(voteAverage: movie.voteAverage),
                          const Spacer(),
                          // Badge de Clasificación por edad según el país/idioma
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
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Tap de navegación al detalle
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => context.push('/home/0/movie/${movie.id}'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget de estrellas de rating
class _StarRating extends StatelessWidget {
  final double voteAverage;

  const _StarRating({required this.voteAverage});

  @override
  Widget build(BuildContext context) {
    final stars = (voteAverage / 2).clamp(0.0, 5.0);
    final fullStars = stars.floor();
    final hasHalfStar = (stars - fullStars) >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < fullStars; i++)
          const Icon(Icons.star, color: Colors.amber, size: 14),
        if (hasHalfStar)
          const Icon(Icons.star_half, color: Colors.amber, size: 14),
        for (int i = fullStars + (hasHalfStar ? 1 : 0); i < 5; i++)
          const Icon(Icons.star_border, color: Colors.amber, size: 14),
        const SizedBox(width: 4),
        Text(
          voteAverage.toStringAsFixed(1),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
