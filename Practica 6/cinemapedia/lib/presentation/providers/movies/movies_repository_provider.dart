import 'package:cinemapedia/infrastructure/datasources/moviedb_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cinemapedia/infrastructure/repositories/movie_repository_impl.dart';
import 'package:cinemapedia/presentation/providers/language/language_provider.dart';

final movieRepositoryProvider = Provider((ref) {
  final tmdbLang = ref.watch(tmdbLanguageProvider);
  return MovieRepositoryImpl(MoviedbDatasource(language: tmdbLang));
});
