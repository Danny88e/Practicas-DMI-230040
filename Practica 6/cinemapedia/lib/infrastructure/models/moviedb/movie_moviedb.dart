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
  final DateTime? releaseDate;
  final String title;
  final bool video;
  final double voteAverage;
  final int voteCount;

  factory MovieMovieDB.fromJson(Map<String, dynamic> json) {
    // Soporte transparente para Películas (title, release_date) y Series (name, first_air_date)
    final resolvedTitle = json["title"] ?? json["name"] ?? 'No Title';
    final resolvedOriginalTitle = json["original_title"] ?? json["original_name"] ?? '';
    final dateStr = json["release_date"] ?? json["first_air_date"];

    DateTime? parsedDate;
    if (dateStr != null && dateStr.toString().isNotEmpty) {
      parsedDate = DateTime.tryParse(dateStr.toString());
    }

    return MovieMovieDB(
      adult: json["adult"] ?? false,
      backdropPath: json["backdrop_path"] ?? '',
      genreIds: json["genre_ids"] != null
          ? List<int>.from(json["genre_ids"].map((x) => x))
          : [],
      id: json["id"] ?? 0,
      originalLanguage: json["original_language"] ?? '',
      originalTitle: resolvedOriginalTitle,
      overview: json["overview"] ?? '',
      popularity: (json["popularity"] != null) ? (json["popularity"] as num).toDouble() : 0.0,
      posterPath: json["poster_path"] ?? '',
      releaseDate: parsedDate,
      title: resolvedTitle,
      video: json["video"] ?? false,
      voteAverage: (json["vote_average"] != null) ? (json["vote_average"] as num).toDouble() : 0.0,
      voteCount: json["vote_count"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "adult": adult,
    "backdrop_path": backdropPath,
    "genre_ids": List<dynamic>.from(genreIds.map((x) => x)),
    "id": id,
    "original_language": originalLanguage,
    "original_title": originalTitle,
    "overview": overview,
    "popularity": popularity,
    "poster_path": posterPath,
    "release_date": (releaseDate != null)
        ? "${releaseDate!.year.toString().padLeft(4, '0')}-${releaseDate!.month.toString().padLeft(2, '0')}-${releaseDate!.day.toString().padLeft(2, '0')}"
        : null,
    "title": title,
    "video": video,
    "vote_average": voteAverage,
    "vote_count": voteCount,
  };
}
