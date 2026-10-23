import 'package:dio/dio.dart';

import 'package:cinemapedia/config/constants/environment.dart';
import 'package:cinemapedia/domain/datasources/movies_datasource.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/infrastructure/mappers/movie_mapper.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/moviedb_response.dart';

class MoviedbDatasource extends MoviesDatasource {
  MoviedbDatasource({Dio? dio})
    : dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://api.themoviedb.org/3',
              headers: {
                'Authorization': 'Bearer ${Environment.requiredMovieDbToken}',
                'accept': 'application/json',
              },
              queryParameters: {'language': 'es-MX'},
            ),
          );

  final Dio dio;

  @override
  Future<List<Movie>> getNowPlaying({int page = 1}) async {
    final response = await dio.get(
      '/movie/now_playing',
      queryParameters: {'page': page},
    );
    if (response.data is! Map<String, dynamic>) {
      throw const FormatException('TMDB devolvió una respuesta inesperada.');
    }

    final movieDBResponse = MovieDbResponse.fromJson(response.data);
    return movieDBResponse.results.map(MovieMapper.movieDBToEntity).toList();
  }
}
