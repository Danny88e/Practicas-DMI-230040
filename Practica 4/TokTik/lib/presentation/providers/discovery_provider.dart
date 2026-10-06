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
    try {
      final result = await youtubeDataSource.getTrendingVideosByPage(1);
      videos = result.map((v) => v.copyWith(
            isLiked: LocalStorageService.isLiked(v.id),
          )).toList();
      errorMessage = null;
    } catch (e) {
      errorMessage = 'No se pudo cargar el contenido de YouTube.';
      videos = [];
    }
    initialLoading = false;
    notifyListeners();
  }

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
}
