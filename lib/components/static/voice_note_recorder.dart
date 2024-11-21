import 'dart:async';
import 'dart:math';
import 'package:chat/constants/date.dart';
import 'package:chat/services/messages/voice_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:google_fonts/google_fonts.dart';

class VoiceNoteRecorder extends StatefulWidget {
  final VoidCallback onPauseStopRecording;

  const VoiceNoteRecorder(this.voiceMessage, {Key? key, required this.onPauseStopRecording, required this.recordingState})
      : super(key: key);

  final VoiceMessage voiceMessage;

  final RecordingState recordingState;

  @override
  _VoiceNoteRecorderState createState() => _VoiceNoteRecorderState();
}

class _VoiceNoteRecorderState extends State<VoiceNoteRecorder> {
  // late Timer _timer;
  final Random _random = Random();
  late List<double> _waveformBars;

  late final int bars;

  @override
  void initState() {
    super.initState();
    _startWaveformAnimation();
  }

  @override
  void dispose() {
    widget.voiceMessage.timer.cancel();
    super.dispose();
  }

  void _startWaveformAnimation() {

    try {
      widget.voiceMessage.timer = Timer.periodic(Duration(milliseconds: 200), (timer) {
        if (widget.recordingState == RecordingState.recording) {
          setState(() {
            _waveformBars = List.generate(
              bars,
              (index) => _random.nextDouble() * 20 + 10,
            );
          });
        }
      });
    } catch(e) {
      Future.delayed(Duration(milliseconds: 50)).then((value) {
        _startWaveformAnimation();
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    try {
      _waveformBars;
    } catch(e) {
      bars = ( MediaQuery.of(context).size.width / ( 4 * 4.8979592 ) ).toInt();
      _waveformBars = List.generate(
        bars, (index) => 10.0
      );
    }

    return Container(
      height: 30 + (16*2),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          GestureDetector(
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade400,//Color(0xFF6C63FF),
              child: Transform.rotate(angle: -pi/2, child: Icon(Icons.schedule_send_rounded, color: Colors.white, size: 22))
            )
          ),
          SizedBox(width: 10),
          Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: widget.recordingState == RecordingState.paused? Alignment.topCenter : Alignment.center,
                child: Text(
                  widget.voiceMessage.getDurationFormatted(),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Color(0xFF6C63FF), fontSize: 12.25)),
              ),
              //
              if (widget.recordingState == RecordingState.paused) Align(
                alignment: Alignment.bottomCenter,
                child: InkWell(
                  onTap: () {
                    if (widget.voiceMessage.isPlaying) {
                      widget.voiceMessage.pausePreview();
                    } else {
                      widget.voiceMessage.playPreview();
                    }
                  },
                  borderRadius: BorderRadius.circular(40),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF6C63FF), // Play button background color
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2), // Slightly darker shadow
                          blurRadius: 8, // Increases the softness of the shadow
                          offset: const Offset(3, 3), // Shadow positioning
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1), // Subtle highlight effect
                          blurRadius: 4,
                          offset: const Offset(-2, -2), // Gives a raised effect
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.voiceMessage.isPlaying? Icons.pause_rounded : Icons.play_arrow_rounded, // Play button icon
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Animated Waveform
          Expanded(
            child: SingleChildScrollView(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _waveformBars.map((barHeight) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2.0),
                    width: 4.0,
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: Color(0xFF6C63FF),
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // const SizedBox(width: 12),
          // Stop Button
          GestureDetector(
            onTap: widget.voiceMessage.recordingState == RecordingState.paused? widget.voiceMessage.cancel : widget.onPauseStopRecording,
            child: Icon(
              widget.voiceMessage.recordingState == RecordingState.paused? Icons.delete_rounded : Icons.stop,
              color: Color( widget.voiceMessage.recordingState == RecordingState.paused? 0xFFFF3B30 : 0xFF6C63FF),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
