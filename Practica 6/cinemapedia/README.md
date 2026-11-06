# cinemapedia

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## API de TMDB

El token de acceso de lectura se configura localmente en `.env`, con esta variable:

```dotenv
TMDB_BEARER_TOKEN=pega_aqui_tu_token_de_lectura
```

No guardes el token real en este README ni lo subas a Git. `.env` está excluido
por `.gitignore`; conserva el token en un gestor de secretos o contraseñas.
Al ejecutar en Flutter Web, el token queda accesible desde el navegador, así que
esta configuración es solo para desarrollo local y no debe usarse como secreto
en una aplicación pública.

## Ejecutar

Después de crear `.env` en la raíz del proyecto y agregar un token válido:

```powershell
flutter pub get
flutter run -d chrome
```

También puedes seleccionar otro dispositivo disponible con `flutter devices`.

## Verificar

```powershell
flutter analyze
flutter test
```
