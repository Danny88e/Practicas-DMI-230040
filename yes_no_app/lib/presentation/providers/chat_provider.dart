// ChatProvider gestiona el estado de la conversación.
// Agrega mensajes del usuario y solicita respuesta automática
// del bot cuando el texto termina en signo de interrogación.

import 'package:flutter/material.dart';
import 'package:yes_no_app/domain/entities/message.dart';
import 'package:yes_no_app/infrastructure/datasources/get_yes_no_answer.dart';

class ChatProvider extends ChangeNotifier {
  // Controlador del scroll para auto-desplazarse al último mensaje
  final ScrollController chatScrollController = ScrollController();

  // Datasource de la API
  final _getYesNoAnswer = GetYesNoAnswer();

  // Lista de mensajes de la conversación
  List<Message> messages = [];

  // Agrega un mensaje del usuario y, si termina en "?", pide respuesta del bot
  Future<void> sendMessage(String text) async {
    if (text.isEmpty) return;

    final userMessage = Message(text: text, from: MessageFrom.mine);
    messages.add(userMessage);
    notifyListeners();
    _scrollToBottom();

    // El bot responde solo si el mensaje termina en "?"
    if (text.endsWith('?')) {
      final botMessage = await _getYesNoAnswer.getAnswer();
      messages.add(botMessage);
      notifyListeners();
      _scrollToBottom();
    }
  }

  // Desplaza la vista hasta el último mensaje de forma animada
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (chatScrollController.hasClients) {
        chatScrollController.animateTo(
          chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
