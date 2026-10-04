import 'package:flutter/material.dart';

/// Enum para identificar la temporada activa según la fecha actual.
enum AppSeason { halloween, christmas, normal }

class AppTheme {

  /// Determina la temporada activa basándose en la fecha del sistema.
  static AppSeason get currentSeason {
    final now = DateTime.now();
    final month = now.month;

    if (month == 10) return AppSeason.halloween;   // Octubre → Halloween
    if (month == 12) return AppSeason.christmas;    // Diciembre → Navidad
    return AppSeason.normal;
  }

  /// Retorna el asset del ícono correspondiente a la temporada actual.
  static String get currentAppIcon {
    switch (currentSeason) {
      case AppSeason.halloween:
        return 'assets/icons/Logo_TokTik_Octubre.jfif';
      case AppSeason.christmas:
        return 'assets/icons/Logo_TokTik_Diciembre.jfif';
      case AppSeason.normal:
        return 'assets/icons/Logo_TokTik.jfif';
    }
  }

  /// Genera el ThemeData apropiado según la temporada actual.
  ThemeData getTheme() {
    switch (currentSeason) {
      case AppSeason.halloween:
        return _halloweenTheme();
      case AppSeason.christmas:
        return _christmasTheme();
      case AppSeason.normal:
        return _normalTheme();
    }
  }

  // ─────────────────────────────────────────────
  // Tema Normal (todo el año fuera de temporada)
  // ─────────────────────────────────────────────
  ThemeData _normalTheme() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1DB954),
      brightness: Brightness.dark,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
      ),
    ),
  );

  // ─────────────────────────────────────────────
  // Tema Halloween (todo Octubre)
  // Colores: naranja calabaza, morado oscuro, negro
  // ─────────────────────────────────────────────
  ThemeData _halloweenTheme() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: const Color(0xFFFF6B00),        // naranja calabaza
      onPrimary: Colors.black,
      secondary: const Color(0xFF9B30FF),       // morado halloween
      onSecondary: Colors.white,
      error: const Color(0xFFCF6679),
      onError: Colors.black,
      surface: const Color(0xFF1A0A2E),         // fondo morado muy oscuro
      onSurface: const Color(0xFFFFE0B2),       // texto naranja claro
      surfaceContainerHighest: const Color(0xFF2D1B4E),
      outline: const Color(0xFFFF6B00),
    ),
    scaffoldBackgroundColor: const Color(0xFF0D0016),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A0A2E),
      foregroundColor: Color(0xFFFF6B00),
    ),
    iconTheme: const IconThemeData(color: Color(0xFFFF6B00)),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: Color(0xFFFFE0B2),
        fontSize: 18,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(color: Color(0xFFFF6B00), blurRadius: 8),
          Shadow(color: Colors.black87, blurRadius: 4),
        ],
      ),
      bodyMedium: TextStyle(color: Color(0xFFFFE0B2)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Color(0xFFFF6B00),
    ),
  );

  // ─────────────────────────────────────────────
  // Tema Navidad (todo Diciembre)
  // Colores: rojo navideño, verde pino, dorado
  // ─────────────────────────────────────────────
  ThemeData _christmasTheme() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: const Color(0xFFCC0000),         // rojo navideño
      onPrimary: Colors.white,
      secondary: const Color(0xFF2E7D32),        // verde pino
      onSecondary: Colors.white,
      error: const Color(0xFFCF6679),
      onError: Colors.black,
      surface: const Color(0xFF1B0000),          // fondo rojo muy oscuro
      onSurface: const Color(0xFFFFF8E1),        // texto crema/dorado
      surfaceContainerHighest: const Color(0xFF3B0000),
      outline: const Color(0xFFFFD700),
    ),
    scaffoldBackgroundColor: const Color(0xFF0D0000),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1B0000),
      foregroundColor: Color(0xFFFFD700),
    ),
    iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: Color(0xFFFFF8E1),
        fontSize: 18,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(color: Color(0xFFFFD700), blurRadius: 8),
          Shadow(color: Color(0xFFCC0000), blurRadius: 4),
        ],
      ),
      bodyMedium: TextStyle(color: Color(0xFFFFF8E1)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Color(0xFFFFD700),
    ),
  );
}