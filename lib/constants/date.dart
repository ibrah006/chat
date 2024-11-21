
import 'package:intl/intl.dart';

class DateManager {
  static String getDuration(Duration duration) {
    String negativeSign = duration.isNegative ? '-' : '';
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60).abs());
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60).abs());
    return "$negativeSign${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  static String formatDuration(int? seconds) {

    if (seconds==null) return "00:00";

    int minutes = seconds ~/ 60; // Get the number of minutes
    int remainingSeconds = seconds % 60; // Get the remaining seconds

    String formattedMinutes = minutes.toString().padLeft(2, '0'); // Ensure 2 digits for minutes
    String formattedSeconds = remainingSeconds.toString().padLeft(2, '0'); // Ensure 2 digits for seconds

    return "$formattedMinutes:$formattedSeconds";
  }

  
  static String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));

    if (dateTime.isAfter(today)) {
      // Today
      return DateFormat.Hm().format(dateTime); // Shows only the time, e.g., "14:33"
    } else if (dateTime.isAfter(yesterday)) {
      // Yesterday
      return 'Yesterday';
    } else {
      // Older than yesterday
      return DateFormat.yMMMd().format(dateTime); // Shows the date, e.g., "Oct 10, 2023"
    }
  }

  static String formatSecondsToMinutes(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

}