class Environment {
  static const theMovieDbToken = String.fromEnvironment('TMDB_BEARER_TOKEN');

  static String get requiredMovieDbToken {
    if (theMovieDbToken.trim().isEmpty) {
      throw StateError(
        'Falta configurar TMDB_BEARER_TOKEN. Copia .env.example.json a '
        '.env.json, agrega tu token y ejecuta la app con '
        '--dart-define-from-file=.env.json.',
      );
    }

    return theMovieDbToken;
  }
}