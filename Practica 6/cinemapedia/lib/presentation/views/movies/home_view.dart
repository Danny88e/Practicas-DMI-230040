import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinemapedia/config/constants/app_localizations.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:cinemapedia/presentation/widgets/widgets.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends ConsumerState<HomeView> with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();

    ref.read(nowPlayingMoviesProvider.notifier).loadNextPage();
    ref.read(popularMoviesProvider.notifier).loadNextPage();
    ref.read(topRatedMoviesProvider.notifier).loadNextPage();
    ref.read(upcomingMoviesProvider.notifier).loadNextPage();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final initialLoading = ref.watch(initialLoadingProvider);
    if (initialLoading) return const FullScreenLoader();

    final slideShowMovies = ref.watch(moviesSlideshowProvider);
    final nowPlayingMovies = ref.watch(nowPlayingMoviesProvider);
    final topRatedMovies = ref.watch(topRatedMoviesProvider);
    final upcomingMovies = ref.watch(upcomingMoviesProvider);

    final currentLang = ref.watch(languageProvider);
    final contentType = ref.watch(contentTypeProvider);
    final isMovies = contentType == 'movie';

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollStartNotification) {
          debugPrint('[Scroll Vertical] Inicio de scroll en HomeView');
        } else if (notification is ScrollEndNotification) {
          debugPrint('[Scroll Vertical] Fin de scroll en HomeView');
        }
        return false;
      },
      child: CustomScrollView(
        slivers: [
          const SliverAppBar(
            floating: true,
            flexibleSpace: FlexibleSpaceBar(
              title: CustomAppbar(),
              titlePadding: EdgeInsets.zero,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Column(
                  children: [
                    // Carrusel superior con autoplay, controles manuales e indicadores
                    MoviesSlideshow(movies: slideShowMovies),

                    // Lista 1: En cines / En emisión
                    MovieHorizontalListview(
                      movies: nowPlayingMovies,
                      title: isMovies
                          ? AppLocalizations.get('now_playing', currentLang)
                          : AppLocalizations.get('now_airing', currentLang),
                      subTitle: isMovies
                          ? AppLocalizations.get('now_playing_sub', currentLang)
                          : AppLocalizations.get('now_airing_sub', currentLang),
                      loadNextPage: () =>
                          ref.read(nowPlayingMoviesProvider.notifier).loadNextPage(),
                    ),

                    // Lista 2: Próximamente / Próximas series
                    MovieHorizontalListview(
                      movies: upcomingMovies,
                      title: isMovies
                          ? AppLocalizations.get('upcoming', currentLang)
                          : AppLocalizations.get('upcoming_series', currentLang),
                      subTitle: isMovies
                          ? AppLocalizations.get('upcoming_sub', currentLang)
                          : null,
                      loadNextPage: () =>
                          ref.read(upcomingMoviesProvider.notifier).loadNextPage(),
                    ),

                    // Lista 3: Mejor calificadas / Series aclamadas
                    MovieHorizontalListview(
                      movies: topRatedMovies,
                      title: isMovies
                          ? AppLocalizations.get('top_rated', currentLang)
                          : AppLocalizations.get('top_rated_series', currentLang),
                      subTitle: isMovies
                          ? AppLocalizations.get('top_rated_sub', currentLang)
                          : null,
                      loadNextPage: () =>
                          ref.read(topRatedMoviesProvider.notifier).loadNextPage(),
                    ),

                    const SizedBox(height: 16),
                  ],
                );
              },
              childCount: 1,
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
