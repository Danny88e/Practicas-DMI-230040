import 'package:go_router/go_router.dart';
import 'package:cinemapedia/presentation/screens/screens.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    // Pantalla de bienvenida animada (Splash Screen)
    GoRoute(
      path: '/splash',
      name: SplashScreen.name,
      builder: (context, state) => const SplashScreen(),
    ),

    // Pantalla principal con pestañas (Inicio, Populares, Favoritos)
    GoRoute(
      path: '/home/:page',
      name: HomeScreen.name,
      builder: (context, state) {
        final pageIndex = int.tryParse(state.pathParameters['page'] ?? '0') ?? 0;
        return HomeScreen(pageIndex: pageIndex);
      },
      routes: [
        // Detalle de película / serie
        GoRoute(
          path: 'movie/:id',
          name: MovieScreen.name,
          builder: (context, state) {
            final movieId = state.pathParameters['id'] ?? 'no-id';
            return MovieScreen(movieId: movieId);
          },
        ),
      ],
    ),

    // Redirección de raíz al Splash Screen
    GoRoute(
      path: '/',
      redirect: (_, __) => '/splash',
    ),
  ],
);
