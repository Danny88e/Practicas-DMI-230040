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

## Configurar el token de TMDB

1. Copia `.env.example.json` como `.env.json`.
2. Reemplaza el valor de `TMDB_BEARER_TOKEN` con tu token de acceso de lectura.
3. No compartas ni agregues `.env.json` a Git; está ignorado por `.gitignore`.

El token se compila dentro de la aplicación local al ejecutar Flutter. No publiques
el binario ni despliegues esta configuración como si fuera un secreto de servidor.

## Ejecutar en Windows

```powershell
flutter pub get
flutter run -d windows --dart-define-from-file=.env.json
```

También puedes seleccionar otro dispositivo disponible con `flutter devices`.

## Verificar

```powershell
flutter analyze
flutter test
```
