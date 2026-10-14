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
  // Clave propia del proyecto DMI-230040
  static const String youtubeApiKey = 'AIzaSyBhAGHFy1ClhV9jZ1ZpgDoE-QFA2WN2Qhg';

  // ─── Pexels API ────────────────────────────────────────────────────────
  // NOTA: La emisión de nuevas claves Pexels está suspendida temporalmente.
  // Los videos de Pexels quedan desactivados hasta obtener clave válida.
  static const String pexelsApiKey = '';

  // ─── Pixabay API ───────────────────────────────────────────────────────
  // Clave propia del proyecto DMI-230040
  static const String pixabayApiKey = '57999227-8d67580ec5c316c2a7fa08016';

  // ─── Verificadores de configuración ───────────────────────────────────
  static bool get isYoutubeConfigured =>
      youtubeApiKey.isNotEmpty && youtubeApiKey.length > 10;

  static bool get isPexelsConfigured =>
      pexelsApiKey.isNotEmpty && pexelsApiKey.length > 10;

  static bool get isPixabayConfigured =>
      pixabayApiKey.isNotEmpty && pixabayApiKey.length > 10;
}
