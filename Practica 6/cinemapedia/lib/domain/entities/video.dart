

class Video {

  final String id;
  final String name;
  final String youtubeKey;
  final DateTime publishedAt;
  final String type;
  final bool official;

  Video({
    required this.id,
    required this.name,
    required this.youtubeKey,
    required this.publishedAt,
    this.type = '',
    this.official = false,
  });


}