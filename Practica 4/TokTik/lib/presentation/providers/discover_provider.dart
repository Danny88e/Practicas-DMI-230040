import 'package:flutter/material.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/infrastructure/models/local_video_model.dart';
import 'package:toktik/shared/data/local_video_posts.dart';



class DiscoverProvider extends ChangeNotifier {

  bool initialLoading = true;
  List<VideoPost> videos = [];


  Future<void> loadNextPage() async {

    // Convertir todos los datos al modelo de entidad
    final List<VideoPost> allVideos = videoPosts.map(
      (video) => LocalVideoModel.fromJson(video).toVideoPostEntity()
    ).toList();

    // Filtrar videos ilógicos: excluir aquellos donde likes > views
    // Un video no puede tener más likes que visualizaciones
    final List<VideoPost> validVideos = allVideos.where(
      (video) => video.isValid
    ).toList();

    videos.addAll(validVideos);
    initialLoading = false;
    notifyListeners();
  }


}