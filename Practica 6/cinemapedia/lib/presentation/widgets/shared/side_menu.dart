import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cinemapedia/config/constants/app_languages.dart';
import 'package:cinemapedia/config/constants/app_localizations.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';

class SideMenu extends ConsumerWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final currentLang = ref.watch(languageProvider);
    final contentType = ref.watch(contentTypeProvider);

    return NavigationDrawer(
      children: [
        // Drawer Header con Logo e información del estudiante
        DrawerHeader(
          decoration: BoxDecoration(
            color: colors.primary,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Image.asset(
                'assets/logos/Cinemapedia_logo.png',
                height: 48,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.movie_creation_outlined, color: colors.onPrimary, size: 48),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.get('app_title', currentLang),
                style: textTheme.titleMedium?.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                AppLocalizations.get('student_info', currentLang),
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onPrimary.withOpacity(0.85),
                ),
              ),
            ],
          ),
        ),

        // Navegación principal
        NavigationDrawerDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: Text(AppLocalizations.get('nav_home', currentLang)),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.thumb_up_alt_outlined),
          selectedIcon: const Icon(Icons.thumb_up_alt),
          label: Text(AppLocalizations.get('nav_popular', currentLang)),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.favorite_outline),
          selectedIcon: const Icon(Icons.favorite),
          label: Text(AppLocalizations.get('nav_favorites', currentLang)),
        ),

        const Divider(indent: 16, endIndent: 16),

        // Sección: Configuración
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            AppLocalizations.get('settings', currentLang),
            style: textTheme.titleSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Subsección: Contenido (Películas / Series)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    contentType == 'movie' ? Icons.movie_outlined : Icons.tv,
                    color: colors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    contentType == 'movie'
                        ? AppLocalizations.get('movies', currentLang)
                        : AppLocalizations.get('series', currentLang),
                    style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment<String>(
                    value: 'movie',
                    icon: const Icon(Icons.movie, size: 16),
                    label: Text(AppLocalizations.get('movies', currentLang)),
                  ),
                  ButtonSegment<String>(
                    value: 'tv',
                    icon: const Icon(Icons.tv, size: 16),
                    label: Text(AppLocalizations.get('series', currentLang)),
                  ),
                ],
                selected: {contentType},
                onSelectionChanged: (Set<String> newSelection) {
                  ref.read(contentTypeProvider.notifier).setContentType(newSelection.first);
                },
              ),
            ],
          ),
        ),

        const Divider(indent: 16, endIndent: 16),

        // Subsección: Idioma
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            AppLocalizations.get('language', currentLang),
            style: textTheme.labelLarge?.copyWith(
              color: colors.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Lista de 5 idiomas interactivos
        ...AppLanguages.supported.map((lang) {
          final isSelected = lang['code'] == currentLang;
          return ListTile(
            leading: Text(
              lang['flag']!,
              style: const TextStyle(fontSize: 24),
            ),
            title: Text(
              lang['label']!,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? colors.primary : null,
              ),
            ),
            trailing: isSelected
                ? Icon(Icons.check_circle, color: colors.primary)
                : null,
            tileColor: isSelected ? colors.primaryContainer.withOpacity(0.3) : null,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            onTap: () {
              ref.read(languageProvider.notifier).setLanguage(lang['code']!);
              Navigator.of(context).pop(); // Cierra el Drawer
            },
          );
        }),

        const Divider(indent: 16, endIndent: 16),

        // Acerca de
        ListTile(
          leading: Icon(Icons.info_outline, color: colors.secondary),
          title: Text(AppLocalizations.get('about', currentLang)),
          subtitle: Text(AppLocalizations.get('about_desc', currentLang)),
          onTap: () => Navigator.of(context).pop(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

