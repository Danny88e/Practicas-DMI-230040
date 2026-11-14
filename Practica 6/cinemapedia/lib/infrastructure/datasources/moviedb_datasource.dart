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

  Dio get _dio => Dio(BaseOptions(
        baseUrl: 'https://api.themoviedb.org/3',
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

  @override
  Future<List<Movie>> getNowPlaying({int page = 1}) async {
    final endpoint = (contentType == 'tv') ? '/tv/on_the_air' : '/movie/now_playing';
    final response = await _dio.get(
      endpoint,
      queryParameters: {'page': page},
    );

    return _jsonToMovies(response.data);
  }

  @override
  Future<List<Movie>> getPopular({int page = 1}) async {
    final endpoint = (contentType == 'tv') ? '/tv/popular' : '/movie/popular';
    final response = await _dio.get(
      endpoint,
      queryParameters: {'page': page},
    );

    return _jsonToMovies(response.data);
  }

  @override
  Future<List<Movie>> getTopRated({int page = 1}) async {
    final endpoint = (contentType == 'tv') ? '/tv/top_rated' : '/movie/top_rated';
    final response = await _dio.get(
      endpoint,
      queryParameters: {'page': page},
    );

    return _jsonToMovies(response.data);
  }

  @override
  Future<List<Movie>> getUpcoming({int page = 1}) async {
    final endpoint = (contentType == 'tv') ? '/tv/airing_today' : '/movie/upcoming';
    final response = await _dio.get(
      endpoint,
      queryParameters: {'page': page},
    );

    return _jsonToMovies(response.data);
  }

  @override
  Future<Movie> getMovieById(String id) async {
    final endpoint = (contentType == 'tv') ? '/tv/$id' : '/movie/$id';

    Response response;
    try {
      response = await _dio.get(endpoint);
    } catch (_) {
      // Intento inverso en caso de que sea ID de película o serie cruzada
      final altEndpoint = (contentType == 'tv') ? '/movie/$id' : '/tv/$id';
      response = await _dio.get(altEndpoint);
    }

    if (response.statusCode != 200) {
      throw Exception('Element with id: $id not found');
    }

    final movieDetails = MovieDetails.fromJson(response.data);
    Movie movie = MovieMapper.movieDetailsToEntity(movieDetails);

    // Política de Respaldo: Si no cuenta con sinopsis en el idioma seleccionado,
    // aplicar respaldo automático al inglés (en-US)
    if (movie.overview.trim().isEmpty && !language.startsWith('en')) {
      try {
        final enResponse = await _dio.get(
          endpoint,
          queryParameters: {
            'api_key': Environment.theMovieDbKey,
            'language': 'en-US',
          },
        );
        if (enResponse.statusCode == 200) {
          final enDetails = MovieDetails.fromJson(enResponse.data);
          if (enDetails.overview.trim().isNotEmpty) {
            movie = Movie(
              adult: movie.adult,
              backdropPath: movie.backdropPath,
              genreIds: movie.genreIds,
              id: movie.id,
              originalLanguage: movie.originalLanguage,
              originalTitle: movie.originalTitle,
              overview: enDetails.overview,
              popularity: movie.popularity,
              posterPath: movie.posterPath,
              releaseDate: movie.releaseDate,
              title: movie.title,
              video: movie.video,
              voteAverage: movie.voteAverage,
              voteCount: movie.voteCount,
            );
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
    if (query.isEmpty) return [];

    final endpoint = (contentType == 'tv') ? '/search/tv' : '/search/movie';
    final response = await _dio.get(
      endpoint,
      queryParameters: {'query': query},
    );

    return _jsonToMovies(response.data);
  }

  @override
  Future<List<Movie>> getSimilarMovies(int movieId) async {
    final endpoint = (contentType == 'tv') ? '/tv/$movieId/similar' : '/movie/$movieId/similar';
    try {
      final response = await _dio.get(endpoint);
      return _jsonToMovies(response.data);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<Video>> getYoutubeVideosById(int movieId) async {
    final endpoint = (contentType == 'tv') ? '/tv/$movieId/videos' : '/movie/$movieId/videos';
    try {
      final response = await _dio.get(endpoint);
      final moviedbVideosReponse = MoviedbVideosResponse.fromJson(response.data);
      final videos = <Video>[];

      for (final moviedbVideo in moviedbVideosReponse.results) {
        if (moviedbVideo.site == 'YouTube') {
          final video = VideoMapper.moviedbVideoToEntity(moviedbVideo);
          videos.add(video);
        }
      }

      return videos;
    } catch (_) {
      return [];
    }
  }
}
