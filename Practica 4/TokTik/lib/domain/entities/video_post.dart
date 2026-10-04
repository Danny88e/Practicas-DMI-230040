
class VideoPost {
  final String caption;
  final String videoUrl;
  final int likes;
  final int views;

  const VideoPost({
    required this.caption,
    required this.videoUrl,
    this.likes = 0,
    this.views = 0,
  });

  /// Retorna true si el video es válido para mostrarse.
  /// Un video es inválido (ilógico) cuando tiene más likes que visualizaciones,
  /// ya que es imposible dar like a un video que no has visto.
  bool get isValid => likes <= views;
}