# Práctica 04 — TokTik: Video App - Reproducción automática de videos

**Materia:** Desarrollo Móvil Integral  
**Número de control:** 230040  
**Fecha:** Octubre 2026

---

## Descripción

Aplicación móvil desarrollada en Flutter inspirada en TikTok. Permite reproducir videos de forma automática en pantalla completa con desplazamiento vertical. Incluye sistema de temas estacionales que adapta colores e ícono de la app dependiendo del mes del año, y un filtro lógico que excluye videos con datos inconsistentes (más likes que visualizaciones).

### 📊 Diagramas de Arquitectura Interactivos (GitHub Pages)

Accede a la visualización interactiva de arquitectura con especificación **Archfy**, inspector de nodos y estilos diferenciados:

- 🟢 **[Diagrama 1: Flujo de Videos Locales (Provider Directo)](https://danny88e.github.io/Practicas-DMI-230040/Practica%204/TokTik/architecture-diagram.html#local)**  
  *Modo offline, 14 assets locales, filtro lógico `isValid` (likes &le; views) y persistencia en `SharedPreferences`.*
- 🟣 **[Diagrama 2: Flujo con APIs Externas (Clean Architecture & DataSources)](https://danny88e.github.io/Practicas-DMI-230040/Practica%204/TokTik/architecture-diagram.html#api)**  
  *Inversión de dependencias (SOLID DIP), orquestador multi-fuente (`Dio`), YouTube Data API v3, Pixabay Video API y Pexels.*
- 🌐 **[Abrir Visor de Arquitectura Completo (HTML Local)](./architecture-diagram.html)**

---

## Funcionalidades

- **Splash Screen de 3 segundos con sonido estacional**:
  - 🎃 **Octubre**: Logo Halloween (`Logo_TokTik_Octubre.jfif`) + audio temático (`OctubreP4.mpeg`).
  - 🎄 **Diciembre**: Logo Navideño (`Logo_TokTik_Diciembre.jfif`) + audio navideño (`DiciembreP4.mpeg`).
  - 💝 **Febrero**: San Valentín con paleta rosa/carmesí.
  - 📱 **Resto del año**: Logo estándar TokTik.
- **Mecanismo de Prueba de Temporadas**: Botón interactivo en el AppBar que permite forzar cualquier temporada y la persiste en `SharedPreferences`.
- **Botón de Silenciar/Activar Sonido (Mute/Unmute)**: Ubicado en la columna lateral derecha de interacción del video con `ValueNotifier`.
- **Botón Central Play/Pause Visible**: Botón circular interactivo con fondo translúcido y borde que muestra claramente el ícono de Pausa durante la reproducción y de Play al estar pausado, permitiendo alternar la reproducción con un tap.
- **Descripción Extensa con Desplazamiento Vertical**: Botón `... más` que despliega un contenedor scrollable vertical (`SingleChildScrollView` con scrollbar).
- **Desplazamiento Lateral**: Navegación horizontal fluida (`PageView` lateral) entre **For You**, **Discovery** y **Favoritos**, además de un carrusel horizontal en Discovery.
- **Persistencia de Likes y Vistas**: Almacena el número exacto de likes y vistas en `SharedPreferences` persistiendo al reiniciar la app.
- **3 DataSources Externos**: Consumo de videos mediante **YouTube Data API v3**, **Pexels Videos API** y **Pixabay Video API** bajo principios de Clean Architecture.
- **Filtrado de videos ilógicos**: Exclusión automática de videos donde `likes > views`.

---

## Tecnologías

| Tecnología | Uso |
|---|---|
| Flutter / Dart | Framework móvil |
| Material Design 3 | UI y sistema de temas dinámicos |
| `provider` ^6.1.5 | Gestión de estado reactivo |
| `video_player` ^2.9.1 | Reproductor de videos MP4 (local y red) |
| `audioplayers` ^6.1.0 | Reproducción de audios estacionales en Splash |
| `youtube_player_flutter` ^9.1.1 | Reproductor embebido de YouTube |
| `dio` ^5.4.0 | Cliente HTTP para APIs de Pexels, Pixabay y YouTube |
| `shared_preferences` ^2.3.2 | Persistencia de likes, vistas, favoritos y temporadas |
| `cached_network_image` ^3.4.1 | Caché de miniaturas remotas |
| `animate_do` ^3.3.4 | Animaciones fluidas |
| `intl` ^0.19.0 | Formato numérico compacto (K, M) |

---

## Estructura del proyecto

```
lib/
├── main.dart                            ← Entrada de la app + tema estacional
├── config/
│   ├── helpers/
│   │   └── human_formats.dart           ← Formato numérico compacto (K, M)
│   └── theme/
│       └── app_theme.dart               ← Temas Halloween / Navidad / Normal
├── domain/
│   └── entities/
│       └── video_post.dart              ← Entidad VideoPost + getter isValid
├── infrastructure/
│   └── models/
│       └── local_video_model.dart       ← Modelo de datos locales
├── shared/
│   └── data/
│       └── local_video_posts.dart       ← Lista de 14 videos con datos
└── presentation/
    ├── providers/
    │   └── discover_provider.dart       ← Estado + filtrado de videos ilógicos
    ├── screens/
    │   └── discover/
    │       └── discover_screen.dart     ← Pantalla principal con ícono dinámico
    └── widgets/
        ├── shared/
        │   ├── video_scrollable_view.dart ← PageView vertical de videos
        │   └── video_buttons.dart         ← Botones likes / vistas / disco
        └── video/
            ├── fullscreen_player.dart     ← Reproductor a pantalla completa
            └── video_background.dart      ← Gradiente oscuro sobre el video
```

---

## Videos — Descarga desde Google Drive

> Los archivos de video **no están incluidos en el repositorio** porque algunos superan el límite de 100 MB de GitHub (`7.mp4` = ~112 MB).

📁 **Carpeta de Drive con todos los videos:**  
👉 [https://drive.google.com/drive/folders/1UIfiS2BddDjaQhLNDF1gzXh5rHRjgOhO?usp=sharing](https://drive.google.com/drive/folders/1UIfiS2BddDjaQhLNDF1gzXh5rHRjgOhO?usp=sharing)

Antes de ejecutar la app, descarga los 14 videos y colócalos en:
```
Practica 4/TokTik/assets/videos/
```
Los archivos deben nombrarse exactamente: `1.mp4`, `2.mp4`, ..., `14.mp4`

---

## Cómo ejecutar

```bash
# 1. Descarga los videos desde Drive y colócalos en assets/videos/

# 2. Entra a la carpeta del proyecto:
cd "Practica 4/TokTik"

# 3. Instalar dependencias
flutter pub get

# 4. Ejecutar en dispositivo o emulador
flutter run

# Ejecutar en Chrome (web)
flutter run -d chrome
```

---

## Explicación de cómo funciona el cambio de ícono y estilos, y exclusión de videos con características ilógicas

### 🎨 Cambio de estilos y temas según la fecha

La clase `AppTheme` (en `lib/config/theme/app_theme.dart`) utiliza un `enum AppSeason` con tres valores posibles: `halloween`, `christmas` y `normal`.

El getter estático `currentSeason` consulta `DateTime.now().month` para determinar qué temporada está activa:

```dart
static AppSeason get currentSeason {
  final now = DateTime.now();
  final month = now.month;

  if (month == 10) return AppSeason.halloween;  // Todo octubre
  if (month == 12) return AppSeason.christmas;   // Todo diciembre
  return AppSeason.normal;
}
```

Dependiendo de la temporada retornada, el método `getTheme()` aplica uno de tres `ThemeData` distintos:

| Temporada | Mes | Color primario | Color fondo | Efecto |
|---|---|---|---|---|
| 🎃 Halloween | Octubre | Naranja `#FF6B00` | Morado oscuro `#0D0016` | Resplandor naranja en texto |
| 🎄 Navidad | Diciembre | Rojo `#CC0000` | Rojo muy oscuro `#0D0000` | Resplandor dorado en texto |
| 📅 Normal | Resto | Verde `#1DB954` | Negro estándar | Sin efectos especiales |

Este tema es pasado directamente a `MaterialApp` en `main.dart`:

```dart
theme: AppTheme().getTheme(),
```

---

### 🖼️ Cambio de ícono de la aplicación según la fecha

El getter estático `currentAppIcon` en `AppTheme` retorna la ruta del asset correspondiente a la temporada activa:

```dart
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
```

Este ícono se muestra en la `AppBar` de `DiscoverScreen`, donde se carga dinámicamente con `Image.asset`:

```dart
Image.asset(
  AppTheme.currentAppIcon,
  width: 36,
  height: 36,
  fit: BoxFit.cover,
)
```

> **Nota:** El cambio del ícono del launcher (el que aparece en la pantalla de inicio del dispositivo) en Flutter requiere modificar los archivos nativos de Android/iOS con herramientas como `flutter_launcher_icons`. Lo implementado aquí es el ícono dentro de la interfaz de la app (AppBar), que cambia automáticamente en tiempo de ejecución según la fecha.

---

### 🚫 Exclusión de videos con características ilógicas (likes > views)

La entidad `VideoPost` (en `lib/domain/entities/video_post.dart`) cuenta con un getter llamado `isValid`:

```dart
bool get isValid => likes <= views;
```

Este getter implementa la regla lógica: **un video no puede tener más likes que visualizaciones**, ya que es imposible dar like a un video que no se ha visto.

En `DiscoverProvider` (en `lib/presentation/providers/discover_provider.dart`), al cargar los videos se aplica un filtro con `.where()`:

```dart
final List<VideoPost> validVideos = allVideos.where(
  (video) => video.isValid
).toList();
```

**Resultado del filtrado con los datos actuales:**

| Video | Likes | Views | ¿Válido? |
|---|---|---|---|
| Subiendo escaleras automáticas | 23,230 | 1,523 | ❌ Excluido |
| Planta apreciada por peatones | 24,230 | 1,343 | ❌ Excluido |
| Que borroso veo todo! | 21,564,320 | 123,563 | ❌ Excluido |
| ¿Esto es trigo? | 320 | 2,300 | ✅ Mostrado |
| El COVID no me afecta | 3,230 | 31,030 | ✅ Mostrado |
| No quiero ir a trabajar | 10 | 330 | ✅ Mostrado |
| Limpiar nunca fue tan divertido | 1,320 | 33,032 | ✅ Mostrado |
| ¿Ya llegamos a la India? | 342 | 3,332 | ✅ Mostrado |
| Esta tortuga es mi ídola | 845 | 1,231 | ✅ Mostrado |
| El mejor gato | 214 | 1,231 | ✅ Mostrado |
| Jugando xbox | 2,135 | 12,312 | ✅ Mostrado |
| Bonito gato | 678 | 987 | ✅ Mostrado |
| Gato dormilon | 8,899 | 43,212 | ✅ Mostrado |
| Tigre muy amable :3 | 23 | 123 | ✅ Mostrado |

De los 14 videos, **3 son excluidos** por ser ilógicos y **11 son mostrados**.

---

## Assets utilizados

```
assets/
├── icons/
│   ├── Logo_TokTik.jfif            ← Ícono normal (resto del año)
│   ├── Logo_TokTik_Octubre.jfif    ← Ícono Halloween (Octubre)
│   └── Logo_TokTik_Diciembre.jfif  ← Ícono Navidad (Diciembre)
└── videos/
    ├── 1.mp4 – 14.mp4              ← Videos de la app
```

---

## Arquitectura del proyecto

### Diagrama de arquitectura — práctica 04

### Evidencia Diagrama de Arquitectura

#### Realizado por

**Luis Daniel Suarez Escamilla 230040**  
@[Danny88e](https://github.com/Danny88e)