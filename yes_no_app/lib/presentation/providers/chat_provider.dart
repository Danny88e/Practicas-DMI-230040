import 'package:flutter/material.dart';
import 'package:yes_no_app/domain/entities/message.dart';

class ChatProvider extends ChangeNotifier {
    
    final ScrollController chatScrollController = ScrollController();

    List<Message> messageList = [
        Message(text: 'Holaaaaaa', imageUlr: '', fromWho: FromWho.me),
        Message(text: 'Ya regresaste ?', imageUlr: '', fromWho: FromWho.me),
    ];

    Future<void> sendMessage(String text) async {
        final newMessage = Message(
            text: text,
            imageUlr: '',
            fromWho: FromWho.me,
        );
        messageList.add(newMessage);
        notifyListeners();
    }

    void moveScrollToBottom() {
        chatScrollController.animateTo(
            chatScrollController.position.maxScrollExtent + 100,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
        );
    }
}