# Widgets App — Práctica 5

**Desarrollo Móvil Integral (DMI) · Matrícula 230040**

Aplicación Flutter que demuestra una amplia variedad de widgets de Material Design 3, gestión de estado con Riverpod y navegación declarativa con GoRouter.

---

## 📋 Descripción del Proyecto

`widgets_app` es una aplicación de catálogo de widgets construida para la **Práctica 5** del curso de Desarrollo Móvil Integral. Cada pantalla explora un conjunto específico de widgets o patrones de Flutter, con el objetivo de consolidar el conocimiento práctico de:

- **Material Design 3** (theming dinámico, color seeds, dark/light mode).
- **Navegación declarativa** con `go_router`.
- **Gestión de estado** reactiva con `flutter_riverpod`.
- **Animaciones** de entrada con `animate_do`.

---

## 🏗️ Arquitectura

```
lib/
├── config/
│   ├── router/
│   │   └── app_router.dart          # Configuración de GoRouter (todas las rutas)
│   └── theme/
│       └── app_theme.dart           # AppTheme, colores, dark/light
├── presentation/
│   ├── providers/
│   │   ├── counter_provider.dart    # StateProvider para el contador
│   │   └── theme_provider.dart      # StateNotifierProvider + ThemeNotifier
│   └── screens/
│       ├── home/
│       │   └── home_screen.dart
│       ├── buttons/
│       │   └── buttons_screen.dart
│       ├── cards/
│       │   └── cards_screen.dart
│       ├── progress/
│       │   └── progress_screen.dart
│       ├── snackbar/
│       │   └── snackbar_screen.dart
│       ├── animated_container/
│       │   └── animated_container_screen.dart
│       ├── ui_controls/
│       │   └── ui_controls_screen.dart
│       ├── app_tutorial/
│       │   └── app_tutorial_screen.dart
│       ├── infinite_scroll/
│       │   └── infinite_scroll_screen.dart
│       ├── counter/
│       │   └── counter_screen.dart
│       └── theme_changer/
│           └── theme_changer_screen.dart
└── main.dart
```

### Patrones utilizados

| Patrón | Uso |
|--------|-----|
| **Provider (Riverpod)** | Estado global: contador y tema |
| **StateNotifier** | Lógica del cambio de tema (color + modo oscuro) |
| **GoRouter** | Rutas declarativas con nombres de pantalla |
| **StatefulWidget** | Estado local: AnimatedContainer, InfiniteScroll, Tutorial |
| **ConsumerWidget** | Lectura/escritura reactiva de providers |
| **StreamBuilder** | Indicadores de progreso en tiempo real |

---

## 🗺️ Diagrama de Arquitectura

> [**Ver Diagrama Interactivo en GitHub Pages →**](https://TU-USUARIO.github.io/Practicas-DMI-230040/Practica-05/widgets_app/architecture-diagram.html)

El diagrama cubre dos vistas navegables en un solo documento:
- **Arquitectura General** — Flujo de capas Config → Presentation → State con dependencias externas
- **Arquitectura Específica** — Detalle de las 11 pantallas, providers Riverpod y tabla de rutas GoRouter

---

## 📱 Demostración en Línea (Appetize.io)

> [**Probar Widgets App en Appetize.io →**](https://appetize.io/app/TU_ENLACE_AQUI)

Permite ejecutar e interactuar con la aplicación en un emulador virtual directamente desde el navegador web. Consultar [Explicacion.md](Explicacion.md) para ver la guía de generación del APK mediante GitHub Actions y publicación en Appetize.

---

## 🚀 Instalación y Ejecución

### Requisitos

- Flutter SDK ≥ 3.10.0
- Dart SDK ≥ 3.0.0
- Android Studio / VS Code con extensión Flutter

### Pasos

```bash
# 1. Clonar / copiar el proyecto
cd "Practica 5/widgets_app"

# 2. Instalar dependencias
flutter pub get

# 3. Ejecutar en dispositivo/emulador
flutter run

# 4. (Opcional) Generar APK de release
flutter build apk --release
```

---

## 📦 Dependencias Principales

| Paquete | Versión | Uso |
|---------|---------|-----|
| `go_router` | ^17.5.0 | Navegación declarativa |
| `flutter_riverpod` | ^3.4.3 | Gestión de estado |
| `animate_do` | ^5.1.0 | Animaciones de entrada (FadeIn, ZoomIn, etc.) |

---

## 🖼️ Pantallas y Widgets Demostrados

### 1. Home Screen
- `Scaffold` + `Drawer` (NavigationDrawer con secciones agrupadas)
- `ListView.builder` + `ListTile` con iconos y subtítulos

### 2. Buttons Screen
- `ElevatedButton`, `FilledButton`, `OutlinedButton`, `TextButton`
- `IconButton`, `FloatingActionButton`
- `CustomButton` (Material + InkWell para efecto ripple personalizado)

### 3. Cards Screen
- `Card` con 4 variantes: `elevated`, `outlined`, `filled`, imagen de fondo
- `ClipRRect`, `Ink`, `InkWell`

### 4. Progress Screen
- `CircularProgressIndicator` (determinado e indeterminado)
- `LinearProgressIndicator`
- `StreamBuilder` con `Stream.periodic`

### 5. SnackBar Screen
- `ScaffoldMessenger.of(context).showSnackBar`
- `showDialog` con `AlertDialog` (acciones personalizadas)
- `showAboutDialog`

### 6. Animated Container
- `AnimatedContainer` con transiciones de color, tamaño y radio de borde
- `Random` para generación de valores aleatorios
- `GestureDetector` para disparar la animación

### 7. UI Controls Screen
- `SwitchListTile`
- `RadioListTile` agrupado en un widget `RadioGroup`
- `CheckboxListTile`
- `ExpansionTile`

### 8. App Tutorial Screen
- `PageView` con `PageController`
- Animaciones `FadeInRight` de `animate_do`
- Indicadores de página personalizados
- Imágenes locales desde `assets/images/`

### 9. Infinite Scroll Screen
- `ScrollController` para detectar el final de la lista
- `RefreshIndicator` para pull-to-refresh
- `FadeInImage` con placeholder GIF local (`assets/images/jar-loading.gif`) y `NetworkImage`
- `animate_do` (SpinPerfect, FadeIn) en el FAB

### 10. Counter Screen (Riverpod)
- `StateProvider<int>` definido en `counter_provider.dart`
- `ConsumerWidget` con `ref.watch` y `ref.read`

### 11. Theme Changer Screen (Riverpod)
- `StateNotifierProvider` con `ThemeNotifier`
- `RadioListTile` para selección de color seed
- `SwitchListTile` para toggle de modo oscuro

---

## 🎨 Sistema de Temas

El tema es completamente dinámico y gestionado por Riverpod:

```dart
// theme_provider.dart
class ThemeNotifier extends StateNotifier<AppTheme> {
  void changeColorIndex(int index) => ...;
  void toggleDarkMode() => ...;
}
```

`AppTheme` genera un `ThemeData` con `ColorScheme.fromSeed(...)` para aprovechar Material You.

---

## 📁 Assets

```
assets/
└── images/
    └── jar-loading.gif    # Placeholder GIF para FadeInImage (Infinite Scroll)
```

---

## 📸 Capturas de Pantalla

> _Agregar capturas de pantalla aquí_

| Home | Buttons | Cards |
|------|---------|-------|
| ![Home]() | ![Buttons]() | ![Cards]() |

| Progress | UI Controls | Infinite Scroll |
|----------|-------------|-----------------|
| ![Progress]() | ![UI Controls]() | ![Infinite Scroll]() |

---

## 👤 Autor

**Matrícula:** 230040  
**Curso:** Desarrollo Móvil Integral  
**Práctica:** 5 — Widgets App  

---

## 📄 Licencia

Proyecto académico — uso exclusivo para fines educativos.
