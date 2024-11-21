
import 'package:chat/services/messages/message.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TextBubble extends StatefulWidget {
  const TextBubble(this.message, {super.key, this.isLink = false});

  final Message message;
  final bool isLink;

  @override
  State<TextBubble> createState() => _TextBubbleState();
}

class _TextBubbleState extends State<TextBubble> {

  bool get isSender => widget.message.isSender;

  String get time => DateFormat("hh:mm a").format(widget.message.datetime);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: isSender? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (widget.message.isSending) const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Icon(Icons.schedule, color: Colors.grey, size: 19),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 6),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSender ? Color(0xFF6C63FF) : Colors.white70,  // Sent bubble: #6C63FF, Received bubble: light grey
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: isSender ? Radius.circular(12) : Radius.circular(0),
              bottomRight: isSender ? Radius.circular(0) : Radius.circular(12),
            ),
          ),
          child: Column(
            crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              widget.isLink
                  ? GestureDetector(
                      onTap: () {
                        // Open link
                      },
                      child: Text(
                        widget.message.text,
                        style: TextStyle(color: Colors.blue[200], decoration: TextDecoration.underline),
                      ),
                    )
                  : Text(
                      widget.message.text,
                      style: TextStyle(
                        color: isSender ? Colors.white : Colors.black87,
                      ),
                    ),
              SizedBox(height: 5),
              Text(
                time,
                style: TextStyle(fontSize: 10, color: isSender ? Colors.white70 : Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}