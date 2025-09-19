import 'dart:developer' as dev;
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Logger {
  static Future<String> getLogPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return "${dir.path}/log.txt";
  }

  static Future<void> log(String message) async {
    final fullMessage = "${DateTime.now()} - $message";
    final logFile = File(await getLogPath());
    if (!logFile.existsSync()) logFile.createSync();
    var log = logFile.readAsStringSync();
    log = "$log\n$fullMessage";
    dev.log("Logged: $fullMessage");
    logFile.writeAsStringSync(log);
  }

  static Future<String> getLogs() async {
    final logFile = File(await getLogPath());
    if (logFile.existsSync()) return logFile.readAsStringSync();
    return "";
  }

  static Future<void> deleteLogs() async {
    final logFile = File(await getLogPath());
    if (logFile.existsSync()) logFile.deleteSync();
  }
}
