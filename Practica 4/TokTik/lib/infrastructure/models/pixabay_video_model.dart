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
    final videos = (json['videos'] as Map?)?.cast<String, dynamic>() ?? {};
    final medium = (videos['medium'] as Map?)?.cast<String, dynamic>() ?? {};
    final small = (videos['small'] as Map?)?.cast<String, dynamic>() ?? {};
    final large = (videos['large'] as Map?)?.cast<String, dynamic>() ?? {};
    final tiny = (videos['tiny'] as Map?)?.cast<String, dynamic>() ?? {};

    final best = medium.isNotEmpty
        ? medium
        : small.isNotEmpty
            ? small
            : large.isNotEmpty
                ? large
                : tiny;

    String thumbUrl = best['thumbnail']?.toString() ?? '';
    final pictureId = json['picture_id']?.toString() ?? '';
    if (thumbUrl.isEmpty && pictureId.isNotEmpty) {
      thumbUrl = 'https://i.vimeocdn.com/video/${pictureId}_640x360.jpg';
    }
    if (thumbUrl.isEmpty) {
      thumbUrl = json['userImageURL']?.toString() ?? '';
    }

    return PixabayVideoModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      tags: json['tags']?.toString() ?? '',
      user: json['user']?.toString() ?? 'Pixabay',
      videoUrl: best['url']?.toString() ?? '',
      thumbnailUrl: thumbUrl,
      views: int.tryParse(json['views']?.toString() ?? '0') ?? 0,
      likes: int.tryParse(json['likes']?.toString() ?? '0') ?? 0,
      duration: int.tryParse(json['duration']?.toString() ?? '0') ?? 0,
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
