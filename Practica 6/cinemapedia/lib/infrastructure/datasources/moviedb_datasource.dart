import 'package:dio/dio.dart';

import 'package:cinemapedia/config/constants/environment.dart';
import 'package:cinemapedia/domain/datasources/movies_datasource.dart';
import 'package:cinemapedia/domain/entities/entities.dart';
import 'package:cinemapedia/infrastructure/mappers/mappers.dart';
import 'package:cinemapedia/infrastructure/models/models.dart';

class MoviedbDatasource extends MoviesDatasource {
  final String language;
  final String contentType; // 'movie' o 'tv'

  MoviedbDatasource({
    this.language = 'es-MX',
    this.contentType = 'movie',
  });

  bool get _isTv => contentType == 'tv';

  Dio get _dio => Dio(BaseOptions(
        baseUrl: 'https://api.themoviedb.org/3',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        queryParameters: {
          'api_key': Environment.theMovieDbKey,
          'language': language,
        },
      ));

  List<Movie> _jsonToMovies(Map<String, dynamic> json) {
    final movieDBResponse = MovieDbResponse.fromJson(json);

    final List<Movie> movies = movieDBResponse.results
        .where((moviedb) => moviedb.posterPath != 'no-poster')
        .map((moviedb) => MovieMapper.movieDBToEntity(moviedb))
        .toList();

    return movies;
  }

  /// Descarga una lista y, si el idioma activo no es inglés y algún elemento
  /// llegó sin sinopsis, recupera la versión en inglés y completa solo los
  /// campos vacíos. Así se cumple la política de respaldo sin alterar los
  /// textos que sí existen en el idioma elegido.
  Future<List<Movie>> _fetchMovieList(
    String endpoint, {
    Map<String, dynamic> queryParameters = const {},
    int page = 1,
  }) async {
    final response = await _dio.get(
      endpoint,
      queryParameters: {...queryParameters, 'page': page},
    );

    final movies = _jsonToMovies(response.data);
    if (language.toLowerCase().startsWith('en') ||
        movies.isEmpty ||
        !movies.any((movie) => movie.overview.trim().isEmpty)) {
      return movies;
    }

    try {
      final englishResponse = await _dio.get(
        endpoint,
        queryParameters: {
          ...queryParameters,
          'page': page,
          'language': 'en-US',
        },
      );
      final englishMovies = _jsonToMovies(englishResponse.data);
      final englishOverviews = {
        for (final movie in englishMovies) movie.id: movie.overview,
      };

      return movies.map((movie) {
        if (movie.overview.trim().isNotEmpty) return movie;
        final englishOverview = englishOverviews[movie.id]?.trim() ?? '';
        return englishOverview.isEmpty
            ? movie
            : movie.copyWith(overview: englishOverview);
      }).toList();
    } catch (_) {
      return movies;
    }
  }

  @override
  Future<List<Movie>> getNowPlaying({int page = 1}) {
    final endpoint = _isTv ? '/tv/on_the_air' : '/movie/now_playing';
    return _fetchMovieList(endpoint, page: page);
  }

  @override
  Future<List<Movie>> getPopular({int page = 1}) {
    final endpoint = _isTv ? '/tv/popular' : '/movie/popular';
    return _fetchMovieList(endpoint, page: page);
  }

  @override
  Future<List<Movie>> getTopRated({int page = 1}) {
    final endpoint = _isTv ? '/tv/top_rated' : '/movie/top_rated';
    return _fetchMovieList(endpoint, page: page);
  }

  @override
  Future<List<Movie>> getUpcoming({int page = 1}) {
    final endpoint = _isTv ? '/tv/airing_today' : '/movie/upcoming';
    return _fetchMovieList(endpoint, page: page);
  }

  @override
  Future<Movie> getMovieById(String id) async {
    var endpoint = _isTv ? '/tv/$id' : '/movie/$id';

    Response response;
    try {
      response = await _dio.get(endpoint);
    } catch (_) {
      // Intento inverso en caso de que sea ID de película o serie cruzada
      endpoint = _isTv ? '/movie/$id' : '/tv/$id';
      response = await _dio.get(endpoint);
    }

    if (response.statusCode != 200) {
      throw Exception('Element with id: $id not found');
    }

    final movieDetails = MovieDetails.fromJson(response.data);
    var movie = MovieMapper.movieDetailsToEntity(movieDetails);

    // Política de Respaldo: Si no cuenta con sinopsis en el idioma seleccionado,
    // aplicar respaldo automático al inglés (en-US)
    if (movie.overview.trim().isEmpty &&
        !language.toLowerCase().startsWith('en')) {
      try {
        final enResponse = await _dio.get(
          endpoint,
          queryParameters: {'language': 'en-US'},
        );
        if (enResponse.statusCode == 200) {
          final enMovie =
              MovieMapper.movieDetailsToEntity(MovieDetails.fromJson(enResponse.data));
          if (enMovie.overview.trim().isNotEmpty) {
            movie = movie.copyWith(overview: enMovie.overview);
          }
        }
      } catch (_) {
        // En caso de fallo de red, se mantiene el objeto original
      }
    }

    return movie;
  }

  @override
  Future<List<Movie>> searchMovies(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return [];

    final endpoint = _isTv ? '/search/tv' : '/search/movie';
    return _fetchMovieList(
      endpoint,
      queryParameters: {'query': trimmedQuery},
    );
  }

  @override
  Future<List<Movie>> getSimilarMovies(int movieId) async {
    final endpoint = _isTv ? '/tv/$movieId/similar' : '/movie/$movieId/similar';
    try {
      return await _fetchMovieList(endpoint);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<Video>> getYoutubeVideosById(int movieId) async {
    final endpoint = _isTv ? '/tv/$movieId/videos' : '/movie/$movieId/videos';
    try {
      final response = await _dio.get(endpoint);
      final moviedbVideosReponse = MoviedbVideosResponse.fromJson(response.data);
      final videos = <Video>[];

      for (final moviedbVideo in moviedbVideosReponse.results) {
        if (moviedbVideo.site == 'YouTube' &&
            moviedbVideo.key.trim().isNotEmpty) {
          final video = VideoMapper.moviedbVideoToEntity(moviedbVideo);
          videos.add(video);
        }
      }

      // El tráiler oficial siempre se reproduce primero; luego teasers y clips.
      videos.sort((a, b) => _videoPriority(a).compareTo(_videoPriority(b)));
      return videos;
    } catch (_) {
      return [];
    }
  }

  int _videoPriority(Video video) {
    if (video.type == 'Trailer' && video.official) return 0;
    if (video.type == 'Trailer') return 1;
    if (video.type == 'Teaser' && video.official) return 2;
    if (video.type == 'Teaser') return 3;
    return 4;
  }

  /// Obtiene la clasificación por edades real de TMDB para el país asociado
  /// al idioma activo. Devuelve 'NR' cuando TMDB no tiene certificación.
  @override
  Future<String> getAgeRating(int movieId) async {
    final endpoint = _isTv
        ? '/tv/$movieId/content_ratings'
        : '/movie/$movieId/release_dates';

    try {
      final response = await _dio.get(endpoint);
      final results = response.data['results'];
      if (results is! List) return 'NR';

      for (final countryCode in _ratingCountries) {
        final rating = _extractRating(results, countryCode);
        if (rating != null && rating.trim().isNotEmpty) {
          return _formatRating(rating, countryCode);
        }
      }
    } catch (_) {
      // Sin conexión o sin datos: NR
    }

    return 'NR';
  }

  List<String> get _ratingCountries {
    switch (language.split('-').first.toLowerCase()) {
      case 'es':
        return const ['MX'];
      case 'en':
        return const ['US'];
      case 'de':
        return const ['DE'];
      case 'zh':
        return const ['CN', 'TW'];
      case 'ar':
        return const ['SA', 'AE', 'EG'];
      default:
        return const ['US'];
    }
  }

  String? _extractRating(List results, String countryCode) {
    Map? countryResult;
    for (final item in results) {
      if (item is Map && item['iso_3166_1'] == countryCode) {
        countryResult = item;
        break;
      }
    }
    if (countryResult == null) return null;

    if (_isTv) {
      final rating = (countryResult['rating'] as String?)?.trim();
      return (rating == null || rating.isEmpty) ? null : rating;
    }

    final releaseDates = countryResult['release_dates'];
    if (releaseDates is! List) return null;

    final candidates = releaseDates.whereType<Map>().toList()
      ..sort((a, b) =>
          _releaseTypePriority(a['type']).compareTo(_releaseTypePriority(b['type'])));

    for (final releaseDate in candidates) {
      final certification =
          (releaseDate['certification'] as String?)?.trim() ?? '';
      if (certification.isNotEmpty &&
          certification.toUpperCase() != 'NR' &&
          certification.toUpperCase() != 'NOT RATED') {
        return certification;
      }
    }

    return null;
  }

  int _releaseTypePriority(dynamic type) {
    final releaseType = type is int ? type : int.tryParse('$type') ?? 99;
    const priorities = {3: 0, 2: 1, 4: 2, 5: 3, 1: 4, 6: 5};
    return priorities[releaseType] ?? 10;
  }

  String _formatRating(String rating, String countryCode) {
    final value = rating.trim();
    final upperValue = value.toUpperCase();
    if (upperValue == 'NR' || upperValue == 'NOT RATED') return 'NR';

    if (countryCode == 'DE' && RegExp(r'^\d+$').hasMatch(value)) {
      return 'FSK $value';
    }

    if (countryCode == 'MX') {
      final normalized = value
          .replaceAll('-', '')
          .replaceAll(' ', '')
          .toUpperCase();
      if (RegExp(r'^(AA|A|B|B15|C)$').hasMatch(normalized)) {
        return normalized;
      }
    }

    if (countryCode == 'TW') {
      const taiwanRatings = {
        '0': '普遍級',
        '6': '保護級',
        '12': '輔導級',
        '15': '輔導級',
        '18': '限制級',
      };
      return taiwanRatings[value] ?? value;
    }

    return value;
  }
}
