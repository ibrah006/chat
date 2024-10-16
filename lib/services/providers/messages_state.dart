
import 'package:chat/services/messages/message.dart';
import 'package:flutter/material.dart';

class MessagesState extends ChangeNotifier {


  final List<Message> messages = [];

  add(Message message) {
    messages.add(message);
    notifyListeners();
  }
}