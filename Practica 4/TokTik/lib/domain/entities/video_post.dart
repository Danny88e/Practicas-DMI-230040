/// Fuente de origen de un video.
enum VideoSource { local, youtube, pexels, pixabay }

/// Entidad principal de dominio que representa un video en TokTik.
class VideoPost {
  final String id;
  final String caption;
  final String description;
  final String videoUrl;
  final String? thumbnailUrl;
  final int likes;
  final int views;
  final bool isLiked;
  final VideoSource source;

  const VideoPost({
    required this.id,
    required this.caption,
    this.description = '',
    required this.videoUrl,
    this.thumbnailUrl,
    this.likes = 0,
    this.views = 0,
    this.isLiked = false,
    this.source = VideoSource.local,
  });

  /// Un video local es inválido si tiene más likes que visualizaciones,
  /// ya que es imposible dar like a un video que no se ha visto.
  /// Los videos de APIs externas se consideran siempre válidos.
  bool get isValid => source == VideoSource.local ? likes <= views : true;

  VideoPost copyWith({
    String? id,
    String? caption,
    String? description,
    String? videoUrl,
    String? thumbnailUrl,
    int? likes,
    int? views,
    bool? isLiked,
    VideoSource? source,
  }) {
    return VideoPost(
      id: id ?? this.id,
      caption: caption ?? this.caption,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      likes: likes ?? this.likes,
      views: views ?? this.views,
      isLiked: isLiked ?? this.isLiked,
      source: source ?? this.source,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'caption': caption,
        'description': description,
        'videoUrl': videoUrl,
        'thumbnailUrl': thumbnailUrl,
        'likes': likes,
        'views': views,
        'isLiked': isLiked,
        'source': source.name,
      };

  factory VideoPost.fromJson(Map<String, dynamic> json) => VideoPost(
        id: json['id'] ?? '',
        caption: json['caption'] ?? '',
        description: json['description'] ?? '',
        videoUrl: json['videoUrl'] ?? '',
        thumbnailUrl: json['thumbnailUrl'],
        likes: json['likes'] ?? 0,
        views: json['views'] ?? 0,
        isLiked: json['isLiked'] ?? false,
        source: VideoSource.values.firstWhere(
          (e) => e.name == json['source'],
          orElse: () => VideoSource.local,
        ),
      );
}