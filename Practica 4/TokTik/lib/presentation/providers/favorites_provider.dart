import 'package:flutter/material.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/services/local_storage_service.dart';

/// Provider que gestiona la lista de videos favoritos del usuario.
/// Los favoritos se cargan desde SharedPreferences.
/// Se sincroniza automáticamente con el sistema de likes.
class FavoritesProvider extends ChangeNotifier {
  List<VideoPost> favorites = [];

  /// Carga los favoritos desde SharedPreferences.
  /// Llamar al navegar a la pestaña Favoritos.
  void loadFavorites() {
    favorites = LocalStorageService.getFavorites();
    notifyListeners();
  }

  /// Actualiza la lista (alias de loadFavorites para clarity).
  void refresh() => loadFavorites();

  /// Elimina un video de favoritos y actualiza like en storage.
  Future<void> removeFavorite(String videoId) async {
    await LocalStorageService.removeFavorite(videoId);
    await LocalStorageService.setLiked(videoId, false);
    favorites.removeWhere((v) => v.id == videoId);
    notifyListeners();
  }

  bool isFavorite(String videoId) =>
      favorites.any((v) => v.id == videoId);
}
