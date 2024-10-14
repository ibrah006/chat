
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
}