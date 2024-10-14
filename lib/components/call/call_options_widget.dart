import 'dart:ui';

import 'package:flutter/material.dart';

class CallOptionsWidget extends StatelessWidget {
  final bool isSpeakerOn;
  final bool isMicOn;
  final bool isCameraOn;

  CallOptionsWidget({
    required this.isSpeakerOn,
    required this.isMicOn,
    required this.isCameraOn,
    required this.onSpeakerToggle,
    required this.onMicToggle,
    required this.onCameraToggle,
    required this.onEnd
  });

  Function() onSpeakerToggle, onMicToggle, onCameraToggle, onEnd;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: 95,
          width: MediaQuery.of(context).size.width,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                color: Colors.white.withOpacity(0.25),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            // color:  Colors.grey.shade50,//Colors.black, // For dark theme
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Speaker button
              _buildOptionButton(
                icon: isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                isActive: isSpeakerOn,
                onTap: onSpeakerToggle,
              ),
              // Camera on/off button
              _buildOptionButton(
                icon: isCameraOn ? Icons.videocam : Icons.videocam_off,
                isActive: isCameraOn,
                onTap: onCameraToggle,
              ),
              // End call button
              _buildOptionButton(
                icon: Icons.call_end,
                isActive: true,
                onTap: onEnd,
                isEndCall: true,
              ),
              // Mic on/off button
              _buildOptionButton(
                icon: isMicOn ? Icons.mic : Icons.mic_off,
                isActive: isMicOn,
                onTap: onMicToggle,
              ),
              // Camera switch button
              _buildOptionButton(
                icon: Icons.switch_camera,
                isActive: true,
                onTap: () {
                  // Handle camera switch
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method to build interactive option buttons
  Widget _buildOptionButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    bool isEndCall = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isEndCall
              ? Colors.redAccent.withOpacity(0.2) // Softer red for end call
              : isActive
                  ? Colors.blueAccent.withOpacity(0.2) // Light green for active
                  : Colors.grey.withOpacity(0.1), // Light grey for inactive
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isEndCall
              ? Colors.redAccent
              : isActive
                  ? Colors.blueAccent
                  : Colors.grey,
          size: 28.0,
        ),
      ),
    );
  }
}
