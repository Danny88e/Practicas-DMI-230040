import 'package:toktik/domain/datasources/video_post_datasource.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/domain/repositories/video_posts_repository.dart';

/// Implementación del repositorio que agrega múltiples DataSources.
///
/// Arquitectura:
///   PexelsDataSource  ─┐
///   PixabayDataSource ─┼→ VideoPostsRepositoryImpl → Lista<VideoPost> → UI
///   (YouTube se maneja en DiscoveryProvider aparte)
class VideoPostsRepositoryImpl implements VideoPostRepository {
  final List<VideoPostDatasource> datasources;

  VideoPostsRepositoryImpl({required this.datasources});

  /// Obtiene videos de todas las fuentes en paralelo y los combina.
  /// Si alguna fuente falla, continúa con las demás (fail-safe).
  @override
  Future<List<VideoPost>> getTrendingVideosByPage(int page) async {
    final results = await Future.wait(
      datasources.map(
        (ds) => ds.getTrendingVideosByPage(page).catchError((_) => <VideoPost>[]),
      ),
    );

    final combined = results.expand((list) => list).toList();
    combined.shuffle(); // Mezcla las fuentes para un feed variado
    return combined;
  }

  @override
  Future<List<VideoPost>> getFavoriteVideosByUser(String userID) async {
    // Los favoritos se gestionan mediante LocalStorageService
    return [];
  }
}
