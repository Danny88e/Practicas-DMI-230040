import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cinemapedia/config/constants/app_localizations.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';

class CustomBottomNavigation extends ConsumerWidget {
  final int currentIndex;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
  });

  void onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home/0');
        break;
      case 1:
        context.go('/home/1');
        break;
      case 2:
        context.go('/home/2');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final currentLang = ref.watch(languageProvider);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (value) => onItemTapped(context, value),
      elevation: 4,
      selectedItemColor: colors.primary,
      unselectedItemColor: colors.onSurface.withOpacity(0.6),
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          activeIcon: const Icon(Icons.home),
          label: AppLocalizations.get('nav_home', currentLang),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.thumb_up_alt_outlined),
          activeIcon: const Icon(Icons.thumb_up_alt),
          label: AppLocalizations.get('nav_popular', currentLang),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.favorite_outline),
          activeIcon: const Icon(Icons.favorite),
          label: AppLocalizations.get('nav_favorites', currentLang),
        ),
      ],
    );
  }
}
