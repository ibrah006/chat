
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CallBubble extends StatelessWidget {
  final bool isMissed;
  final String callType; // 'Incoming' or 'Outgoing'
  final String callTime; // e.g., "2:15 PM"
  final String duration; // e.g., "5 mins"

  const CallBubble({
    required this.isMissed,
    required this.callType,
    required this.callTime,
    required this.duration
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isMissed ? Colors.red[50] : Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isMissed ? Icons.phone_missed : Icons.phone,
              color: isMissed ? Colors.red : Colors.green,
              size: 24,
            ),
            const SizedBox(width: 8),
            Column(
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
                  isMissed ? 'Missed Call' : "Duration: $duration",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}