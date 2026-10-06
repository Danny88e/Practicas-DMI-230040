/// Configuración de API Keys para TokTik.
///
/// INSTRUCCIONES PARA CONFIGURAR:
/// 1. YouTube Data API v3:
///    - Ve a: https://console.developers.google.com
///    - Crea un proyecto → Habilita "YouTube Data API v3"
///    - Crea credenciales → API Key
///    - Reemplaza el valor de [youtubeApiKey]
///
/// 2. Pexels API:
///    - Ve a: https://www.pexels.com/api/
///    - Crea una cuenta → Solicita una API Key
///    - Reemplaza el valor de [pexelsApiKey]
///
/// 3. Pixabay API:
///    - Ve a: https://pixabay.com/api/docs/
///    - Crea una cuenta → La API key está en tu perfil
///    - Reemplaza el valor de [pixabayApiKey]
///
/// IMPORTANTE: No publiques estas claves en repositorios públicos.

class ApiKeys {
  ApiKeys._();

  // ─── YouTube Data API v3 ───────────────────────────────────────────────
  static const String youtubeApiKey = 'TU_YOUTUBE_API_KEY_AQUI';

  // ─── Pexels API ────────────────────────────────────────────────────────
  static const String pexelsApiKey = 'TU_PEXELS_API_KEY_AQUI';

  // ─── Pixabay API ───────────────────────────────────────────────────────
  static const String pixabayApiKey = 'TU_PIXABAY_API_KEY_AQUI';

  // ─── Verificadores de configuración ───────────────────────────────────
  static bool get isYoutubeConfigured =>
      youtubeApiKey != 'TU_YOUTUBE_API_KEY_AQUI' && youtubeApiKey.isNotEmpty;

  static bool get isPexelsConfigured =>
      pexelsApiKey != 'TU_PEXELS_API_KEY_AQUI' && pexelsApiKey.isNotEmpty;

  static bool get isPixabayConfigured =>
      pixabayApiKey != 'TU_PIXABAY_API_KEY_AQUI' && pixabayApiKey.isNotEmpty;
}
