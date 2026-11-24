import 'package:cinemapedia/infrastructure/datasources/actor_moviedb_datasource.dart';
import 'package:cinemapedia/infrastructure/repositories/actor_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cinemapedia/presentation/providers/language/language_provider.dart';
import 'package:cinemapedia/presentation/providers/language/content_type_provider.dart';


// Este repositorio es inmutable
final actorsRepositoryProvider = Provider((ref) {
  final language = ref.watch(tmdbLanguageProvider);
  final contentType = ref.watch(contentTypeProvider);
  return ActorRepositoryImpl(ActorMovieDbDatasource(language: language, contentType: contentType));
});
