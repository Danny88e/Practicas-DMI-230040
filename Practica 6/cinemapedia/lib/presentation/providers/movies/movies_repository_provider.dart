import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinemapedia/infrastructure/datasources/moviedb_datasource.dart';
import 'package:cinemapedia/infrastructure/repositories/movie_repository_impl.dart';
import 'package:cinemapedia/presentation/providers/language/content_type_provider.dart';
import 'package:cinemapedia/presentation/providers/language/language_provider.dart';

/// Proveedor del repositorio de películas/series que reacciona tanto al cambio
/// de idioma como a la alternancia entre Películas y Series.
final movieRepositoryProvider = Provider((ref) {
  final tmdbLang = ref.watch(tmdbLanguageProvider);
  final contentType = ref.watch(contentTypeProvider);

  return MovieRepositoryImpl(
    MoviedbDatasource(
      language: tmdbLang,
      contentType: contentType,
    ),
  );
});
