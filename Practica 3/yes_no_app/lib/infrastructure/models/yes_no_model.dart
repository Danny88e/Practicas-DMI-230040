// Modelo que mapea la respuesta JSON de la API yesno.wtf
// Ejemplo de respuesta: { "answer": "yes", "forced": false, "image": "https://..." }

import 'package:yes_no_app/domain/entities/message.dart';

class YesNoModel {
  final String answer;
  final bool forced;
  final String image;

  YesNoModel({
    required this.answer,
    required this.forced,
    required this.image,
  });

  /// Construye el modelo desde el JSON devuelto por la API.
  factory YesNoModel.fromJson(Map<String, dynamic> json) {
    return YesNoModel(
      answer: json['answer'],
      forced: json['forced'],
      image: json['image'],
    );
  }

  /// Convierte el modelo a la entidad [Message] del chat.
  /// Traduce "yes" → "Sí", "no" → "No", "maybe" → "Tal vez".
  Message toMessageEntity() {
    String text;
    switch (answer) {
      case 'yes':
        text = '¡Sí!';
        break;
      case 'no':
        text = 'No';
        break;
      default:
        text = 'Tal vez...';
    }

    return Message(
      text: text,
      from: MessageFrom.bot,
      imageUrl: image,
    );
  }
}
