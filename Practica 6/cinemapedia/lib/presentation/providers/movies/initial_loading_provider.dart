import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'movies_providers.dart';

final initialLoadingProvider = Provider<bool>((ref) {

  ref.watch(nowPlayingMoviesProvider);
  ref.watch(popularMoviesProvider);
  ref.watch(topRatedMoviesProvider);
  ref.watch(upcomingMoviesProvider);

  return !ref.read(nowPlayingMoviesProvider.notifier).hasCompletedInitialLoad ||
      !ref.read(popularMoviesProvider.notifier).hasCompletedInitialLoad ||
      !ref.read(topRatedMoviesProvider.notifier).hasCompletedInitialLoad ||
      !ref.read(upcomingMoviesProvider.notifier).hasCompletedInitialLoad;
});