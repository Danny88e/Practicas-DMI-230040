// Tema de la aplicación SportBot.
// Usa Material 3 con una paleta azul deportiva.

import 'package:flutter/material.dart';

// Color base para el tema deportivo (azul oscuro)
const Color _customColor = Color(0xFF1565C0);

const List<Color> _colorThemes = [
  _customColor,       // 0 - Azul deportivo (por defecto)
  Colors.teal,        // 1
  Colors.green,       // 2
  Colors.orange,      // 3
  Colors.purple,      // 4
];

class AppTheme {
  final int selectedColor;

  AppTheme({this.selectedColor = 0})
      : assert(
          selectedColor >= 0 && selectedColor <= _colorThemes.length - 1,
          'Colors must be between 0 and ${_colorThemes.length - 1}',
        );

  ThemeData theme() {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: _colorThemes[selectedColor],
      brightness: Brightness.dark, // Tema oscuro al estilo de las capturas
    );
  }
}
