import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinemapedia/presentation/providers/movies/movies_repository_provider.dart';

/// Clasificación de edades oficial de TMDB para el país del idioma activo.
/// El repositorio se recrea al cambiar idioma o tipo de contenido, por lo que
/// este provider también se invalida automáticamente.
final ageRatingProvider = FutureProvider.family<String, int>((ref, movieId) {
  final movieRepository = ref.watch(movieRepositoryProvider);
  return movieRepository.getAgeRating(movieId);
});
