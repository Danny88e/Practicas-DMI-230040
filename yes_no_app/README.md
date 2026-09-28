# Práctica 03: Yes, No, Maybe

> Aplicación de chat desarrollada con Flutter para practicar interfaces de conversación y administración del estado.

## Descripción

La aplicación muestra una conversación con burbujas de mensajes y un campo para escribir y enviar texto. El estado de la conversación se administra con `Provider` y `ChangeNotifier`. Incluye una imagen de perfil local y una imagen remota en las burbujas de respuesta.

> **Nota:** en esta versión, el envío agrega el mensaje escrito a la conversación; no hay integración con la API yesno.wtf.

## Tecnologías

- Flutter y Dart
- Material Design
- `provider` para administrar el estado
- Imágenes locales y remotas

## Ejecución

Desde esta carpeta, instala las dependencias y ejecuta la aplicación en un dispositivo o navegador disponible:

```bash
flutter pub get
flutter run
```

## Estructura principal

- `lib/domain/`: entidad del mensaje.
- `lib/presentation/providers/`: estado de la conversación.
- `lib/presentation/screens/`: pantalla del chat.
- `lib/presentation/widgets/`: burbujas y campo de texto.
- `assets/`: recursos locales de la interfaz.