import 'package:dio/dio.dart';
import 'package:toktik/config/api_keys.dart';
import 'package:toktik/domain/datasources/video_post_datasource.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/infrastructure/models/youtube_video_model.dart';

/// DataSource para obtener videos de YouTube Data API v3.
/// API 1 de 3 requeridas en la práctica.
///
/// Obtiene videos populares cortos de YouTube.
/// NOTA: Los videos de YouTube se reproducen con YoutubePlayerWidget,
/// NO con VideoPlayerController (YouTube no permite URLs directas de MP4).
class YoutubeDataSource implements VideoPostDatasource {
  final Dio _dio = Dio();

  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3/videos';

  @override
  Future<List<VideoPost>> getTrendingVideosByPage(int page) async {
    if (!ApiKeys.isYoutubeConfigured) {
      print('[YoutubeDataSource] API Key no configurada. Retornando lista vacía.');
      return [];
    }

    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'part': 'snippet,statistics',
          'chart': 'mostPopular',
          'maxResults': 10,
          'videoDuration': 'short',
          'regionCode': 'MX',
          'key': ApiKeys.youtubeApiKey,
        },
      ).timeout(const Duration(seconds: 10));

      final List items = response.data['items'] ?? [];
      return items
          .map((item) =>
              YoutubeVideoModel.fromJson(Map<String, dynamic>.from(item))
                  .toVideoPost())
          .where((v) => v.videoUrl.isNotEmpty)
          .toList();
    } on DioException catch (e) {
      print('[YoutubeDataSource] Error HTTP: ${e.response?.statusCode} - ${e.message}');
      return [];
    } catch (e) {
      print('[YoutubeDataSource] Error inesperado: $e');
      return [];
    }
  }

  @override
  Future<List<VideoPost>> getFavoriteVideosByUser(String userID) async => [];
}
