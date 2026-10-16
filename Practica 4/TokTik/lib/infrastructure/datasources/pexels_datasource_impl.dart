import 'package:dio/dio.dart';
import 'package:toktik/config/api_keys.dart';
import 'package:toktik/domain/datasources/video_post_datasource.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/infrastructure/models/pexels_video_model.dart';

/// DataSource para obtener videos de la API de Pexels.
/// API 2 de 3 requeridas en la práctica.
///
/// Retorna URLs directas de MP4, reproducibles con VideoPlayerController.networkUrl.
class PexelsDataSource implements VideoPostDatasource {
  final Dio _dio = Dio();

  static const String _baseUrl = 'https://api.pexels.com/videos/search';

  // Términos de búsqueda para el feed principal
  static const List<String> _queries = [
    'nature',
    'animals',
    'lifestyle',
    'technology',
    'sports',
  ];

  @override
  Future<List<VideoPost>> getTrendingVideosByPage(int page) async {
    if (!ApiKeys.isPexelsConfigured) {
      print('[PexelsDataSource] API Key no configurada. Retornando lista vacía.');
      return [];
    }

    try {
      // Rotamos entre distintas búsquedas para variedad de contenido
      final query = _queries[(page - 1) % _queries.length];

      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'query': query,
          'per_page': 6,
          'page': page,
          'orientation': 'portrait', // Videos verticales para el feed
        },
        options: Options(
          headers: {'Authorization': ApiKeys.pexelsApiKey},
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      final List videos = response.data['videos'] ?? [];
      return videos
          .map((v) => PexelsVideoModel.fromJson(
                  Map<String, dynamic>.from(v))
              .toVideoPost())
          .where((v) => v.videoUrl.isNotEmpty)
          .toList();
    } on DioException catch (e) {
      print('[PexelsDataSource] Error HTTP: ${e.response?.statusCode} - ${e.message}');
      return [];
    } catch (e) {
      print('[PexelsDataSource] Error inesperado: $e');
      return [];
    }
  }

  @override
  Future<List<VideoPost>> getFavoriteVideosByUser(String userID) async => [];
}
