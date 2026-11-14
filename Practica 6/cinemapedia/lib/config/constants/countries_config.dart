/// Configuración de países para compatibilidad y clasificaciones.
class CountriesConfig {
  static const List<Map<String, String>> availableCountries = [
    {'code': 'MX', 'flag': '🇲🇽', 'name': 'México', 'language': 'es-MX', 'continent': 'América'},
    {'code': 'GB', 'flag': '🇬🇧', 'name': 'Reino Unido', 'language': 'en-GB', 'continent': 'Europa'},
    {'code': 'US', 'flag': '🇺🇸', 'name': 'Estados Unidos', 'language': 'en-US', 'continent': 'América'},
    {'code': 'DE', 'flag': '🇩🇪', 'name': 'Alemania', 'language': 'de-DE', 'continent': 'Europa'},
    {'code': 'JP', 'flag': '🇯🇵', 'name': 'Japón', 'language': 'ja-JP', 'continent': 'Asia'},
    {'code': 'CN', 'flag': '🇨🇳', 'name': 'China', 'language': 'zh-CN', 'continent': 'Asia'},
    {'code': 'SA', 'flag': '🇸🇦', 'name': 'Arabia Saudita', 'language': 'ar-SA', 'continent': 'Asia'},
    {'code': 'NG', 'flag': '🇳🇬', 'name': 'Nigeria', 'language': 'en-NG', 'continent': 'África'},
    {'code': 'AU', 'flag': '🇦🇺', 'name': 'Australia', 'language': 'en-AU', 'continent': 'Oceanía'},
  ];

  static String getLanguageCode(String countryCode) {
    final country = availableCountries.firstWhere(
      (c) => c['code'] == countryCode,
      orElse: () => {'language': 'es-MX'},
    );
    return country['language'] ?? 'es-MX';
  }
}

