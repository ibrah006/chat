
import 'package:chat/constants/basic_bloc.dart';
import 'package:flutter/material.dart';

class CallOptions {

  bool isSpeakerOn = false;
  bool isMicOn = true;
  bool isCameraOn = true;

  BasicBloc stateUpdater = BasicBloc();

  toggleSpeaker() {
    isSpeakerOn = !isSpeakerOn;

    stateUpdater.sink.add(null);
  }

  toggleMic() {
    isMicOn = !isMicOn;

    stateUpdater.sink.add(null);
  }

  toggleCamera() {
    isCameraOn = !isCameraOn;

    stateUpdater.sink.add(null);
  }

  void hangUp(Function disposeSignal, BuildContext context, {bool delayed = false}) async {
    if (delayed) await Future.delayed(Duration(seconds: 4));

    disposeSignal().then((value) {
      Navigator.pop(context);
    });
  }
}