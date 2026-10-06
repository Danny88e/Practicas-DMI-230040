import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toktik/presentation/providers/favorites_provider.dart';
import 'package:toktik/presentation/screens/discover/discover_screen.dart';
import 'package:toktik/presentation/screens/discovery/discovery_screen.dart';
import 'package:toktik/presentation/screens/favorites/favorites_screen.dart';

/// Pantalla raíz de la app con Navbar de 3 secciones.
///
/// PUNTO 6 — Navbar:
///   0: For You     → DiscoverScreen  (local + Pexels + Pixabay)
///   1: Discovery   → DiscoveryScreen (YouTube)
///   2: Favoritos   → FavoritesScreen (videos con like)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack mantiene el estado de cada pestaña al navegar
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          DiscoverScreen(),
          DiscoveryScreen(),
          FavoritesScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          // Al entrar a Favoritos, refresca la lista desde SharedPreferences
          if (index == 2) {
            context.read<FavoritesProvider>().refresh();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'For You',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Discovery',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
        ],
      ),
    );
  }
}
