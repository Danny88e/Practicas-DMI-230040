import 'package:toktik/domain/entities/video_post.dart';

/// Modelo para mapear la respuesta de la API de Pexels a VideoPost.
///
/// Endpoint: GET https://api.pexels.com/videos/search
/// Header: Authorization: API_KEY
/// Parámetros: query, per_page, orientation=portrait
class PexelsVideoModel {
  final int id;
  final String userName;
  final String thumbnailUrl;
  final String videoUrl; // URL directa del MP4 (SD o HD)
  final int duration;
  final int width;
  final int height;

  PexelsVideoModel({
    required this.id,
    required this.userName,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.duration,
    required this.width,
    required this.height,
  });

  factory PexelsVideoModel.fromJson(Map<String, dynamic> json) {
    final videoFiles = List<Map<String, dynamic>>.from(
      (json['video_files'] as List? ?? []).map((e) => Map<String, dynamic>.from(e)),
    );
    final pictures = List<Map<String, dynamic>>.from(
      (json['video_pictures'] as List? ?? []).map((e) => Map<String, dynamic>.from(e)),
    );

    // Preferimos SD para móvil (menor peso), luego HD si no hay SD
    final sdFile = videoFiles.where((f) => f['quality'] == 'sd').firstOrNull;
    final hdFile = videoFiles.where((f) => f['quality'] == 'hd').firstOrNull;
    final bestFile = sdFile ?? hdFile ?? (videoFiles.isNotEmpty ? videoFiles.first : null);

    final thumbUrl = pictures.isNotEmpty ? (pictures.first['picture'] ?? '') : '';

    return PexelsVideoModel(
      id: json['id'] ?? 0,
      userName: (json['user'] as Map?)?.cast<String, dynamic>()['name'] ?? 'Pexels',
      thumbnailUrl: thumbUrl,
      videoUrl: bestFile?['link'] ?? '',
      duration: json['duration'] ?? 0,
      width: json['width'] ?? 1920,
      height: json['height'] ?? 1080,
    );
  }

  /// Convierte al modelo de dominio VideoPost.
  /// videoUrl es una URL directa de MP4, reproducible con VideoPlayerController.networkUrl.
  VideoPost toVideoPost() => VideoPost(
        id: 'pexels_$id',
        caption: 'Video por $userName',
        description: 'Video de Pexels · ${duration}s · ${width}x$height',
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
        likes: 0,
        views: 0,
        source: VideoSource.pexels,
      );
}
