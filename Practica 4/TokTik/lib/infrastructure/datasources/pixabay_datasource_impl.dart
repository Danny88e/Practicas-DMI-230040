import 'package:dio/dio.dart';
import 'package:toktik/config/api_keys.dart';
import 'package:toktik/domain/datasources/video_post_datasource.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/infrastructure/models/pixabay_video_model.dart';

/// DataSource para obtener videos de la API de Pixabay.
/// API 3 de 3 requeridas en la práctica.
///
/// Retorna URLs directas de MP4, reproducibles con VideoPlayerController.networkUrl.
/// Pixabay también provee datos reales de likes y views.
class PixabayDataSource implements VideoPostDatasource {
  final Dio _dio = Dio();

  static const String _baseUrl = 'https://pixabay.com/api/videos/';

  // Búsquedas variadas para contenido seguro y general
  static const List<String> _queries = [
    'nature',
    'animals',
    'ocean water',
    'fitness sports',
    'city',
  ];

  @override
  Future<List<VideoPost>> getTrendingVideosByPage(int page) async {
    if (!ApiKeys.isPixabayConfigured) {
      print('[PixabayDataSource] API Key no configurada. Retornando lista vacía.');
      return [];
    }

    try {
      final query = _queries[(page - 1) % _queries.length];

      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'key': ApiKeys.pixabayApiKey,
          'q': query,
          'per_page': 6,
          'page': page,
          'safesearch': 'true',
          'video_type': 'all',
        },
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      final List hits = response.data['hits'] ?? [];
      return hits
          .map((h) => PixabayVideoModel.fromJson(
                  Map<String, dynamic>.from(h))
              .toVideoPost())
          .where((v) => v.videoUrl.isNotEmpty)
          .toList();
    } on DioException catch (e) {
      print('[PixabayDataSource] Error HTTP: ${e.response?.statusCode} - ${e.message}');
      return [];
    } catch (e) {
      print('[PixabayDataSource] Error inesperado: $e');
      return [];
    }
  }

  @override
  Future<List<VideoPost>> getFavoriteVideosByUser(String userID) async => [];
}
