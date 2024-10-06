import 'package:flutter/material.dart';

enum CallState { incoming, ongoing, missed, ended }

class CallBubble extends StatelessWidget {
  final CallState callState; // The state of the call (ongoing/incoming, missed, or ended)
  final String callTime; // The time of the call, e.g., "10:34 AM"

  CallBubble({
    required this.callState,
    required this.callTime,
  });

  // Method to get background color based on the call state
  Color _getBackgroundColor() {
    switch (callState) {
      case CallState.missed:
        return Colors.red.shade50; // Subtle red for missed calls
      case CallState.ended:
        return Colors.grey.shade100; // Subtle grey for ended calls
      case CallState.incoming || CallState.ongoing:
      default:
        return Colors.green.shade50; // Subtle green for ongoing/incoming calls
    }
  }

  // Method to get the icon based on the call state
  IconData _getIcon() {
    switch (callState) {
      case CallState.missed:
        return Icons.phone_missed;
      case CallState.ended:
        return Icons.call_end;
      case CallState.incoming || CallState.ongoing:
      default:
        return Icons.phone_in_talk;
    }
  }

  // Method to get the icon color based on the call state
  Color _getIconColor() {
    switch (callState) {
      case CallState.missed:
        return Colors.red.shade400;
      case CallState.ended:
        return Colors.grey.shade600;
      case CallState.incoming || CallState.ongoing:
      default:
        return Colors.green.shade400;
    }
  }

  // Method to get the call status text based on the call state
  String _getCallStatusText() {
    switch (callState) {
      case CallState.missed:
        return "Missed Call";
      case CallState.ended:
        return "Call Ended";
      case CallState.ongoing:
        return "Ongoing";
      default:
        return "Incoming";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0), // Reduced padding for compactness
            decoration: BoxDecoration(
              color: _getBackgroundColor(), // Background color based on the call state
              borderRadius: BorderRadius.circular(12), // Lesser border radius for a sharper design
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05), // Very subtle shadow for depth
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon representing the call type (missed, ended, or ongoing)
                Icon(
                  _getIcon(),
                  color: _getIconColor(),
                  size: 24.0, // Slightly larger icon size for clarity
                ),
                SizedBox(width: 12),

                // Column holding call status and call time
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getCallStatusText(), // Call status text based on call state
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4), // Slight space between text and call time
                    Text(
                      callTime,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}