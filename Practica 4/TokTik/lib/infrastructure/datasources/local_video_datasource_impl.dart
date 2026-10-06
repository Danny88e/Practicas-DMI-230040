import 'package:toktik/domain/datasources/video_post_datasource.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/infrastructure/models/local_video_model.dart';
import 'package:toktik/shared/data/local_video_posts.dart';

/// DataSource para videos locales almacenados en assets/videos/.
/// NO cuenta como una de las 3 APIs externas requeridas.
class LocalVideoDatasource implements VideoPostDatasource {
  @override
  Future<List<VideoPost>> getTrendingVideosByPage(int page) async {
    // Los videos locales siempre vienen de la misma fuente, ignoramos page
    return videoPosts
        .map((json) => LocalVideoModel.fromJson(json).toVideoPostEntity())
        .toList();
  }

  @override
  Future<List<VideoPost>> getFavoriteVideosByUser(String userID) async {
    // Los favoritos se gestionan mediante LocalStorageService, no desde este datasource
    return [];
  }
}
