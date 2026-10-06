import 'package:toktik/domain/entities/video_post.dart';

/// Modelo para mapear los datos locales (Map) a la entidad VideoPost.
class LocalVideoModel {
  final String id;
  final String name;
  final String description;
  final String videoUrl;
  final int likes;
  final int views;

  LocalVideoModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.videoUrl,
    this.likes = 0,
    this.views = 0,
  });

  factory LocalVideoModel.fromJson(Map<String, dynamic> json) =>
      LocalVideoModel(
        id: json['id'] ?? 'local_${json['videoUrl']}',
        name: json['name'] ?? 'Sin título',
        description: json['description'] ?? '',
        videoUrl: json['videoUrl'],
        likes: json['likes'] ?? 0,
        views: json['views'] ?? 0,
      );

  VideoPost toVideoPostEntity() => VideoPost(
        id: id,
        caption: name,
        description: description,
        videoUrl: videoUrl,
        likes: likes,
        views: views,
        source: VideoSource.local,
      );
}
