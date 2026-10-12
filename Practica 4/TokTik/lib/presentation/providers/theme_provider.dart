import 'package:flutter/material.dart';
import 'package:toktik/config/theme/app_theme.dart';
import 'package:toktik/services/local_storage_service.dart';

/// Provider para la gestión reactiva del tema estacional y mecanismo de pruebas.
/// Permite alternar entre la fecha actual del sistema o forzar cualquier temporada
/// persistiendo la selección en SharedPreferences.
class ThemeProvider extends ChangeNotifier {
  final AppTheme _appTheme = AppTheme();

  /// Retorna la temporada activa actual.
  AppSeason get currentSeason => AppTheme.currentSeason;

  /// Retorna el ThemeData correspondiente a la temporada activa.
  ThemeData get currentTheme => _appTheme.getTheme();

  /// Retorna el path del ícono de la app según la temporada.
  String get currentAppIcon => AppTheme.currentAppIcon;

  /// Retorna true si está usando la fecha automática del sistema.
  bool get isAutomatic => LocalStorageService.getSeasonOverride() == null;

  /// Cambia la temporada para pruebas y la guarda en SharedPreferences.
  /// Si [season] es null, vuelve a la detección automática según la fecha.
  Future<void> setSeason(AppSeason? season) async {
    final seasonName = season?.name;
    await LocalStorageService.setSeasonOverride(seasonName);
    notifyListeners();
  }
}
