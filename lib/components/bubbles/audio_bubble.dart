
import 'package:chat/constants/date.dart';
import 'package:chat/services/messages/message.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AudioBubble extends StatefulWidget {

  AudioBubble(
    this.message, {
    Key? key,
  }) : super(key: key);

  final AudioMessage message;

  @override
  State<AudioBubble> createState() => _AudioBubbleState();
}

class _AudioBubbleState extends State<AudioBubble> {

  late Future<String> path;
  bool get isSender => widget.message.isSender;

  String get audioDuration => DateManager.formatSecondsToMinutes(widget.message.duration.inSeconds);

  bool isPlaying = false;

  void onPlayPause() {

  }

  void download() {
    path = _getPath();
  }

  Future<String> _getPath() async {
    await widget.message.download();

    return widget.message.path;
  }

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
          width: 200,
          margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: isSender ? Color(0xFF6C63FF).withOpacity(0.1) : Colors.grey[200],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isSender ? 12 : 0),
              topRight: Radius.circular(isSender ? 0 : 12),
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          child: Row(
            children: [
              // Play/Pause Button
              FutureBuilder(
                future: path,
                builder: (context, AsyncSnapshot asyncSnapshot) {
              
                  print("path; ${asyncSnapshot.data}");
              
                  return GestureDetector(
                    onTap: asyncSnapshot.data == "downloading"? download : onPlayPause,
                    child: CircleAvatar(
                      backgroundColor: asyncSnapshot.data == "downloading"? Colors.transparent : (isSender ? Color(0xFF6C63FF) : Colors.grey[500]),
                      radius: 20,
                      child: Icon(
                        asyncSnapshot.data == "downloading"? Icons.download : (isPlaying ? Icons.pause : Icons.play_arrow),
                        color: isSender? Color(0xFF6C63FF) : Colors.white,
                        size: asyncSnapshot.data == "downloading"? 27.5 : 24,
                      ),
                    ),
                  );
                }
              ),
              const SizedBox(width: 12),
        
              // Waveform and Duration
              Expanded(
                child: Container(
                  height: 30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Placeholder for the waveform
                      FutureBuilder(
                        future: path,
                        builder: (context, asyncSnapshot) {
                          
                          print("asyncSnapshot hasData: ${asyncSnapshot.hasData}, value: ${asyncSnapshot.data}");
                      
                          return Divider(
                            thickness: 2,
                            height: 6,
                          );
                        }
                      ),
                      // const SizedBox(height: 6),
                      Text(
                        audioDuration,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    download();
  }
}

/// Audio Waveform