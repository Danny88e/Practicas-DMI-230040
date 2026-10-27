# 📱 Widgets App — Práctica 5

> **Materia:** Desarrollo Móvil Integral (DMI)  
> **Alumno:** Luis Daniel Suarez Escamilla — **230040**  
> **Vencimiento:** 27 de Octubre de 2026 (40 firmas)

---

## 🗺 Diagrama de Arquitectura

> Diagrama interactivo generado con la librería **Archify** — visualiza capas, dependencias y flujo de navegación.

**[🔗 Ver Diagrama Interactivo en GitHub Pages](https://danny88e.github.io/Practicas-DMI-230040/Practica%205/widgets_app/architecture_diagram.html)**

---

## 📸 Capturas de Pantalla de la Aplicación

| HomeScreen | SideMenu | ButtonsScreen | CardsScreen |
| :---: | :---: | :---: | :---: |
| ![HomeScreen](docs/screens/home.png) | ![SideMenu](docs/screens/side_menu.png) | ![Buttons](docs/screens/buttons.png) | ![Cards](docs/screens/cards.png) |

| ProgressScreen | SnackbarScreen | AnimatedScreen | UiControlsScreen |
| :---: | :---: | :---: | :---: |
| ![Progress](docs/screens/progress.png) | ![Snackbars](docs/screens/snackbars.png) | ![Animated](docs/screens/animated.png) | ![UI Controls](docs/screens/ui_controls.png) |

| AppTutorialScreen | InfiniteScrollScreen | CounterScreen | ThemeChangerScreen |
| :---: | :---: | :---: | :---: |
| ![Tutorial](docs/screens/tutorial.png) | ![Infinite Scroll](docs/screens/infinite.png) | ![Counter](docs/screens/counter.png) | ![Theme Changer](docs/screens/theme_changer.png) |

---

## 📋 Descripción de la Práctica

**Widgets App** es una aplicación Flutter multiplataforma que sirve como catálogo interactivo de los principales widgets y conceptos de Flutter + Material 3. La práctica cubre:

- ✅ Gestión de estado reactivo con **Riverpod** (`StateProvider`, `StateNotifier`)
- ✅ Navegación declarativa con **GoRouter** (11 rutas nombradas)
- ✅ Theming dinámico con **Material 3** (9 colores, modo oscuro/claro)
- ✅ Animaciones con **animate_do** (`FadeIn`, `SpinPerfect`, `FadeInRight`)
- ✅ NavigationDrawer lateral reutilizable
- ✅ Scroll infinito con lazy loading y pull-to-refresh
- ✅ Tutorial onboarding con PageView

---

## 🏗 Arquitectura del Proyecto

La aplicación sigue una arquitectura **Feature-First** organizada en capas:

```
widgets_app/
└── lib/
    ├── main.dart                          # Entrypoint · ProviderScope
    ├── config/
    │   ├── menu/
    │   │   └── menu_items.dart            # Modelo MenuItem + lista const
    │   ├── router/
    │   │   └── app_router.dart            # GoRouter — 11 rutas
    │   └── theme/
    │       └── app_theme.dart             # AppTheme — Material 3
    └── presentation/
        ├── providers/
        │   ├── counter_provider.dart      # StateProvider<int>
        │   └── theme_provider.dart        # ThemeNotifier (StateNotifier)
        ├── screens/
        │   ├── screens.dart               # Barrel file exports
        │   ├── home/                      # HomeScreen (/)
        │   ├── buttons/                   # ButtonsScreen (/buttons)
        │   ├── cards/                     # CardsScreen (/cards)
        │   ├── progress/                  # ProgressScreen (/progress)
        │   ├── snackbar/                  # SnackbarScreen (/snackbars)
        │   ├── animated/                  # AnimatedScreen (/animated)
        │   ├── ui_controls/               # UiControlsScreen (/ui-controls)
        │   ├── app_tutorial/              # AppTutorialScreen (/tutorial)
        │   ├── infinite_scroll/           # InfiniteScrollScreen (/infinite)
        │   ├── counter/                   # CounterScreen (/counter-river)
        │   └── theme_changer/             # ThemeChangerScreen (/theme-changer)
        └── widgets/
            └── side_menu.dart             # NavigationDrawer reutilizable
```

---

## 📺 Pantallas Implementadas

| # | Pantalla | Ruta | Descripción |
|---|----------|------|-------------|
| 1 | **HomeScreen** | `/` | Menú principal con lista de opciones y drawer lateral |
| 2 | **ButtonsScreen** | `/buttons` | Todos los tipos de botones Material 3 (Elevated, Filled, Outlined, Text, Icon, Custom) |
| 3 | **CardsScreen** | `/cards` | Variantes de Cards como contenedores estilizados |
| 4 | **ProgressScreen** | `/progress` | CircularProgressIndicator y LinearProgressIndicator (generales y controlados) |
| 5 | **SnackbarScreen** | `/snackbars` | SnackBars, AlertDialog y showAboutDialog |
| 6 | **AnimatedScreen** | `/animated` | AnimatedContainer con cambios aleatorios de forma/color/tamaño |
| 7 | **UiControlsScreen** | `/ui-controls` | Switch, Checkbox, Radio, ListTile y más controles Material 3 |
| 8 | **AppTutorialScreen** | `/tutorial` | Onboarding con PageView de 3 slides y animaciones |
| 9 | **InfiniteScrollScreen** | `/infinite` | Lista infinita con imágenes de Picsum + pull-to-refresh |
| 10 | **CounterScreen** | `/counter-river` | Contador con Riverpod StateProvider (demo básico) |
| 11 | **ThemeChangerScreen** | `/theme-changer` | Selector de color de tema con RadioListTile |

---

## 📦 Dependencias

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8    # Íconos iOS
  go_router: ^17.5.0          # Navegación declarativa
  flutter_riverpod: ^3.4.3    # Gestión de estado reactivo
  animate_do: ^5.1.0          # Animaciones predefinidas

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

---

## 🚀 Cómo ejecutar

```bash
# 1. Instalar dependencias
flutter pub get

# 2. Ejecutar en dispositivo/emulador
flutter run

# 3. Ejecutar en web
flutter run -d chrome

# 4. Build release Android
flutter build apk --release
```

**Requisitos:**
- Flutter SDK `^3.10.0`
- Dart SDK `^3.10.0`

---

## ⚙️ Conceptos clave demostrados

### Riverpod — Gestión de Estado

```dart
// StateProvider simple (contador)
final counterProvider = StateProvider<int>((ref) => 5);

// StateNotifier (tema complejo)
class ThemeNotifier extends StateNotifier<AppTheme> {
  ThemeNotifier() : super(AppTheme());

  void toggleDarkmode() =>
    state = state.copyWith(isDarkmode: !state.isDarkmode);

  void changeColorIndex(int i) =>
    state = state.copyWith(selectedColor: i);
}
```

### GoRouter — Navegación Declarativa

```dart
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (ctx, state) => const HomeScreen()),
    GoRoute(path: '/buttons', builder: (ctx, state) => const ButtonsScreen()),
    // ... 9 rutas más
  ],
);
```

### Material 3 — Theming Dinámico

```dart
ThemeData getTheme() => ThemeData(
  useMaterial3: true,
  brightness: isDarkmode ? Brightness.dark : Brightness.light,
  colorSchemeSeed: colorList[selectedColor], // 9 colores
  appBarTheme: const AppBarTheme(centerTitle: false),
);
```

---

## 👤 Autor

**Luis Daniel Suarez Escamilla**  
Matrícula: **230040** | Universidad Tecnológica de Xicotepec de Juárez

🔗 [Repositorio GitHub](https://github.com/Danny88e/Practicas-DMI-230040)
