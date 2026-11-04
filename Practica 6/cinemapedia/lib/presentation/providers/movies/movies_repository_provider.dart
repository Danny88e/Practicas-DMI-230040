import 'package:cinemapedia/config/constants/countries_config.dart';
import 'package:cinemapedia/infrastructure/datasources/moviedb_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cinemapedia/infrastructure/repositories/movie_repository_impl.dart';
import 'package:cinemapedia/presentation/providers/country/country_provider.dart';

/// Repositorio de películas que reacciona al país seleccionado.
/// Cuando cambia el país, el datasource se recrea con el lenguaje correcto
/// para que solo cambien los strings de las películas (la UI permanece igual).
final movieRepositoryProvider = Provider((ref) {
  final countryCode = ref.watch(selectedCountryProvider);
  final language = CountriesConfig.getLanguageCode(countryCode);
  return MovieRepositoryImpl( MoviedbDatasource(language: language) );
});


