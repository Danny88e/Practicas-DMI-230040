import 'package:toktik/domain/entities/video_post.dart';

/// Modelo para mapear la respuesta de la API de Pixabay a VideoPost.
///
/// Endpoint: GET https://pixabay.com/api/videos/
/// Parámetros: key=API_KEY, q=búsqueda, per_page=10, safesearch=true
class PixabayVideoModel {
  final int id;
  final String tags;
  final String user;
  final String videoUrl; // URL directa del MP4
  final String thumbnailUrl;
  final int views;
  final int likes;
  final int duration;

  PixabayVideoModel({
    required this.id,
    required this.tags,
    required this.user,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.views,
    required this.likes,
    required this.duration,
  });

  factory PixabayVideoModel.fromJson(Map<String, dynamic> json) {
    final videos = json['videos'] as Map<String, dynamic>? ?? {};
    // Preferimos 'medium' para móvil, luego 'small', luego 'large'
    final medium = videos['medium'] as Map<String, dynamic>? ?? {};
    final small = videos['small'] as Map<String, dynamic>? ?? {};
    final large = videos['large'] as Map<String, dynamic>? ?? {};
    final tiny = videos['tiny'] as Map<String, dynamic>? ?? {};

    final best = medium.isNotEmpty
        ? medium
        : small.isNotEmpty
            ? small
            : large.isNotEmpty
                ? large
                : tiny;

    return PixabayVideoModel(
      id: json['id'] ?? 0,
      tags: json['tags'] ?? '',
      user: json['user'] ?? 'Pixabay',
      videoUrl: best['url'] ?? '',
      thumbnailUrl: best['thumbnail'] ?? '',
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
      duration: json['duration'] ?? 0,
    );
  }

  /// Convierte al modelo de dominio VideoPost.
  /// videoUrl es una URL directa de MP4, reproducible con VideoPlayerController.networkUrl.
  /// Pixabay provee datos reales de views y likes.
  VideoPost toVideoPost() => VideoPost(
        id: 'pixabay_$id',
        caption: tags.isNotEmpty ? tags.split(',').first.trim() : 'Video Pixabay',
        description: 'Video por $user · Tags: $tags',
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
        likes: likes,
        views: views,
        source: VideoSource.pixabay,
      );
}
