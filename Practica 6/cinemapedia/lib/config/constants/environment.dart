import 'package:flutter_dotenv/flutter_dotenv.dart';


class Environment {

  static String get tmdbBearerToken => dotenv.env['TMDB_BEARER_TOKEN'] ?? '';


}