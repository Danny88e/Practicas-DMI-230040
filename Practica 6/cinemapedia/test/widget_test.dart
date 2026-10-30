// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/moviedb_response.dart';
import 'package:cinemapedia/main.dart';
import 'package:cinemapedia/presentation/providers/movies/movies_providers.dart';

void main() {
  testWidgets('App displays movies from the provider', (tester) async {
    final movies = [
      Movie(
        adult: false,
        backdropPath: '',
        genreIds: const [],
        id: 1,
        originalLanguage: 'es',
        originalTitle: 'Película de prueba',
        overview: 'Descripción de prueba',
        popularity: 1,
        posterPath: 'no-poster',
        releaseDate: DateTime(2026),
        title: 'Película de prueba',
        video: false,
        voteAverage: 8,
        voteCount: 10,
      ),
    ];

    MoviesNotifier createNotifier() => MoviesNotifier(
          fetchMoreMovies: ({int page = 1}) async => movies,
        );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nowPlayingMoviesProvider.overrideWith((ref) => createNotifier()),
          popularMoviesProvider.overrideWith((ref) => createNotifier()),
          topRatedMoviesProvider.overrideWith((ref) => createNotifier()),
          upcomingMoviesProvider.overrideWith((ref) => createNotifier()),
        ],
        child: const MainApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cinemapedia'), findsOneWidget);
    expect(find.text('Película de prueba'), findsWidgets);
    expect(find.text('En cines'), findsOneWidget);
    expect(find.text('Próximamente'), findsOneWidget);
    expect(find.text('Populares'), findsOneWidget);
    expect(find.text('Mejor calificadas'), findsOneWidget);
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
    expect(response.results.single.releaseDate, DateTime(1));
    expect(response.results.single.posterPath, isEmpty);
  });
}
