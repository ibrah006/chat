import 'package:chat/services/call/call_state.dart';
import 'package:chat/services/messages/message.dart';
import 'package:chat/services/notification/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CallBubble extends StatelessWidget {
  final Message callMessage;
  final CallState callState;
  final String callType; // 'Incoming' or 'Outgoing'
  final String callTime; // e.g., "2:15 PM"
  final String duration; // e.g., "5 mins"

  const CallBubble({
    Key? key,
    required this.callMessage,
    required this.callState,
    required this.callType,
    required this.callTime,
    required this.duration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMissed = callState == CallState.missed;
    final canJoin = callState == CallState.incoming || callState == CallState.ongoing;

    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isMissed ? Colors.red[50] : Color(0xFF6C63FF).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: canJoin? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Icon(
                    isMissed ? Icons.phone_missed : Icons.phone,
                    color: isMissed ? Colors.red : Colors.deepPurple.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  // crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "$callType Call - $callTime",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isMissed ? Colors.red : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      callState == CallState.incoming || callState == CallState.ongoing
                          ? "Waiting for you"
                          : callState == CallState.talking
                              ? 'Talking'
                              : isMissed
                                  ? 'Missed Call'
                                  : "Duration: $duration",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                if (canJoin) ...[
                  Expanded(child: SizedBox()),
                  LiveVideoCallIndicator()
                ]
              ],
            ),
            if (canJoin)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: ElevatedButton(
                  onPressed: () async {
                    // Add join call functionality here
                    NotificationService.onAnswerCall(callMessage.toMap());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6C63FF),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Join',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class LiveVideoCallIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const LiveVideoCallIndicator({
    Key? key,
    this.color = const Color(0xFF6C63FF),
    this.size = 40.0,
  }) : super(key: key);

  @override
  _LiveVideoCallIndicatorState createState() => _LiveVideoCallIndicatorState();
}

class _LiveVideoCallIndicatorState extends State<LiveVideoCallIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Pulsating Circle
            Container(
              width: widget.size * _scaleAnimation.value,
              height: widget.size * _scaleAnimation.value,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
            // Icon Container
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.videocam,
                color: Colors.white,
                size: widget.size * 0.6,
              ),
            ),
          ],
        );
      },
    );
  }
}
