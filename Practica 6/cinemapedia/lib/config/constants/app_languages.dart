/// Idiomas soportados por Cinemapedia 230040.
/// Uno por cada idioma requerido: ES, EN, DE, ZH, AR
class AppLanguages {
  static const List<Map<String, String>> supported = [
    {'code': 'es', 'tmdb': 'es-MX', 'label': 'Español', 'flag': '🇲🇽', 'locale': 'es_MX'},
    {'code': 'en', 'tmdb': 'en-US', 'label': 'English', 'flag': '🇺🇸', 'locale': 'en_US'},
    {'code': 'de', 'tmdb': 'de-DE', 'label': 'Deutsch', 'flag': '🇩🇪', 'locale': 'de_DE'},
    {'code': 'zh', 'tmdb': 'zh-CN', 'label': '中文',    'flag': '🇨🇳', 'locale': 'zh_CN'},
    {'code': 'ar', 'tmdb': 'ar-SA', 'label': 'العربية', 'flag': '🇸🇦', 'locale': 'ar_SA'},
  ];

  static String getTmdbCode(String langCode) {
    return supported.firstWhere(
      (l) => l['code'] == langCode,
      orElse: () => {'tmdb': 'es-MX'},
    )['tmdb']!;
  }

  static Map<String, String> getByCode(String langCode) {
    return supported.firstWhere(
      (l) => l['code'] == langCode,
      orElse: () => supported.first,
    );
  }
}
