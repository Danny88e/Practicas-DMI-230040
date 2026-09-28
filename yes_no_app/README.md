# Práctica 03 — SportBot: Chat con API de Respuestas Automáticas

**Materia:** Desarrollo Móvil Integral  
**Número de control:** 230040  
**Fecha:** Septiembre 2026

---

## Descripción

Aplicación de chat en Flutter que responde preguntas del usuario (mensajes que terminan en `?`) utilizando la API pública [yesno.wtf](https://yesno.wtf/api). El bot responde con **Sí**, **No** o **Tal vez** en proporción 40 % / 40 % / 20 %, mostrando el GIF asociado a cada respuesta. El tema del chat es sobre deporte y ejercicio.

---

## Funcionalidades

- Enviar mensajes de texto desde el campo de conversación.
- Mostrar la **hora local de envío** en cada burbuja (usuario y bot).
- Recibir una **respuesta automática** cuando el mensaje termina en `?`.
- Distribución de respuestas: **40 % Sí · 40 % No · 20 % Tal vez**.
- Mostrar el **GIF** devuelto por la API junto a la respuesta.
- **Auto-scroll** al mensaje más reciente.
- **Ícono personalizado** de la aplicación con temática deportiva.

---

## Tecnologías

| Tecnología | Uso |
|---|---|
| Flutter / Dart | Framework móvil |
| Material Design 3 | UI y tema oscuro |
| `provider` ^6.1.5 | Gestión de estado |
| `dio` ^5.4.0 | Solicitudes HTTP |
| `google_fonts` ^6.2.1 | Tipografía |
| [yesno.wtf API](https://yesno.wtf/api) | Respuestas automáticas |

---

## Estructura del proyecto

```
lib/
├── main.dart
├── config/
│   └── theme/
│       └── app_theme.dart          ← Tema oscuro deportivo
├── domain/
│   └── entities/
│       └── message.dart            ← Entidad Message
├── infrastructure/
│   ├── models/
│   │   └── yes_no_model.dart       ← Modelo JSON de la API
│   └── datasources/
│       └── get_yes_no_answer.dart  ← Lógica 40/40/20 + llamada HTTP
└── presentation/
    ├── providers/
    │   └── chat_provider.dart      ← Estado de la conversación
    ├── screens/
    │   └── chat/
    │       └── chat_screen.dart    ← Pantalla principal
    └── widgets/
        ├── chat/
        │   ├── my_message_bubble.dart   ← Burbuja usuario
        │   └── her_message_bubble.dart  ← Burbuja bot + GIF
        └── shared/
            └── message_field_box.dart   ← Campo de texto
```

---

## Cómo ejecutar

```bash
# 1. Instalar dependencias
flutter pub get

# 2. Ejecutar en dispositivo/emulador
flutter run
```

> **Nota:** Se requiere conexión a Internet para que la API de yesno.wtf funcione.

---

## Lógica de distribución (40/40/20)

```dart
final List<String> _options = ['yes', 'yes', 'no', 'no', 'maybe'];
final randomAnswer = _options[Random().nextInt(_options.length)];
// → 2/5 = 40% yes · 2/5 = 40% no · 1/5 = 20% maybe
```

El parámetro `force` de la API fuerza exactamente la respuesta seleccionada:

```
GET https://yesno.wtf/api?force=yes
GET https://yesno.wtf/api?force=no
GET https://yesno.wtf/api?force=maybe
```

---

## Resultados esperados

| Respuesta | Proporción | Texto mostrado |
|---|---|---|
| Sí | 40 % | ¡Sí! 💪 + GIF |
| No | 40 % | No 🚫 + GIF |
| Tal vez | 20 % | Tal vez... 🤔 + GIF |
