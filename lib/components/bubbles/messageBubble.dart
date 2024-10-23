import 'package:chat/services/messages/message.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble(this.message, {super.key});

  final Message message;

  bool get isSentByMe=> message.isSender;

  // Method to get background color based on whether the message is sent by the user
  Color _getBackgroundColor() {
    return isSentByMe ? Colors.blue.shade50 : Colors.grey.shade100;
  }

  // Method to get text color based on whether the message is sent by the user
  Color _getTextColor() {
    return isSentByMe ? Colors.blue.shade700 : Colors.black87;
  }

  // Method to get the time display format
  String _getTimeText() {
    return DateFormat("hh:mm a").format(message.datetime);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      child: Row(
        mainAxisAlignment:
            isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: _getBackgroundColor(), // Background color based on sender
              borderRadius: BorderRadius.circular(12), // Slightly sharp border
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05), // Subtle shadow
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Message Text
                Text(
                  message.text,
                  style: TextStyle(
                    fontSize: 16,
                    color: _getTextColor(),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                // Timestamp Text
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    _getTimeText(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}