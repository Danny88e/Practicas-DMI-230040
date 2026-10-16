import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toktik/domain/entities/video_post.dart';

/// Servicio de almacenamiento local para vistas, likes y favoritos.
///
/// Usa SharedPreferences como mecanismo de persistencia.
/// Se inicializa una vez en main() antes de runApp().
///
/// Claves usadas en SharedPreferences:
///   - 'views_{videoId}'     → int  (contador de vistas por video)
///   - 'liked_{videoId}'     → bool (estado de like por video)
///   - 'favorites'           → List<String> (JSON de VideoPost liked)
class LocalStorageService {
  LocalStorageService._();

  static late SharedPreferences _prefs;

  /// Inicializa SharedPreferences. Llamar antes de runApp().
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ──────────────────────────────────────────────────────────────────────
  // VISTAS
  // ──────────────────────────────────────────────────────────────────────

  /// Obtiene el número de vistas guardadas localmente para un video.
  static int getViews(String videoId) =>
      _prefs.getInt('views_$videoId') ?? 0;

  /// Incrementa en 1 la vista del video dado y la guarda.
  static Future<void> incrementViews(String videoId) async {
    final current = getViews(videoId);
    await _prefs.setInt('views_$videoId', current + 1);
  }

  // ──────────────────────────────────────────────────────────────────────
  // TEMPORADA / SEASON OVERRIDE (Mecanismo de prueba)
  // ──────────────────────────────────────────────────────────────────────

  /// Obtiene la temporada forzada manualmente ('halloween', 'christmas', 'valentines', 'normal')
  /// o null si se usa la fecha actual del dispositivo.
  static String? getSeasonOverride() => _prefs.getString('season_override');

  /// Guarda la temporada forzada para pruebas (o null para volver al modo automático).
  static Future<void> setSeasonOverride(String? season) async {
    if (season == null) {
      await _prefs.remove('season_override');
    } else {
      await _prefs.setString('season_override', season);
    }
  }

  // ──────────────────────────────────────────────────────────────────────
  // LIKES
  // ──────────────────────────────────────────────────────────────────────

  /// Retorna si un video está marcado como gustado.
  static bool isLiked(String videoId) =>
      _prefs.getBool('liked_$videoId') ?? false;

  /// Guarda o elimina el estado de like de un video.
  static Future<void> setLiked(String videoId, bool liked) async {
    await _prefs.setBool('liked_$videoId', liked);
  }

  /// Retorna el número de likes guardados localmente para un video, si existe.
  static int? getLikes(String videoId) => _prefs.getInt('likes_count_$videoId');

  /// Guarda el número de likes de un video en el local storage.
  static Future<void> setLikes(String videoId, int count) async {
    await _prefs.setInt('likes_count_$videoId', count);
  }

  // ──────────────────────────────────────────────────────────────────────
  // FAVORITOS
  // ──────────────────────────────────────────────────────────────────────

  /// Retorna la lista de videos guardados como favoritos.
  static List<VideoPost> getFavorites() {
    final raw = _prefs.getStringList('favorites') ?? [];
    return raw
        .map((jsonStr) {
          try {
            return VideoPost.fromJson(
                jsonDecode(jsonStr) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<VideoPost>()
        .toList();
  }

  /// Agrega un video a favoritos (solo si no existe ya).
  static Future<void> addFavorite(VideoPost video) async {
    final favorites = getFavorites();
    if (favorites.any((v) => v.id == video.id)) return;
    favorites.add(video);
    await _saveFavorites(favorites);
  }

  /// Elimina un video de favoritos por su ID.
  static Future<void> removeFavorite(String videoId) async {
    final favorites = getFavorites()
      ..removeWhere((v) => v.id == videoId);
    await _saveFavorites(favorites);
  }

  /// Actualiza el video en favoritos (por ejemplo, cuando cambian los likes).
  static Future<void> updateFavorite(VideoPost video) async {
    final favorites = getFavorites();
    final idx = favorites.indexWhere((v) => v.id == video.id);
    if (idx != -1) {
      favorites[idx] = video;
      await _saveFavorites(favorites);
    }
  }

  static Future<void> _saveFavorites(List<VideoPost> favorites) async {
    await _prefs.setStringList(
      'favorites',
      favorites.map((v) => jsonEncode(v.toJson())).toList(),
    );
  }
}
