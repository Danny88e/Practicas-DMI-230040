import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cinemapedia/config/constants/countries_config.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/infrastructure/datasources/moviedb_datasource.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/moviedb_response.dart';
import 'package:cinemapedia/infrastructure/repositories/movie_repository_impl.dart';
import 'package:cinemapedia/presentation/providers/country/country_provider.dart';
import 'package:cinemapedia/presentation/providers/movies/movies_repository_provider.dart';
import 'package:cinemapedia/presentation/providers/movies/movies_providers.dart';

void main() {
  test('MoviesNotifier completes its initial load after fetching movies', () async {
    final notifier = MoviesNotifier(
      fetchMoreMovies: ({int page = 1}) async => [],
    );

    await notifier.loadNextPage();

    expect(notifier.hasCompletedInitialLoad, isTrue);
    expect(notifier.state, isEmpty);
    notifier.dispose();
  });

  test('MoviesNotifier ends loading after a request failure', () async {
    final notifier = MoviesNotifier(
      fetchMoreMovies: ({int page = 1}) async => throw Exception('request failed'),
    );

    await notifier.loadNextPage();

    expect(notifier.hasCompletedInitialLoad, isTrue);
    expect(notifier.state, isEmpty);
    notifier.dispose();
  });

  test('changing country reloads movies with the new language', () async {
    final requestedLanguages = <String>[];
    final container = ProviderContainer(
      overrides: [
        movieRepositoryProvider.overrideWith((ref) {
          final country = ref.watch(selectedCountryProvider);
          final datasource = _RecordingDatasource(
            language: CountriesConfig.getLanguageCode(country),
            requestedLanguages: requestedLanguages,
          );
          return MovieRepositoryImpl(datasource);
        }),
      ],
    );
    final subscription = container.listen(
      nowPlayingMoviesProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    addTearDown(container.dispose);

    await Future<void>.delayed(Duration.zero);
    container.read(selectedCountryProvider.notifier).state = 'GB';
    await Future<void>.delayed(Duration.zero);

    expect(requestedLanguages, ['es-MX', 'en-GB']);
  });

  test('TMDB response accepts movies with missing optional fields', () {
    final response = MovieDbResponse.fromJson({
      'page': 1,
      'results': [
        {
          'id': 1,
          'title': 'Película sin datos opcionales',
          'original_title': 'Movie without optional data',
          'original_language': 'en',
        },
      ],
      'total_pages': 1,
      'total_results': 1,
    });

    expect(response.results, hasLength(1));
    expect(response.results.single.genreIds, isEmpty);
    expect(response.results.single.releaseDate, isNull);
    expect(response.results.single.posterPath, isEmpty);
  });
}

class _RecordingDatasource extends MoviedbDatasource {
  _RecordingDatasource({
    required super.language,
    required this.requestedLanguages,
  });

  final List<String> requestedLanguages;

  @override
  Future<List<Movie>> getNowPlaying({int page = 1}) async {
    requestedLanguages.add(language);
    return [];
  }
}
