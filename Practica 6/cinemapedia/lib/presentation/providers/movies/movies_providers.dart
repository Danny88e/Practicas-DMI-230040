import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentation/providers/movies/movies_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final nowPlayingMoviesProvider = StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
  final fetchMoreMovies = ref.watch( movieRepositoryProvider ).getNowPlaying;
  final notifier = MoviesNotifier(
    fetchMoreMovies: fetchMoreMovies
  );
  notifier.loadNextPage();
  return notifier;
});

final popularMoviesProvider = StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
  final fetchMoreMovies = ref.watch( movieRepositoryProvider ).getPopular;
  final notifier = MoviesNotifier(
    fetchMoreMovies: fetchMoreMovies
  );
  notifier.loadNextPage();
  return notifier;
});

final upcomingMoviesProvider = StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
  final fetchMoreMovies = ref.watch( movieRepositoryProvider ).getUpcoming;
  final notifier = MoviesNotifier(
    fetchMoreMovies: fetchMoreMovies
  );
  notifier.loadNextPage();
  return notifier;
});

final topRatedMoviesProvider = StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
  final fetchMoreMovies = ref.watch( movieRepositoryProvider ).getTopRated;
  final notifier = MoviesNotifier(
    fetchMoreMovies: fetchMoreMovies
  );
  notifier.loadNextPage();
  return notifier;
});



typedef MovieCallback = Future<List<Movie>> Function({ int page });

class MoviesNotifier extends StateNotifier<List<Movie>> {
  
  int currentPage = 0;
  bool isLoading = false;
  bool hasCompletedInitialLoad = false;
  MovieCallback fetchMoreMovies;


  MoviesNotifier({
    required this.fetchMoreMovies,
  }): super([]);

  Future<void> loadNextPage() async{
    if ( isLoading ) return;
    isLoading = true;

    final nextPage = currentPage + 1;
    try {
      final List<Movie> movies = await fetchMoreMovies(page: nextPage);
      currentPage = nextPage;
      if (mounted) state = [...state, ...movies];
    } catch (_) {
      // Complete the initial loading state even if the request fails.
    } finally {
      isLoading = false;
      if (mounted) {
        hasCompletedInitialLoad = true;
        if (state.isEmpty) state = [...state];
      }
    }
  }


}

