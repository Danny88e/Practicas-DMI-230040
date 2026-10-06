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
  // LIKES
  // ──────────────────────────────────────────────────────────────────────

  /// Retorna si un video está marcado como gustado.
  static bool isLiked(String videoId) =>
      _prefs.getBool('liked_$videoId') ?? false;

  /// Guarda o elimina el like de un video.
  static Future<void> setLiked(String videoId, bool liked) async {
    await _prefs.setBool('liked_$videoId', liked);
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
