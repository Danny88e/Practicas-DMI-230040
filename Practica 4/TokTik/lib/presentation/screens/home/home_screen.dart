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
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    if (index == 2) {
      context.read<FavoritesProvider>().refresh();
    }
  }

  void _onDestinationSelected(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    if (index == 2) {
      context.read<FavoritesProvider>().refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // PageView horizontal: permite desplazamiento lateral entre For You, Discovery y Favoritos
      body: PageView(
        controller: _pageController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        onPageChanged: _onPageChanged,
        children: const [
          DiscoverScreen(),
          DiscoveryScreen(),
          FavoritesScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
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
