import 'dart:developer';

class Log {
  static void d(String tag, String message) {
    print("DEBUG", tag, message);
  }

  static void e(String tag, String message) {
    print("ERROR", tag, message);
  }

  static void i(String tag, String message) {
    print("INFO", tag, message);
  }

  static void print(String verbose, String tag, String message) {
    DateTime now = DateTime.now().toLocal();
    String hours = now.hour < 10 ? "0${now.hour}" : "${now.hour}";
    String minutes = now.minute < 10 ? "0${now.minute}" : "${now.minute}";
    String seconds = now.second < 10 ? "0${now.second}" : "${now.second}";
    String milliseconds;
    if (now.millisecond < 10) {
      milliseconds = "00${now.millisecond}";
    } else if (now.millisecond < 100) {
      milliseconds = "0${now.millisecond}";
    } else {
      milliseconds = "${now.millisecond}";
    }
    log("$verbose - $hours:$minutes:$seconds $milliseconds - $tag->$message");
  }
}
