

import 'package:chat/services/messages/message.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble(this.message, {super.key});

  final Message message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade300,
        borderRadius: BorderRadius.circular(16)
      ),
      child: Text(message.text),
    );
  }
}