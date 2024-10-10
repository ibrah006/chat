import 'package:chat/services/call/call_details.dart';
import 'package:chat/services/call/call_state.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CallBubble extends StatelessWidget {
  final CallDetails callDetails;

  CallBubble({
    required this.callDetails
  });

  // Method to get background color based on the call state
  Color _getBackgroundColor() {
    switch (callDetails.state) {
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
    switch (callDetails.state) {
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
    switch (callDetails.state) {
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
    switch (callDetails.state) {
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
                      DateFormat("hh:mm").format(callDetails.datetime),
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