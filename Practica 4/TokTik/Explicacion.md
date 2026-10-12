# Práctica 4 — TokTik: App de Videos Cortos

**Materia:** Desarrollo Móvil Integral  
**Número de control:** 230040  
**Autor:** Luis Daniel Suarez Escamilla  

---

## Índice

1. [Play/Pause](#1-playpause)
2. [Descripción y Ver más](#2-descripción-y-ver-más)
3. [Control de Sonido](#3-control-de-sonido)
4. [Contador de Vistas](#4-contador-de-vistas)
5. [Sistema de Likes](#5-sistema-de-likes)
6. [Navbar con Tres Secciones](#6-navbar-con-tres-secciones)
7. [APIs y DataSources](#7-apis-y-datasources)
8. [Sistema de Favoritos](#8-sistema-de-favoritos)
9. [Flujo Completo](#9-flujo-completo)
10. [Almacenamiento Local](#10-almacenamiento-local)
11. [Videos Locales](#11-videos-locales)
12. [Estructura de Archivos](#12-estructura-de-archivos)
13. [Paquetes Utilizados](#13-paquetes-utilizados)
14. [Configuración de APIs](#14-configuración-de-apis)
15. [Pruebas](#15-pruebas)
16. [Splash Screen Estacional](#16-splash-screen-estacional)
17. [Botón de Mute en Columna Lateral](#17-botón-de-mute-en-columna-lateral)
18. [Botón Play/Pause en el Centro de la Pantalla](#18-botón-playpause-en-el-centro-de-la-pantalla)
19. [Mecanismo de Prueba de Temporadas (LocalStorage & San Valentín)](#19-mecanismo-de-prueba-de-temporadas-localstorage--san-valentín)
20. [Persistencia del Conteo de Likes en Local Storage](#20-persistencia-del-conteo-de-likes-en-local-storage)
21. [Descripción Extensa con Desplazamiento Vertical](#21-descripción-extensa-con-desplazamiento-vertical)
22. [Desplazamiento Lateral entre Secciones y Carrusel](#22-desplazamiento-lateral-entre-secciones-y-carrusel)
23. [Diagramas de Arquitectura (Provider Local vs Repositorio y DataSources)](#23-diagramas-de-arquitectura-provider-local-vs-repositorio-y-datasources)

---

## 1. Play/Pause

### ¿Qué se implementó?
Un botón de reproducción/pausa superpuesto sobre el video. Al pausar el video aparece un ícono ▶ en el centro de la pantalla; al reproducirlo, desaparece con una animación de opacidad.

### Archivo con la lógica
`lib/presentation/widgets/video/fullscreen_player.dart` → clase `_FullScreenPlayerState`

### ¿Cómo funciona?

1. El widget `FullScreenPlayer` crea y gestiona un `VideoPlayerController`.
2. Toda la pantalla del video está envuelta en un `GestureDetector` con `onTap: _togglePlayPause`.
3. `_togglePlayPause()` llama a `controller.pause()` o `controller.play()`.
4. El ícono central usa `ValueListenableBuilder<VideoPlayerValue>` para escuchar cambios del controlador en tiempo real.
5. Cuando `value.isPlaying == false`, el ícono aparece (opacidad 1.0); cuando está reproduciendo, desaparece (opacidad 0.0).

```dart
ValueListenableBuilder<VideoPlayerValue>(
  valueListenable: controller,
  builder: (_, value, __) {
    return AnimatedOpacity(
      opacity: value.isPlaying ? 0.0 : 1.0,  // Visible solo cuando está pausado
      duration: Duration(milliseconds: 300),
      child: Center(child: Icon(Icons.play_arrow_rounded, ...)),
    );
  },
),
```

### Interacción con el reproductor
El controlador (`VideoPlayerController`) maneja el estado internamente. El widget solo le dice `.pause()` o `.play()`. El `ValueListenableBuilder` observa ese estado y actualiza el ícono sin necesidad de `setState`.

---

## 2. Descripción y "Ver más"

### ¿Cómo se almacena la descripción?
En la entidad `VideoPost` (dominio) existe el campo `description: String`. Este campo se llena desde tres fuentes:
- **Videos locales**: La descripción está en `lib/shared/data/local_video_posts.dart`.
- **Pexels**: La descripción se construye con el nombre del usuario y duración del video.
- **Pixabay**: La descripción contiene el usuario y los tags del video.
- **YouTube**: La descripción viene directamente del campo `snippet.description` de la API.

### Archivo con la lógica
`lib/presentation/widgets/video/video_description.dart`

### ¿Cómo funciona "Ver más"?

```dart
static const int _maxChars = 80;  // Límite de caracteres

bool get _hasLongDescription => description.length > _maxChars;

String get _truncated => '${description.substring(0, _maxChars)}...';
```

1. Si la descripción supera 80 caracteres, se muestra truncada con `...`.
2. Al presionar "Ver más" (`GestureDetector`), `setState` cambia `_isExpanded = true`.
3. Ahora se muestra la descripción completa.
4. Aparece el botón "Ver menos" para contraerla de nuevo.

```text
Descripción corta       → Se muestra completa, sin botón.
Descripción larga...    → Ver más
                        (tap)
Descripción completa    → Ver menos
```

---

## 3. Control de Sonido

### ¿Cómo se controla el volumen?
Mediante el método `controller.setVolume(double)` del `VideoPlayerController`.
- Volumen `0` = silenciado.
- Volumen `1` = sonido activado.

### Archivo con la lógica
`lib/presentation/widgets/video/fullscreen_player.dart` → método `_toggleMute()`

### ¿Cómo funciona el botón?
Un botón `InkWell` circular posicionado en la esquina superior derecha del video (`Positioned(top: 16, right: 16, ...)`).

```dart
bool _isMuted = true;  // Los videos inician en silencio

void _toggleMute() {
  setState(() {
    _isMuted = !_isMuted;
    controller.setVolume(_isMuted ? 0 : 1);
  });
}
```

### Estados posibles
| Estado     | Ícono   | Volumen |
|------------|---------|---------|
| Silenciado | 🔇 (`volume_off`) | 0 |
| Con sonido | 🔊 (`volume_up`)  | 1 |

**Nota:** Los videos inician en silencio (`setVolume(0)`) para no interrumpir al usuario al hacer scroll.

---

## 4. Contador de Vistas

### ¿Cuándo aumenta una vista?
Cuando el usuario hace scroll y el video pasa a ser el **video visible** en el `PageView`. Esto ocurre en el callback `onPageChanged` de `VideoScrollableView`.

```dart
PageView.builder(
  onPageChanged: (index) {
    final video = videos[index];
    onViewIncrement?.call(video.id);  // Se llama aquí
  },
)
```

### ¿Cómo se identifica cada video?
Cada `VideoPost` tiene un campo `id: String` único:
- Videos locales: `local_1`, `local_2`, ..., `local_14`
- Videos de Pexels: `pexels_{id_del_api}`
- Videos de Pixabay: `pixabay_{id_del_api}`
- Videos de YouTube: `yt_{videoId}`

Esto garantiza que no haya conflictos de IDs entre fuentes.

### ¿Cómo se guarda localmente?
Con `SharedPreferences` a través de `LocalStorageService`:

```dart
// Clave: 'views_{videoId}' → valor: int
static Future<void> incrementViews(String videoId) async {
  final current = _prefs.getInt('views_$videoId') ?? 0;
  await _prefs.setInt('views_$videoId', current + 1);
}
```

El contador persiste entre reinicios de la app.

### Tecnología de almacenamiento
**`shared_preferences`** — paquete oficial de Flutter para persistencia clave-valor.

---

## 5. Sistema de Me Gusta

### Estado inicial
Todos los videos inician sin like: el corazón está vacío (`Icons.favorite_border`).

### ¿Cómo se agrega Like?
1. El usuario presiona el corazón en `VideoButtons`.
2. `_VideoButtonsState._handleLikeTap()` cambia el estado local inmediatamente (respuesta visual instantánea).
3. Llama al callback `onLikeToggle` que invoca `DiscoverProvider.toggleLike(video)`.
4. El provider actualiza la lista, guarda el like en `SharedPreferences` y agrega el video a Favoritos.

```dart
// En VideoButtons:
void _handleLikeTap() {
  setState(() {
    _isLiked = !_isLiked;
    _likes = _isLiked ? _likes + 1 : _likes - 1;
  });
  widget.onLikeToggle?.call(video.copyWith(isLiked: _isLiked));
}
```

### ¿Cómo se elimina?
Presionar el corazón relleno (`Icons.favorite`) invierte el proceso: `isLiked = false`, `likes - 1`, se quita de Favoritos en SharedPreferences.

### Animación del corazón
```dart
AnimatedSwitcher(
  duration: Duration(milliseconds: 200),
  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
  child: Icon(
    isLiked ? Icons.favorite : Icons.favorite_border,
    key: ValueKey(isLiked),
    color: isLiked ? Colors.red : Colors.white,
  ),
),
```

---

## 6. Navbar con Tres Secciones

### Archivo con la lógica
`lib/presentation/screens/home/home_screen.dart`

### Estructura
La pantalla raíz `HomeScreen` usa un `NavigationBar` (Material 3) con 3 pestañas y un `IndexedStack` para preservar el estado de cada pestaña al navegar.

```
HomeScreen
├── IndexedStack(index: _currentIndex)
│   ├── [0] DiscoverScreen   → For You
│   ├── [1] DiscoveryScreen  → Discovery
│   └── [2] FavoritesScreen  → Favoritos
└── NavigationBar
    ├── For You (home icon)
    ├── Discovery (explore icon)
    └── Favoritos (favorite icon)
```

### ¿Cómo funciona la navegación?
- `onDestinationSelected(index)` actualiza `_currentIndex`.
- `IndexedStack` muestra la pestaña correspondiente sin destruir las demás.
- Al seleccionar Favoritos (index 2), se llama `FavoritesProvider.refresh()` para recargar desde SharedPreferences.

| Pestaña     | Fuentes de contenido     |
|-------------|--------------------------|
| For You     | Local + Pexels + Pixabay |
| Discovery   | YouTube (tarjetas)       |
| Favoritos   | Videos con ❤️ (todos los orígenes) |

---

## 7. APIs y DataSources

### ¿Qué es una API?
Una **API** (Application Programming Interface) es un servicio web que proporciona datos en formato JSON a través de peticiones HTTP. En TokTik, las APIs nos dan información y URLs de videos de Internet.

### ¿Qué es un DataSource?
Un **DataSource** es una clase en el código que se comunica directamente con una API específica. Traduce la respuesta JSON de la API al formato que usa la app (`VideoPost`). La pantalla **nunca** llama a la API directamente; siempre pasa por un DataSource.

### ¿Qué es VideoPost?
`VideoPost` (en `lib/domain/entities/video_post.dart`) es la entidad de dominio: el formato estándar que usa toda la app para representar un video, independientemente de su origen.

### Diagrama de flujo

```
YouTube API → YoutubeDataSource → VideoPost
Pexels API  → PexelsDataSource  → VideoPost
Pixabay API → PixabayDataSource → VideoPost
Assets      → LocalVideoDatasource → VideoPost
```

```
                    PANTALLA
                       ↑
              DiscoverProvider
              DiscoveryProvider
                       ↑
         VideoPostsRepositoryImpl
                       ↑
         ┌─────────────┼─────────────┐
         ↓             ↓             ↓
   PexelsDataSource  PixabayDS  YoutubeDS
         ↓             ↓             ↓
   Pexels API     Pixabay API  YouTube API
         ↓             ↓             ↓
      JSON            JSON          JSON
         ↓             ↓             ↓
  PexelsVideoModel  PixabayVM  YoutubeVM
         ↓             ↓             ↓
                  VideoPost
```

### ¿Por qué NO se consume la API directamente desde la pantalla?

Si la pantalla contuviera código como `http.get('api.pexels.com/...')`:
- Sería difícil de mantener y probar.
- Mezclaría lógica de negocio con lógica de interfaz.
- Si cambia la API, habría que buscar el código en múltiples archivos.

Con DataSources:
- La pantalla solo conoce `VideoPost` — no sabe si viene de Pexels, Pixabay o Local.
- Para cambiar una API, solo se modifica su DataSource.
- Es posible agregar nuevas fuentes sin tocar la UI.

### YoutubeDataSource
**Archivo:** `lib/infrastructure/datasources/youtube_datasource_impl.dart`  
**API:** YouTube Data API v3  
**Endpoint:** `GET https://www.googleapis.com/youtube/v3/videos`  
**Parámetros:** `part=snippet,statistics`, `chart=mostPopular`, `videoDuration=short`, `regionCode=MX`  
**Autenticación:** Query parameter `key=API_KEY`  

El modelo `YoutubeVideoModel` extrae de la respuesta:
- `id` → ID del video de YouTube (se almacena en `videoPost.videoUrl`)
- `snippet.title` → caption
- `snippet.description` → description
- `snippet.thumbnails.maxres.url` → thumbnailUrl
- `statistics.viewCount` → views
- `statistics.likeCount` → likes

**IMPORTANTE:** El `videoUrl` para videos de YouTube almacena el **ID del video** (ej: `dQw4w9WgXcQ`), NO una URL de MP4. El reproductor `youtube_player_flutter` usa este ID para embeber el player oficial de YouTube.

### PexelsDataSource
**Archivo:** `lib/infrastructure/datasources/pexels_datasource_impl.dart`  
**API:** Pexels Videos API  
**Endpoint:** `GET https://api.pexels.com/videos/search`  
**Parámetros:** `query=nature`, `orientation=portrait`, `per_page=6`  
**Autenticación:** Header `Authorization: API_KEY`  

El modelo `PexelsVideoModel` selecciona el archivo de video SD (calidad media) de `video_files` y obtiene la miniatura de `video_pictures`. Retorna una **URL directa de MP4** reproducible con `VideoPlayerController.networkUrl()`.

### PixabayDataSource
**Archivo:** `lib/infrastructure/datasources/pixabay_datasource_impl.dart`  
**API:** Pixabay Video API  
**Endpoint:** `GET https://pixabay.com/api/videos/`  
**Parámetros:** `key=API_KEY`, `q=nature`, `safesearch=true`, `per_page=6`  
**Autenticación:** Query parameter `key=API_KEY`  

El modelo `PixabayVideoModel` selecciona la calidad `medium` del objeto `videos`. Pixabay provee datos reales de `likes` y `views`. Retorna una **URL directa de MP4**.

---

## 8. Sistema de Favoritos

### Relación con los Likes
El sistema de favoritos está **directamente vinculado** con los likes. No son sistemas separados.

```
Usuario pulsa ♡
      ↓
Corazón → ❤️  (animación)
      ↓
likes + 1
      ↓
LocalStorageService.setLiked(id, true)
      ↓
LocalStorageService.addFavorite(video)  ← Guarda el VideoPost completo como JSON
      ↓
FavoritesProvider.refresh() al abrir la pestaña
```

### ¿Cómo se agrega un video a Favoritos?
Automáticamente al dar like. El `VideoPost` completo (con su `source`) se serializa a JSON y se guarda en SharedPreferences.

### ¿Cómo se elimina?
1. Desde `VideoButtons`: quitar el like elimina de Favoritos.
2. Desde `FavoritesScreen`: presionar el corazón rojo en la tarjeta del favorito.

En ambos casos, se llama a `LocalStorageService.removeFavorite(videoId)` y `setLiked(videoId, false)`.

### ¿Cómo se muestran en la sección Favoritos?
`FavoritesScreen` lee `FavoritesProvider.favorites`, que a su vez lee desde `LocalStorageService.getFavorites()`. Se muestran como tarjetas con:
- Miniatura del video.
- Fuente (Local, YouTube, Pexels, Pixabay) como badge de color.
- Título y descripción.
- Botón ❤️ para quitar.

Al tocar una tarjeta:
- YouTube → abre `YoutubePlayerScreen` (usa `youtube_player_flutter`).
- Local / Pexels / Pixabay → abre `FullScreenPlayer` (usa `video_player`).

### ¿Por qué se guarda el VideoPost completo?
Porque cada fuente se reproduce diferente. Al guardar el campo `source`, la app sabe qué reproductor usar cuando el usuario abre un favorito.

---

## 9. Flujo Completo

```
Usuario
  ↓
Abre TokTik → HomeScreen
  ↓
Selecciona pestaña → For You / Discovery / Favoritos
  ↓
  ┌────────────────────────────────────────┐
  │              For You                   │
  │  DiscoverProvider.loadNextPage()       │
  │          ↓                            │
  │  VideoPostsRepositoryImpl             │
  │       ↓              ↓               │
  │  PexelsDataSource  PixabayDataSource  │
  │       ↓              ↓               │
  │   Pexels API     Pixabay API          │
  │       ↓              ↓               │
  │      JSON            JSON             │
  │       ↓              ↓               │
  │  PexelsVideoModel  PixabayVM          │
  │       ↓              ↓               │
  │        [VideoPost, VideoPost, ...]    │
  │                 ↓                    │
  │      + LocalVideoDatasource           │
  │                 ↓                    │
  │  VideoScrollableView (PageView)       │
  │          ↓                           │
  │     FullScreenPlayer                  │
  │       (video_player)                  │
  └────────────────────────────────────────┘

  ┌────────────────────────────────────────┐
  │            Discovery                   │
  │  DiscoveryProvider.loadVideos()        │
  │         ↓                             │
  │  YoutubeDataSource                     │
  │         ↓                             │
  │  YouTube Data API v3                   │
  │         ↓                             │
  │        JSON                            │
  │         ↓                             │
  │  YoutubeVideoModel → VideoPost         │
  │         ↓                             │
  │  ListView de tarjetas (cards)          │
  │         ↓ (tap)                        │
  │  YoutubePlayerScreen                   │
  │   (youtube_player_flutter)             │
  └────────────────────────────────────────┘

  ┌────────────────────────────────────────┐
  │            Favoritos                   │
  │  FavoritesProvider.loadFavorites()     │
  │         ↓                             │
  │  LocalStorageService.getFavorites()    │
  │         ↓                             │
  │  SharedPreferences → JSON → VideoPost  │
  │         ↓                             │
  │  ListView de tarjetas de favoritos     │
  └────────────────────────────────────────┘
```

---

## 10. Almacenamiento Local

### Tecnología utilizada
**`shared_preferences`** — biblioteca oficial de Flutter/Dart para almacenamiento clave-valor persistente.

### Información almacenada

| Dato       | Clave en SharedPreferences | Tipo    | Ejemplo |
|------------|----------------------------|---------|---------|
| Vistas     | `views_{videoId}`          | `int`   | `views_local_5 → 12` |
| Like       | `liked_{videoId}`          | `bool`  | `liked_pexels_1234 → true` |
| Favoritos  | `favorites`                | `List<String>` | Lista de JSON |

### ¿Cómo se identifican los videos?

Cada video tiene un campo `id` único construido como `{source}_{id}`:

| Fuente   | Formato del ID       | Ejemplo              |
|----------|----------------------|----------------------|
| Local    | `local_{número}`     | `local_4`            |
| Pexels   | `pexels_{id_api}`    | `pexels_1448735`     |
| Pixabay  | `pixabay_{id_api}`   | `pixabay_1234567`    |
| YouTube  | `yt_{videoId}`       | `yt_dQw4w9WgXcQ`     |

Este esquema garantiza que no haya colisiones de IDs entre fuentes.

### Servicio encargado
`lib/services/local_storage_service.dart` — clase estática con métodos:
- `init()` → inicializa SharedPreferences (llamado en `main()`)
- `getViews(id)`, `incrementViews(id)`
- `isLiked(id)`, `setLiked(id, bool)`
- `getFavorites()`, `addFavorite(video)`, `removeFavorite(id)`

---

## 11. Videos Locales

### ¿Por qué permanecen en el proyecto?
Los videos locales (`assets/videos/1.mp4` ... `14.mp4`) son la base de la práctica. Fueron la implementación original de TokTik y demuestran la funcionalidad sin necesidad de conexión a Internet ni API Keys.

### ¿Cómo se integran con las APIs?
La clase `LocalVideoDatasource` implementa la misma interfaz (`VideoPostDatasource`) que los datasources de las APIs. Esto significa que produce `List<VideoPost>` igual que Pexels o Pixabay, solo que leyendo desde datos locales.

En `DiscoverProvider.loadNextPage()`:
```dart
// Primero los locales (filtrados por isValid)
final localDs = LocalVideoDatasource();
final localVideos = (await localDs.getTrendingVideosByPage(1))
    .where((v) => v.isValid)  // Excluye likes > views
    .toList();

// Luego los de APIs externas
final apiVideos = await videosRepository.getTrendingVideosByPage(page);

// Se mezclan en el mismo feed
videos = [...localVideos, ...apiVideos];
```

La pantalla no distingue si un video es local o de una API — todos son `VideoPost`.

**Los videos locales NO cuentan como una de las 3 APIs externas requeridas.**

---

## 12. Estructura de Archivos

```
lib/
├── main.dart                              ← Entrada + providers + LocalStorageService.init()
├── config/
│   ├── api_keys.dart                      ← API Keys (YouTube, Pexels, Pixabay)
│   ├── helpers/
│   │   └── human_formats.dart             ← Formatos numéricos (K, M)
│   └── theme/
│       └── app_theme.dart                 ← Temas Halloween / Navidad / Normal
├── domain/                               ← Reglas de negocio puras
│   ├── datasources/
│   │   └── video_post_datasource.dart     ← Interfaz abstracta de datasource
│   ├── entities/
│   │   └── video_post.dart                ← Entidad VideoPost (id, caption, source, etc.)
│   └── repositories/
│       └── video_posts_repository.dart    ← Interfaz abstracta de repositorio
├── infrastructure/                       ← Implementaciones concretas
│   ├── datasources/
│   │   ├── local_video_datasource_impl.dart  ← Lee assets
│   │   ├── youtube_datasource_impl.dart      ← API 1: YouTube Data API v3
│   │   ├── pexels_datasource_impl.dart       ← API 2: Pexels Videos API
│   │   └── pixabay_datasource_impl.dart      ← API 3: Pixabay Video API
│   ├── models/
│   │   ├── local_video_model.dart
│   │   ├── youtube_video_model.dart
│   │   ├── pexels_video_model.dart
│   │   └── pixabay_video_model.dart
│   └── repositories/
│       └── video_posts_repository_impl.dart  ← Agrega múltiples datasources
├── services/
│   └── local_storage_service.dart         ← SharedPreferences (vistas, likes, favoritos)
├── shared/
│   └── data/
│       └── local_video_posts.dart         ← Lista de 14 videos locales con id y descripción
└── presentation/
    ├── providers/
    │   ├── discover_provider.dart          ← Estado de For You
    │   ├── discovery_provider.dart         ← Estado de Discovery (YouTube)
    │   └── favorites_provider.dart         ← Estado de Favoritos
    ├── screens/
    │   ├── home/
    │   │   └── home_screen.dart            ← Navbar principal (3 pestañas)
    │   ├── discover/
    │   │   └── discover_screen.dart        ← For You (PageView)
    │   ├── discovery/
    │   │   ├── discovery_screen.dart       ← Discovery (YouTube cards)
    │   │   └── youtube_player_screen.dart  ← Pantalla de YouTube fullscreen
    │   └── favorites/
    │       └── favorites_screen.dart       ← Favoritos (lista de cards)
    └── widgets/
        ├── shared/
        │   ├── video_scrollable_view.dart  ← PageView vertical + onViewIncrement
        │   └── video_buttons.dart          ← Like (❤️), vistas (👁), disco (💿)
        └── video/
            ├── fullscreen_player.dart      ← Reproductor video_player (play/pause + mute)
            ├── youtube_player_widget.dart  ← Reproductor YouTube
            ├── video_description.dart      ← Título + descripción + Ver más/menos
            └── video_background.dart       ← Gradiente oscuro sobre el video
```

---

## 13. Paquetes Utilizados

| Paquete | Versión | Propósito |
|---------|---------|-----------|
| `flutter` | SDK | Framework base |
| `provider` | ^6.1.5 | Gestión de estado (DiscoverProvider, etc.) |
| `video_player` | ^2.9.1 | Reproducción de videos MP4 (local y red) |
| `youtube_player_flutter` | ^9.1.1 | Reproductor embebido de YouTube |
| `animate_do` | ^3.3.4 | Animación del disco giratorio |
| `intl` | ^0.19.0 | Formato numérico (K, M) |
| `dio` | ^5.4.0 | Cliente HTTP para consumir las APIs |
| `shared_preferences` | ^2.3.2 | Persistencia local (vistas, likes, favoritos) |
| `cached_network_image` | ^3.4.1 | Carga y caché de miniaturas de red |
| `cupertino_icons` | ^1.0.8 | Íconos de iOS (Material usa Material Icons) |

### Paquetes nuevos agregados en esta práctica
- `dio`: Consumir APIs REST (YouTube, Pexels, Pixabay).
- `shared_preferences`: Persistir vistas, likes y favoritos localmente.
- `youtube_player_flutter`: Reproducir videos de YouTube (requiere WebView nativo).
- `cached_network_image`: Mostrar miniaturas de red con caché eficiente.

---

## 14. Configuración de APIs

### Archivo de configuración
`lib/config/api_keys.dart`

```dart
class ApiKeys {
  static const String youtubeApiKey = 'TU_YOUTUBE_API_KEY_AQUI';
  static const String pexelsApiKey  = 'TU_PEXELS_API_KEY_AQUI';
  static const String pixabayApiKey = 'TU_PIXABAY_API_KEY_AQUI';
}
```

### Cómo obtener cada clave

#### YouTube Data API v3
1. Ve a: https://console.developers.google.com
2. Crea un proyecto nuevo.
3. Habilita la API: **YouTube Data API v3**.
4. Ve a Credenciales → Crear credencial → Clave de API.
5. Copia la clave y reemplaza `TU_YOUTUBE_API_KEY_AQUI`. (AIzaSyBhAGHFy1ClhV9jZ1ZpgDoE-QFA2WN2Qhg)

#### Pexels API
1. Ve a: https://www.pexels.com/api/
2. Crea una cuenta gratuita.
3. Solicita acceso a la API (se aprueba en segundos).
4. Copia tu API Key del panel y reemplaza `TU_PEXELS_API_KEY_AQUI`.
Solicitar acceso a la API
La emisión de nuevas claves API está actualmente suspendida.

#### Pixabay API
1. Ve a: https://pixabay.com/api/docs/
2. Crea una cuenta gratuita.
3. Tu API Key aparece automáticamente en la documentación cuando estás logueado.
4. Reemplaza `TU_PIXABAY_API_KEY_AQUI`.
Buscar vídeos
CONSEGUIRhttps://pixabay.com/api/videos/
Parámetros
clave (obligatoria)	str	Tu clave API:57999227-8d67580ec5c316c2a7fa08016 Girar
q	str	Un término de búsqueda codificado en URL. Si se omite, se mostrarán todos los vídeos . Este valor no puede exceder los 100 caracteres.
Ejemplo: "yellow+flower"
idioma	str	Código de idioma del idioma en el que se realizará la búsqueda.
Valores aceptados: cs, da, de, en, es, fr, id, it, hu, nl, no, pl, pt, ro, sk, fi, sv, tr, vi, th, bg, ru, el, ja, ko, zh. Valor
predeterminado: "en".
identificación	str	Recuperar vídeos individuales por ID.
tipo_de_video	str	Filtra los resultados por tipo de vídeo.
Valores aceptados: "all", "film", "animation".
Valor predeterminado: "all".
categoría	str	Filtra los resultados por categoría.
Valores aceptados: antecedentes, moda, naturaleza, ciencia, educación, sentimientos, salud, personas, religión, lugares, animales, industria, informática, comida, deportes, transporte, viajes, edificios, negocios, música
ancho_mínimo	entero	Ancho mínimo de vídeo.
Valor predeterminado: "0"
altura_mínima	entero	Altura mínima del vídeo.
Valor predeterminado: "0"
elección_de_los_editores	booleano	Seleccione los vídeos que hayan recibido el premio "Elección del editor ".
Valores aceptados: "verdadero", "falso".
Valor predeterminado: "falso".
búsqueda segura	booleano	Un indicador que especifica que solo se deben devolver vídeos aptos para todas las edades.
Valores aceptados: "true", "false".
Valor predeterminado: "false".
orden	str	Cómo deben ordenarse los resultados.
Valores aceptados: "popular", "latest".
Valor predeterminado: "popular".
página	entero	Los resultados de la búsqueda se muestran paginados. Utilice este parámetro para seleccionar el número de página.
Valor predeterminado: 1
por página	entero	Determina el número de resultados por página.
Valores aceptados: 3 - 200.
Valor predeterminado: 20.
llamar de vuelta	cadena	Nombre de la función de devolución de llamada JSONP
bonito	booleano	Sangrar la salida JSON. Esta opción no debe usarse en producción.
Valores aceptados: "true", "false".
Valor predeterminado: "false".

### Cómo ejecutar el proyecto
```bash
# 1. Descarga los videos de Drive (ver assets/videos/README.txt)
# 2. Coloca los videos en: assets/videos/

# 3. Instala dependencias
cd "Practica 4/TokTik"
flutter pub get

# 4. Ejecuta
flutter run

# Si quieres ver solo videos locales (sin API keys), la app funciona igual.
# Las pestañas de Pexels/Pixabay/YouTube estarán vacías si no hay keys.
```

### ¿Qué pasa si no tengo API Keys?
La app **NO se cierra**. Cada DataSource verifica si la key está configurada:
```dart
if (!ApiKeys.isPexelsConfigured) return [];  // Retorna lista vacía
```
La pestaña For You mostrará solo los videos locales. Discovery mostrará un estado vacío con instrucciones.

---

## 15. Pruebas

### Play/Pause
1. Abre la app en la pestaña **For You**.
2. Toca cualquier parte del video → el video se pausa y aparece el ícono ▶ en el centro.
3. Toca de nuevo → el video reanuda y el ícono desaparece.

### Sonido
1. Busca el ícono 🔇 en la esquina superior derecha del video.
2. Tócalo → cambia a 🔊 y el sonido se activa.
3. Tócalo de nuevo → vuelve a 🔇.

### Descripción y Ver más
1. Abre la app — en la parte inferior de cada video verás el título y la descripción.
2. Si la descripción es larga, verás `...Ver más`.
3. Toca "Ver más" → se expande la descripción completa.
4. Toca "Ver menos" → se contrae.

### Vistas
1. Abre la app — el contador de 👁 muestra el valor inicial.
2. Haz scroll al siguiente video → el contador del video anterior se incrementó en 1.
3. Cierra y vuelve a abrir la app → el contador mantiene su valor (persistencia).

### Likes
1. Toca el corazón ♡ → se llena ❤️ y el contador aumenta en 1.
2. Toca de nuevo → vuelve a ♡ y el contador disminuye.
3. Cierra y vuelve a abrir → el like sigue guardado.

### Favoritos
1. Dale like ❤️ a un video.
2. Navega a la pestaña **Favoritos** → el video aparece en la lista.
3. En Favoritos, toca el ❤️ de la tarjeta → el video desaparece de la lista.
4. Vuelve a For You → el corazón ya está vacío ♡.

### YouTube (Discovery)
1. Configura tu YouTube API Key en `api_keys.dart`.
2. Abre la pestaña **Discovery**.
3. Verás tarjetas de videos de YouTube con miniaturas.
4. Toca una tarjeta → abre el reproductor de YouTube embebido.

### Pexels y Pixabay (For You)
1. Configura las API Keys de Pexels y/o Pixabay.
2. Abre la pestaña **For You**.
3. Además de los videos locales, verás videos de Pexels y Pixabay.
4. Estos se reproducen directamente (MP4) con los mismos controles.

### Videos locales
1. Descarga los 14 videos de Drive (ver `assets/videos/README.txt`).
2. La app siempre muestra los videos locales válidos (los 3 ilógicos se filtran).
3. Los videos locales funcionan sin conexión a Internet.

---

## 16. Splash Screen Estacional

### ¿Qué se implementó?
Una pantalla de bienvenida que se muestra durante **3 segundos** al iniciar la app. Muestra el logo de la temporada activa y reproduce un sonido correspondiente.

### Archivo con la lógica
`lib/presentation/screens/splash/splash_screen.dart`

### Detección de temporada
La temporada se obtiene de `AppTheme.currentSeason` que compara el mes actual del dispositivo:

| Mes      | Temporada  | Logo                          | Sonido                  |
|----------|------------|-------------------------------|-------------------------|
| Octubre  | Halloween  | `Logo_TokTik_Octubre.jfif`    | `OctubreP4.mpeg`        |
| Diciembre| Navidad    | `Logo_TokTik_Diciembre.jfif`  | `DiciembreP4.mpeg`      |
| Resto    | Normal     | `Logo_TokTik.jfif`            | (ninguno)               |

### ¿Cómo funciona?

```dart
// En main.dart: home apunta a SplashScreen
home: const SplashScreen(),

// SplashScreen en initState():
Future.delayed(const Duration(seconds: 3), _navigateToHome);
_playSeasonalSound();  // Reproduce el audio de assets/sounds/

// Navegación con transición fade
Navigator.of(context).pushReplacement(
  PageRouteBuilder(
    pageBuilder: (_, __, ___) => const HomeScreen(),
    transitionsBuilder: (_, anim, __, child) =>
        FadeTransition(opacity: anim, child: child),
  ),
);
```

### Animaciones del Splash
- **Fade-in + Scale**: El logo y el texto aparecen con animación elástica.
- **Barra de progreso**: `LinearProgressIndicator` con color temático.
- **Fondo degradado**: Radial/Linear según la temporada.
- **Partículas de fondo**: Para Halloween, se pintan destellos naranjas con `CustomPainter`.

### Paquete de Audio
Se usa el paquete `audioplayers` para reproducir los archivos `.mpeg` de `assets/sounds/`:

```dart
await _audioPlayer.play(AssetSource('sounds/OctubreP4.mpeg'));
```

---

## 17. Botón de Mute en Columna Lateral

### ¿Qué se implementó?
El botón de silenciar/activar sonido se movió de la esquina superior del video a la **columna lateral de botones** (junto al corazón y las vistas), cumpliendo el requisito del profesor.

### Archivo con la lógica
`lib/presentation/widgets/shared/video_buttons.dart` → clase `_MuteButton`

### Arquitectura con ValueNotifier

```
VideoScrollableView
├── ValueNotifier<bool> _isMutedNotifier (estado compartido)
├── ValueNotifier<bool> _isPlayingNotifier
├── FullScreenPlayer(isMutedNotifier: _isMutedNotifier, ...)
│     └── Escucha _isMutedNotifier → setVolume()
└── VideoButtons(isMutedNotifier: _isMutedNotifier)
      └── _MuteButton → al tocar, cambia _isMutedNotifier.value
```

El `ValueNotifier` garantiza que el cambio de mute se propaga reactivamente al reproductor **sin rebuild innecesario de toda la pantalla**.

### Estados del botón
| Estado    | Ícono          | Texto   | Color fondo |
|-----------|----------------|---------|-------------|
| Muteado   | `volume_off`   | "Mudo"  | `white24`   |
| Con sonido| `volume_up`    | "Sonido"| `white10`   |

---

## 18. Botón Play/Pause en el Centro de la Pantalla

### ¿Qué se implementó?
Un botón circular en el centro exacto del video que se muestra al pausar y desaparece al reproducir. Comparte estado con `FullScreenPlayer` mediante `ValueNotifier<bool>`.

### Archivo con la lógica
`lib/presentation/widgets/shared/video_scrollable_view.dart` (overlay en el `Stack`)

### ¿Cómo funciona?

```dart
// En VideoScrollableView:
Center(
  child: ValueListenableBuilder<bool>(
    valueListenable: _isPlayingNotifier,
    builder: (_, isPlaying, __) {
      return GestureDetector(
        onTap: () => _isPlayingNotifier.value = !_isPlayingNotifier.value,
        child: AnimatedOpacity(
          opacity: isPlaying ? 0.0 : 1.0,  // Solo visible al pausar
          duration: Duration(milliseconds: 300),
          child: Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
            child: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, ...),
          ),
        ),
      );
    },
  ),
),
```

### Comportamiento
- Al tocar el **video** → alterna play/pause (GestureDetector en FullScreenPlayer).
- Al tocar el **botón central** → también alterna (GestureDetector del overlay).
- Ambos comparten el mismo `_isPlayingNotifier` → siempre sincronizados.
- Al cambiar de video con scroll → `_isPlayingNotifier.value = true` (reinicia a play).

---

## 19. Mecanismo de Prueba de Temporadas (LocalStorage & San Valentín)

### ¿Qué se implementó?
Un mecanismo interactivo de pruebas integrado en la UI que permite al profesor y al desarrollador forzar en cualquier momento cualquiera de las temporadas:
- 🎃 **Halloween** (Octubre): Naranja calabaza, morado oscuro, audio espeluznante.
- 🎄 **Navidad** (Diciembre): Rojo navideño, verde pino, dorado, villancico.
- 💝 **San Valentín / Valentine's Day** (Febrero): Rosa intenso, carmesí y amor.
- 📱 **Normal**: Modo oscuro estándar con acentos verdes.
- 🗓️ **Automático**: Lee la fecha del sistema (`DateTime.now().month`).

La selección se guarda de forma persistente en `SharedPreferences` mediante la clave `season_override`.

### Acceso en la aplicación
1. En la pestaña **For You**, se pulsa el botón de paleta (🎨) en el AppBar superior derecho.
2. Se abre el diálogo interactivo `SeasonSelectorDialog`.
3. Al seleccionar una temporada, la app actualiza reactivamente su paleta de colores, ícono y textos sin necesidad de reiniciar la app (vía `ThemeProvider`).
4. El diálogo incluye un botón directo **"Probar Splash Screen (3s)"** para previsualizar inmediatamente la pantalla de bienvenida y el audio estacional de la temporada elegida.

---

## 20. Persistencia del Conteo de Likes en Local Storage

### ¿Qué se implementó?
Para cumplir con el requerimiento de que el número de *Me Gusta* persista parcialmente tras cerrar la app:
1. `LocalStorageService.setLikes(videoId, count)` guarda el total entero de likes bajo la clave `likes_count_{videoId}`.
2. Cuando el usuario da like, se incrementa en 1 y se guarda en `LocalStorageService`.
3. Cuando el usuario desmarca el like, se resta 1 y se actualiza en `LocalStorageService`.
4. Al cargar los videos (locales o remotos), `DiscoverProvider` y `DiscoveryProvider` consultan `LocalStorageService.getLikes(v.id)` y sobreescriben el valor base si existe uno almacenado.

---

## 21. Descripción Extensa con Desplazamiento Vertical

### ¿Qué se implementó?
En `lib/presentation/widgets/video/video_description.dart`:
- Cuando la descripción excede los 80 caracteres, se muestra truncada con el botón interactivo **"... más"**.
- Al presionar **"... más"**, la descripción se expande dentro de un contenedor acotado (`ConstrainedBox` con altura máxima de 130 px).
- La sección cuenta con **desplazamiento vertical** (`SingleChildScrollView` con física `BouncingScrollPhysics()` y barra de scroll `RawScrollbar` visible), permitiendo leer descripciones completas (incluso las más largas de YouTube) sin desbordar la pantalla del video.
- Al presionar **"Ver menos"**, se contrae de nuevo a su estado compacto.

---

## 22. Desplazamiento Lateral entre Secciones y Carrusel

### ¿Qué se implementó?
1. **Desplazamiento lateral en HomeScreen**:
   La pantalla principal implementa un `PageView` horizontal (`scrollDirection: Axis.horizontal`) conectado con `PageController` al `NavigationBar`.
   El usuario puede deslizar con el dedo lateralmente (swipe horizontal) para navegar de forma natural entre:
   - **For You** (desplazamiento vertical de videos TikTok)
   - **Discovery** (videos de YouTube)
   - **Favoritos** (videos con ❤️ guardados)
2. **Carrusel lateral de tendencias en Discovery**:
   En la pestaña Discovery se agregó una sección superior con desplazamiento lateral horizontal (`ListView.builder` con `Axis.horizontal`), permitiendo explorar miniaturas de tendencias de YouTube deslizando de izquierda a derecha.

---

## 23. Diagramas de Arquitectura (Provider Local vs Repositorio y DataSources)

Como requisito fundamental de evaluación de la práctica, se presentan los dos diagramas de arquitectura que contrastan el consumo local directo frente a la arquitectura desacoplada con Repositorio y múltiples DataSources.

### Diagrama 1: Arquitectura con Provider Local

Este diagrama modela el flujo directo donde el Provider interactúa con la fuente de datos local (assets empaquetados en la aplicación) y el almacenamiento en disco (`SharedPreferences`):

```mermaid
graph TD
    subgraph UI ["Capa de Presentación (UI)"]
        V[DiscoverScreen / VideoScrollableView]
        VB[VideoButtons - Likes y Vistas]
    end

    subgraph ProviderLayer ["Gestor de Estado"]
        DP[DiscoverProvider]
    end

    subgraph LocalDatasourceLayer ["Capa de Datos Local"]
        LDS[LocalVideoDatasource]
        LVM[LocalVideoModel Mapper]
    end

    subgraph Persistence ["Persistencia Local"]
        LSS[LocalStorageService]
        SP[(SharedPreferences)]
    end

    subgraph LocalAssets ["Recursos Locales"]
        LVP[local_video_posts.dart]
        VIDS[(assets/videos/*.mp4)]
    end

    V -->|Lee videos y estado| DP
    VB -->|Incrementa vistas / Alterna like| DP
    DP -->|Carga videos locales iniciales| LDS
    LDS -->|Lee lista de videos| LVP
    LDS -->|Carga video URLs| VIDS
    LVP -->|Mapea a entidad| LVM
    LVM -->|Genera instancias| DP
    DP -->|Persiste vistas y likes| LSS
    LSS -->|Guarda / Lee| SP
```

**Características del Provider Local:**
- **Sin conexión requerida**: Los 14 videos locales funcionan offline directamente desde los assets.
- **Filtrado de inconsistencias**: `DiscoverProvider` evalúa el getter `video.isValid` y descarta los 3 videos ilógicos (`likes > views`).
- **Persistencia inmediata**: Guarda y lee likes, vistas y estado directamente vía `LocalStorageService`.

---

### Diagrama 2: Arquitectura con Provider a través de Repositorio y Diferentes DataSources

Este diagrama modela la **Arquitectura Limpia (Clean Architecture)** implementando el principio de Inversión de Dependencias (DIP) del estándar SOLID. El Provider no conoce la procedencia específica ni los detalles HTTP de cada API; se comunica únicamente a través de la interfaz abstracta del repositorio:

```mermaid
graph TD
    subgraph UI ["Capa de Presentación"]
        DS_UI[DiscoverScreen - For You]
        DY_UI[DiscoveryScreen - YouTube]
    end

    subgraph Providers ["Capa de Providers"]
        DP[DiscoverProvider]
        DYP[DiscoveryProvider]
    end

    subgraph Domain ["Capa de Dominio (Clean Code)"]
        REPO_INTERFACE["VideoPostRepository (Abstract Interface)"]
        ENTITY["VideoPost Entity"]
    end

    subgraph Infrastructure ["Capa de Infraestructura"]
        REPO_IMPL["VideoPostsRepositoryImpl"]
        PEX_DS["PexelsDataSourceImpl"]
        PIX_DS["PixabayDataSourceImpl"]
        YOUTUBE_DS["YoutubeDataSourceImpl"]
    end

    subgraph ModelsMappers ["Modelos y Mappers"]
        PEX_MODEL["PexelsVideoModel"]
        PIX_MODEL["PixabayVideoModel"]
        YOU_MODEL["YoutubeVideoModel"]
    end

    subgraph ExternalAPIs ["APIs Externas REST (HTTP/Dio)"]
        API_PEX[("Pexels Video API\napi.pexels.com")]
        API_PIX[("Pixabay Video API\npixabay.com")]
        API_YOU[("YouTube Data API v3\ngoogleapis.com")]
    end

    DS_UI -->|Observa videos| DP
    DY_UI -->|Observa videos| DYP
    
    DP -->|Consume mediante interfaz| REPO_INTERFACE
    DYP -->|Consume datasource YouTube| YOUTUBE_DS
    
    REPO_INTERFACE -.->|Implementado por| REPO_IMPL
    REPO_IMPL -->|Orquesta llamada| PEX_DS
    REPO_IMPL -->|Orquesta llamada| PIX_DS

    PEX_DS -->|GET /videos/search| API_PEX
    PIX_DS -->|GET /api/videos| API_PIX
    YOUTUBE_DS -->|GET /videos?chart=mostPopular| API_YOU

    API_PEX -->|JSON Response| PEX_MODEL
    API_PIX -->|JSON Response| PIX_MODEL
    API_YOU -->|JSON Response| YOU_MODEL

    PEX_MODEL -->|toVideoPostEntity()| ENTITY
    PIX_MODEL -->|toVideoPostEntity()| ENTITY
    YOU_MODEL -->|toVideoPostEntity()| ENTITY

    ENTITY -->|Entrega a| REPO_IMPL
    REPO_IMPL -->|Entrega List<VideoPost>| DP
```

**Ventajas clave de este diseño:**
1. **Desacoplamiento total**: Si la API de Pexels o Pixabay cambia sus nombres de campos JSON, solo se actualiza su modelo/mapper (`PexelsVideoModel`), sin alterar ni una sola línea de la UI ni de los Providers.
2. **Escalabilidad**: Se pueden agregar nuevos datasources (por ejemplo, DailyMotion, Vimeo o Twitch) simplemente implementando `VideoPostDatasource` y registrándolos en `VideoPostsRepositoryImpl`.
3. **Sustituibilidad (Principio de Liskov)**: El Provider solo depende de `VideoPostRepository`, permitiendo inyectar fuentes reales o mocks en pruebas unitarias.

