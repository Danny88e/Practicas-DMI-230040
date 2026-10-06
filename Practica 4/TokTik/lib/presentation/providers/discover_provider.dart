import 'package:flutter/material.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/domain/repositories/video_posts_repository.dart';
import 'package:toktik/infrastructure/datasources/local_video_datasource_impl.dart';
import 'package:toktik/services/local_storage_service.dart';

/// Provider del feed "For You".
/// Combina videos locales (siempre) con videos de Pexels y Pixabay (si están configurados).
class DiscoverProvider extends ChangeNotifier {
  final VideoPostRepository videosRepository;

  bool initialLoading = true;
  bool isLoadingMore = false;
  List<VideoPost> videos = [];
  int _currentPage = 1;

  DiscoverProvider({required this.videosRepository});

  Future<void> loadNextPage() async {
    if (isLoadingMore) return;
    isLoadingMore = true;

    // 1. Cargar videos locales (siempre disponibles, solo en primera página)
    List<VideoPost> localVideos = [];
    if (_currentPage == 1) {
      final localDs = LocalVideoDatasource();
      localVideos = await localDs.getTrendingVideosByPage(1);
      // Aplicar filtro: excluir videos ilógicos (likes > views)
      localVideos = localVideos.where((v) => v.isValid).toList();
    }

    // 2. Cargar videos de APIs externas (Pexels + Pixabay via repository)
    final apiVideos = await videosRepository.getTrendingVideosByPage(_currentPage);

    // 3. Combinar y aplicar estado persistido (likes + vistas)
    final allNew = [...localVideos, ...apiVideos];
    final processed = allNew.map((v) => v.copyWith(
          isLiked: LocalStorageService.isLiked(v.id),
          views: v.views + LocalStorageService.getViews(v.id),
        )).toList();

    videos.addAll(processed);
    initialLoading = false;
    isLoadingMore = false;
    _currentPage++;
    notifyListeners();
  }

  // ──────────────────────────────────────────────────────────────────────
  // LIKE / FAVORITO
  // ──────────────────────────────────────────────────────────────────────

  /// Alterna el like de un video. Sincroniza con SharedPreferences y Favoritos.
  Future<void> toggleLike(VideoPost video) async {
    final idx = videos.indexWhere((v) => v.id == video.id);
    if (idx == -1) return;

    final isNowLiked = !video.isLiked;
    final newLikes = isNowLiked ? video.likes + 1 : (video.likes - 1).clamp(0, 999999999);

    final updated = video.copyWith(isLiked: isNowLiked, likes: newLikes);
    videos[idx] = updated;

    await LocalStorageService.setLiked(video.id, isNowLiked);

    if (isNowLiked) {
      await LocalStorageService.addFavorite(updated);
    } else {
      await LocalStorageService.removeFavorite(video.id);
    }

    notifyListeners();
  }

  // ──────────────────────────────────────────────────────────────────────
  // VISTAS
  // ──────────────────────────────────────────────────────────────────────

  /// Incrementa las vistas cuando el usuario reproduce un video.
  Future<void> incrementViews(String videoId) async {
    await LocalStorageService.incrementViews(videoId);
    final idx = videos.indexWhere((v) => v.id == videoId);
    if (idx != -1) {
      videos[idx] = videos[idx].copyWith(views: videos[idx].views + 1);
      notifyListeners();
    }
  }

  /// Sincroniza el estado de un like desde otra pantalla (ej: Favoritos).
  void syncLikeFromExternal(String videoId, bool isLiked) {
    final idx = videos.indexWhere((v) => v.id == videoId);
    if (idx == -1) return;
    final v = videos[idx];
    final newLikes = isLiked ? v.likes + 1 : (v.likes - 1).clamp(0, 999999999);
    videos[idx] = v.copyWith(isLiked: isLiked, likes: newLikes);
    notifyListeners();
  }
}