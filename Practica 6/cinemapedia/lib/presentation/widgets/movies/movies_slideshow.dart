import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';


class MoviesSlideshow extends ConsumerWidget {
  
  final List<Movie> movies;
  
  const MoviesSlideshow({
    super.key, 
    required this.movies
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final colors = Theme.of(context).colorScheme;
    // Leer el país seleccionado para clasificaciones dinámicas
    final selectedCountry = ref.watch(selectedCountryProvider);

    return SizedBox(
      height: 210,
      width: double.infinity,
      child: Swiper(
        viewportFraction: 0.8,
        scale: 0.9,
        autoplay: true,
        pagination: SwiperPagination(
          margin: const EdgeInsets.only(top: 0),
          builder: DotSwiperPaginationBuilder(
            activeColor: colors.primary,
            color: colors.secondary
          )
        ),
        itemCount: movies.length,
        itemBuilder: (context, index) => _Slide(
          movie: movies[index],
          selectedCountry: selectedCountry,
        ),
      ),
    );
  }
}


class _Slide extends StatelessWidget {

  final Movie movie;
  final String selectedCountry;

  const _Slide({
    required this.movie,
    required this.selectedCountry,
  });

  @override
  Widget build(BuildContext context) {

    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Colors.black45,
          blurRadius: 10,
          offset: Offset(0, 10)
        )
      ]
    );

    // Calcular clasificación de edad dinámica según país
    final ageRating = _getAgeRating(movie.voteAverage, selectedCountry);

    return Padding(
      padding: const EdgeInsets.only( bottom: 30 ),
      child: DecoratedBox(
        decoration: decoration,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Imagen de fondo
              SizedBox.expand(
                child: Image.network(
                  movie.backdropPath,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if ( loadingProgress != null ) {
                      return const DecoratedBox(
                        decoration: BoxDecoration( color: Colors.black12 )
                      );
                    }
                    return FadeIn(child: child);
                  },
                ),
              ),

              // Gradiente sobre la imagen para legibilidad del texto
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.5, 1.0],
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.85),
                      ],
                    ),
                  ),
                ),
              ),

              // Overlay de información en la parte inferior
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      // Título local de la película
                      Text(
                        movie.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // Título original
                      if (movie.originalTitle != movie.title)
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

                      // Fila: estrellas (rating) + clasificación de edad
                      Row(
                        children: [
                          // Estrellas de rating
                          _StarRating(voteAverage: movie.voteAverage),

                          const Spacer(),

                          // Badge de clasificación por edad
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade700,
                              borderRadius: BorderRadius.circular(4),
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

            ],
          ),
        )
      ),
    );
  }

  /// Devuelve la clasificación de edad apropiada según el país seleccionado
  /// basada en el voteAverage de la película como aproximación
  String _getAgeRating(double voteAverage, String countryCode) {
    switch (countryCode) {
      case 'MX':
        // Sistema mexicano: A, AA, B, B-15, C, D
        if (voteAverage >= 8.0) return 'AA';
        if (voteAverage >= 6.0) return 'B';
        if (voteAverage >= 4.0) return 'B-15';
        return 'C';

      case 'GB':
        // Sistema europeo BBFC / PEGI
        if (voteAverage >= 8.0) return 'PG';
        if (voteAverage >= 6.0) return 'PEGI 12';
        if (voteAverage >= 4.0) return 'PEGI 16';
        return 'PEGI 18';

      case 'JP':
        // Sistema japonés: G, PG12, R15+, R18+
        if (voteAverage >= 8.0) return 'G';
        if (voteAverage >= 6.0) return 'PG12';
        if (voteAverage >= 4.0) return 'R15+';
        return 'R18+';

      case 'NG':
        // Sistema nigeriano / africano: G, PG, 12A, 15, 18
        if (voteAverage >= 8.0) return 'G';
        if (voteAverage >= 6.0) return 'PG';
        if (voteAverage >= 4.0) return '15';
        return '18';

      case 'AU':
        // Sistema australiano: G, PG, M, MA15+, R18+
        if (voteAverage >= 8.0) return 'G';
        if (voteAverage >= 6.0) return 'PG';
        if (voteAverage >= 5.0) return 'M';
        if (voteAverage >= 4.0) return 'MA15+';
        return 'R18+';

      default:
        return 'NR';
    }
  }
}


/// Widget de estrellas para mostrar el rating de la película
class _StarRating extends StatelessWidget {
  final double voteAverage;

  const _StarRating({required this.voteAverage});

  @override
  Widget build(BuildContext context) {
    // Convertir de escala 0-10 a 0-5 estrellas
    final stars = (voteAverage / 2).clamp(0.0, 5.0);
    final fullStars = stars.floor();
    final hasHalfStar = (stars - fullStars) >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Estrellas llenas
        for (int i = 0; i < fullStars; i++)
          const Icon(Icons.star, color: Colors.amber, size: 14),

        // Media estrella
        if (hasHalfStar)
          const Icon(Icons.star_half, color: Colors.amber, size: 14),

        // Estrellas vacías
        for (int i = fullStars + (hasHalfStar ? 1 : 0); i < 5; i++)
          const Icon(Icons.star_border, color: Colors.amber, size: 14),

        const SizedBox(width: 4),

        // Número del rating
        Text(
          voteAverage.toStringAsFixed(1),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

