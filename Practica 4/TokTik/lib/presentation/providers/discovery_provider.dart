import 'package:flutter/material.dart';
import 'package:toktik/domain/datasources/video_post_datasource.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/services/local_storage_service.dart';

/// Provider del feed "Discovery" — muestra videos de YouTube.
/// YouTube usa YoutubePlayerWidget, no VideoPlayerController.
class DiscoveryProvider extends ChangeNotifier {
  final VideoPostDatasource youtubeDataSource;

  bool initialLoading = true;
  String? errorMessage;
  List<VideoPost> videos = [];

  DiscoveryProvider({required this.youtubeDataSource});

  Future<void> loadVideos() async {
    initialLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await youtubeDataSource.getTrendingVideosByPage(1);
      if (result.isEmpty) {
        errorMessage = 'No se obtuvieron videos de YouTube. Comprueba tu conexión a internet o la cuota de la API.';
        videos = [];
      } else {
        videos = result.map((v) {
          final savedLikes = LocalStorageService.getLikes(v.id);
          return v.copyWith(
            isLiked: LocalStorageService.isLiked(v.id),
            likes: savedLikes ?? v.likes,
          );
        }).toList();
        errorMessage = null;
      }
    } catch (e) {
      errorMessage = 'Error al conectar con YouTube: $e';
      videos = [];
    }
    initialLoading = false;
    notifyListeners();
  }

  Future<void> toggleLike(VideoPost video) async {
    final idx = videos.indexWhere((v) => v.id == video.id);

    final isNowLiked = !video.isLiked;
    final newLikes = isNowLiked ? video.likes + 1 : (video.likes - 1).clamp(0, 999999999);
    final updated = video.copyWith(isLiked: isNowLiked, likes: newLikes);

    if (idx != -1) {
      videos[idx] = updated;
    }
    await LocalStorageService.setLiked(video.id, isNowLiked);
    await LocalStorageService.setLikes(video.id, newLikes);

    if (isNowLiked) {
      await LocalStorageService.addFavorite(updated);
    } else {
      await LocalStorageService.removeFavorite(video.id);
    }

    notifyListeners();
  }

  /// Sincroniza el estado de un like desde otra pantalla (ej: pestaña Favoritos).
  void syncLikeFromExternal(String videoId, bool isLiked) {
    final idx = videos.indexWhere((v) => v.id == videoId);
    if (idx == -1) return;
    final v = videos[idx];
    final newLikes = isLiked ? v.likes + 1 : (v.likes - 1).clamp(0, 999999999);
    videos[idx] = v.copyWith(isLiked: isLiked, likes: newLikes);
    notifyListeners();
  }
}
