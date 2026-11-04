import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: colors.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Logo en el drawer
                Image.asset(
                  'assets/logos/Cinemapedia_logo.png',
                  height: 48,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.movie_outlined, color: colors.onPrimary, size: 48),
                ),
                const SizedBox(height: 8),
                Text(
                  'Cinemapedia 230040',
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Luis Daniel Suarez Escamilla',
                  style: textTheme.bodySmall?.copyWith(color: colors.onPrimary),
                ),
              ],
            ),
          ),

          // Inicio
          ListTile(
            leading: Icon(Icons.home_outlined, color: colors.primary),
            title: const Text('Inicio'),
            onTap: () {
              context.go('/');
              Scaffold.of(context).closeDrawer();
            },
          ),

          // Categorías
          ListTile(
            leading: Icon(Icons.label_outline, color: colors.primary),
            title: const Text('Categorías'),
            onTap: () {
              Scaffold.of(context).closeDrawer();
            },
          ),

          // Favoritos
          ListTile(
            leading: Icon(Icons.favorite_outline, color: colors.primary),
            title: const Text('Favoritos'),
            onTap: () {
              Scaffold.of(context).closeDrawer();
            },
          ),

          const Divider(),

          // Acerca de
          ListTile(
            leading: Icon(Icons.info_outline, color: colors.secondary),
            title: const Text('Acerca de'),
            subtitle: const Text('Práctica 6 - DMI 230040'),
            onTap: () {
              Scaffold.of(context).closeDrawer();
            },
          ),
        ],
      ),
    );
  }
}
