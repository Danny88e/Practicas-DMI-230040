// Entidad que representa un mensaje en el chat.
// Guarda el texto, quién lo envió, una URL de GIF opcional
// y la hora local en que fue enviado.

enum MessageFrom { mine, bot }

class Message {
  final String text;
  final MessageFrom from;
  final String? imageUrl; // URL del GIF de la respuesta (solo mensajes del bot)
  final DateTime createdAt;

  Message({
    required this.text,
    required this.from,
    this.imageUrl,
  }) : createdAt = DateTime.now();
}
