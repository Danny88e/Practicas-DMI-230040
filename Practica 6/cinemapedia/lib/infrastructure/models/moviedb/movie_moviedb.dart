class MovieMovieDB {
  MovieMovieDB({
    required this.adult,
    required this.backdropPath,
    required this.genreIds,
    required this.id,
    required this.originalLanguage,
    required this.originalTitle,
    required this.overview,
    required this.popularity,
    required this.posterPath,
    required this.releaseDate,
    required this.title,
    required this.video,
    required this.voteAverage,
    required this.voteCount,
  });

  final bool adult;
  final String backdropPath;
  final List<int> genreIds;
  final int id;
  final String originalLanguage;
  final String originalTitle;
  final String overview;
  final double popularity;
  final String posterPath;
  final DateTime releaseDate;
  final String title;
  final bool video;
  final double voteAverage;
  final int voteCount;

  factory MovieMovieDB.fromJson(Map<String, dynamic> json) => MovieMovieDB(
    adult: json['adult'] as bool? ?? false,
    backdropPath: json['backdrop_path'] as String? ?? '',
    genreIds: (json['genre_ids'] as List<dynamic>? ?? const [])
        .map((id) => (id as num).toInt())
        .toList(),
    id: (json['id'] as num).toInt(),
    originalLanguage: json['original_language'] as String? ?? '',
    originalTitle: json['original_title'] as String? ?? '',
    overview: json['overview'] as String? ?? '',
    popularity: (json['popularity'] as num?)?.toDouble() ?? 0,
    posterPath: json['poster_path'] as String? ?? '',
    releaseDate:
        DateTime.tryParse(json['release_date'] as String? ?? '') ?? DateTime(1),
    title: json['title'] as String? ?? '',
    video: json['video'] as bool? ?? false,
    voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
    voteCount: (json['vote_count'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'adult': adult,
    'backdrop_path': backdropPath,
    'genre_ids': genreIds,
    'id': id,
    'original_language': originalLanguage,
    'original_title': originalTitle,
    'overview': overview,
    'popularity': popularity,
    'poster_path': posterPath,
    'release_date':
        '${releaseDate.year.toString().padLeft(4, '0')}-${releaseDate.month.toString().padLeft(2, '0')}-${releaseDate.day.toString().padLeft(2, '0')}',
    'title': title,
    'video': video,
    'vote_average': voteAverage,
    'vote_count': voteCount,
  };
}
