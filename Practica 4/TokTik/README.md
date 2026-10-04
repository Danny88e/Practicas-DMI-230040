# Práctica 04 — TokTik: Video App - Reproducción automática de videos

**Materia:** Desarrollo Móvil Integral  
**Número de control:** 230040  
**Fecha:** Octubre 2026

---

## Descripción

Aplicación móvil desarrollada en Flutter inspirada en TikTok. Permite reproducir videos de forma automática en pantalla completa con desplazamiento vertical. Incluye sistema de temas estacionales que adapta colores e ícono de la app dependiendo del mes del año, y un filtro lógico que excluye videos con datos inconsistentes (más likes que visualizaciones).

---

## Funcionalidades

- Reproducción automática de videos en pantalla completa (vertical scroll).
- Pausar/reanudar video con un toque en pantalla.
- Visualización de **likes** y **vistas** con formato compacto (K, M).
- Ícono de disco rotatorio animado en cada video.
- **Filtrado de videos ilógicos**: se excluyen videos donde `likes > views`.
- **Temas estacionales automáticos** según el mes del año:
  - 🎃 **Octubre** → Tema Halloween (naranja, morado oscuro)
  - 🎄 **Diciembre** → Tema Navidad (rojo, verde pino, dorado)
  - 📅 **Resto del año** → Tema normal oscuro
- **Ícono de la app dinámico** que cambia según la temporada activa.

---

## Tecnologías

| Tecnología | Uso |
|---|---|
| Flutter / Dart | Framework móvil |
| Material Design 3 | UI y sistema de temas |
| `provider` ^6.1.5 | Gestión de estado |
| `video_player` ^2.9.1 | Reproducción de video |
| `animate_do` ^3.3.4 | Animación del ícono |
| `intl` ^0.19.0 | Formato numérico compacto |

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