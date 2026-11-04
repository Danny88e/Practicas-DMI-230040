import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cinemapedia/domain/entities/movie.dart';

import 'package:cinemapedia/presentation/delegates/search_movie_delegate.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:cinemapedia/presentation/widgets/shared/country_config_modal.dart';

class CustomAppbar extends ConsumerWidget {
  const CustomAppbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final colors = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(context).textTheme.titleMedium;
    // País actualmente seleccionado (para mostrar la bandera en el botón)
    final selectedCountry = ref.watch(selectedCountryProvider);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric( horizontal: 10 ),
        child: SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              // Logo de la app cargado desde assets/logos/
              Image.asset(
                'assets/logos/Cinemapedia_logo.png',
                height: 32,
                errorBuilder: (context, error, stackTrace) =>
                    Icon( Icons.movie_outlined, color: colors.primary ),
              ),
              const SizedBox( width: 8 ),
              Text('Cinemapedia 230040', style: titleStyle ),
      
              const Spacer(),

              // Botón de Configuración de País (reemplaza botón de temáticas)
              IconButton(
                tooltip: 'Configuración de País',
                onPressed: () => showCountryConfigModal(context),
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getFlag(selectedCountry),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
      
              // Botón de búsqueda
              IconButton(onPressed: () {

                final searchedMovies = ref.read( searchedMoviesProvider );
                final searchQuery = ref.read(searchQueryProvider);
                
                showSearch<Movie?>(
                  query: searchQuery,
                  context: context, 
                  delegate: SearchMovieDelegate(
                    initialMovies: searchedMovies,
                    searchMovies: ref.read( searchedMoviesProvider.notifier ).searchMoviesByQuery
                  )
                ).then((movie) {
                  if ( movie == null ) return;

                  context.push('/movie/${ movie.id }');
                });

              }, 
              icon: const Icon(Icons.search)
              )
            ],
          ),
        ),
      )
    );
  }

  /// Devuelve la bandera emoji para el código de país dado
  String _getFlag(String countryCode) {
    const flags = {
      'MX': '🇲🇽',
      'GB': '🇬🇧',
      'JP': '🇯🇵',
      'NG': '🇳🇬',
      'AU': '🇦🇺',
    };
    return flags[countryCode] ?? '🌍';
  }
}
