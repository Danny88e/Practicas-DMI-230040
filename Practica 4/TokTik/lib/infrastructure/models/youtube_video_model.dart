import 'package:toktik/domain/entities/video_post.dart';

/// Modelo para mapear la respuesta de la YouTube Data API v3 a VideoPost.
///
/// Endpoint: GET https://www.googleapis.com/youtube/v3/videos
/// Parámetros: part=snippet,statistics&chart=mostPopular&key=API_KEY
class YoutubeVideoModel {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final int viewCount;
  final int likeCount;

  YoutubeVideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.viewCount,
    required this.likeCount,
  });

  factory YoutubeVideoModel.fromJson(Map<String, dynamic> json) {
    final snippet = (json['snippet'] as Map?)?.cast<String, dynamic>() ?? {};
    final stats = (json['statistics'] as Map?)?.cast<String, dynamic>() ?? {};
    final thumbnails = (snippet['thumbnails'] as Map?)?.cast<String, dynamic>() ?? {};
    // Preferimos la miniatura de mayor resolución disponible
    final thumb = (thumbnails['maxres'] as Map?)?.cast<String, dynamic>() ??
        (thumbnails['standard'] as Map?)?.cast<String, dynamic>() ??
        (thumbnails['high'] as Map?)?.cast<String, dynamic>() ??
        (thumbnails['medium'] as Map?)?.cast<String, dynamic>() ??
        (thumbnails['default'] as Map?)?.cast<String, dynamic>() ??
        {};

    final videoId = json['id'] is Map
        ? (json['id']['videoId']?.toString() ?? '')
        : (json['id']?.toString() ?? '');

    String thumbUrl = thumb['url']?.toString() ?? '';
    if (thumbUrl.isEmpty && videoId.isNotEmpty) {
      thumbUrl = 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
    }

    return YoutubeVideoModel(
      id: videoId,
      title: snippet['title']?.toString() ?? 'Sin título',
      description: snippet['description']?.toString() ?? '',
      thumbnailUrl: thumbUrl,
      viewCount: int.tryParse(stats['viewCount']?.toString() ?? '0') ?? 0,
      likeCount: int.tryParse(stats['likeCount']?.toString() ?? '0') ?? 0,
    );
  }

  /// Convierte al modelo de dominio VideoPost.
  /// videoUrl almacena el ID de YouTube (NO una URL de MP4).
  /// El reproductor de YouTube usa este ID para reproducir el video.
  VideoPost toVideoPost() => VideoPost(
        id: 'yt_$id',
        caption: title,
        description: description,
        videoUrl: id, // ID de YouTube, usado por YoutubePlayerWidget
        thumbnailUrl: thumbnailUrl,
        likes: likeCount,
        views: viewCount,
        source: VideoSource.youtube,
      );
}
