import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentation/providers/movies/movies_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final nowPlayingMoviesProvider = FutureProvider<List<Movie>>((ref) {
  return ref.watch(movieRepositoryProvider).getNowPlaying();
});
