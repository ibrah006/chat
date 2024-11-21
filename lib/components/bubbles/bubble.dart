

import 'package:chat/components/bubbles/audio_bubble.dart';
import 'package:chat/components/bubbles/text_bubble.dart';
import 'package:chat/constants/date.dart';
import 'package:chat/services/messages/message.dart';
import 'package:flutter/material.dart';

class Bubble extends StatelessWidget {
  const Bubble(this.message, {super.key});

  final Message message;

  AudioBubble? get isVoice {
    final audioMessage = message.isAudio();

    if (audioMessage == null) {
      return null;
    }
    
    return AudioBubble(audioMessage);
  } 

  @override
  Widget build(BuildContext context) {

    return isVoice?? TextBubble(message);
   
  }
}