import 'movie_moviedb.dart';

class MovieDbResponse {
  MovieDbResponse({
    required this.dates,
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  final Dates? dates;
  final int page;
  final List<MovieMovieDB> results;
  final int totalPages;
  final int totalResults;

  factory MovieDbResponse.fromJson(Map<String, dynamic> json) =>
      MovieDbResponse(
        dates: json['dates'] != null
            ? Dates.fromJson(json['dates'] as Map<String, dynamic>)
            : null,
        page: (json['page'] as num?)?.toInt() ?? 1,
        results: (json['results'] as List<dynamic>? ?? const [])
            .map(
              (movie) => MovieMovieDB.fromJson(movie as Map<String, dynamic>),
            )
            .toList(),
        totalPages: (json['total_pages'] as num?)?.toInt() ?? 0,
        totalResults: (json['total_results'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
    'dates': dates?.toJson(),
    'page': page,
    'results': results.map((movie) => movie.toJson()).toList(),
    'total_pages': totalPages,
    'total_results': totalResults,
  };
}

class Dates {
  Dates({required this.maximum, required this.minimum});

  final DateTime maximum;
  final DateTime minimum;

  factory Dates.fromJson(Map<String, dynamic> json) => Dates(
    maximum: DateTime.parse(json['maximum'] as String),
    minimum: DateTime.parse(json['minimum'] as String),
  );

  Map<String, dynamic> toJson() => {
    "maximum":
        "${maximum.year.toString().padLeft(4, '0')}-${maximum.month.toString().padLeft(2, '0')}-${maximum.day.toString().padLeft(2, '0')}",
    "minimum":
        "${minimum.year.toString().padLeft(4, '0')}-${minimum.month.toString().padLeft(2, '0')}-${minimum.day.toString().padLeft(2, '0')}",
  };
}
