import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String theMovieDbKey = dotenv.env['THE_MOVIEDB_KEY'] ?? 'b2c554c00057161b9a11707ef0cb115e';
  static String get tmdbBearerToken => dotenv.env['TMDB_BEARER_TOKEN'] ?? '';
}
