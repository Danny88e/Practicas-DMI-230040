/// Configuración de países disponibles para consulta de películas.
/// Uno por continente: América, Europa, Asia, África, Oceanía.
class CountriesConfig {
  static const List<Map<String, String>> availableCountries = [
    {
      'code': 'MX',
      'flag': '🇲🇽',
      'name': 'México',
      'language': 'es-MX',
      'continent': 'América',
    },
    {
      'code': 'GB',
      'flag': '🇬🇧',
      'name': 'Reino Unido',
      'language': 'en-GB',
      'continent': 'Europa',
    },
    {
      'code': 'JP',
      'flag': '🇯🇵',
      'name': 'Japón',
      'language': 'ja-JP',
      'continent': 'Asia',
    },
    {
      'code': 'NG',
      'flag': '🇳🇬',
      'name': 'Nigeria',
      'language': 'en-NG',
      'continent': 'África',
    },
    {
      'code': 'AU',
      'flag': '🇦🇺',
      'name': 'Australia',
      'language': 'en-AU',
      'continent': 'Oceanía',
    },
  ];

  /// Devuelve el código de lenguaje TMDB para un código de país dado
  static String getLanguageCode(String countryCode) {
    final country = availableCountries.firstWhere(
      (c) => c['code'] == countryCode,
      orElse: () => {'language': 'es-MX'},
    );
    return country['language'] ?? 'es-MX';
  }
}
