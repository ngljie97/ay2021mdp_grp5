import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:android_remote/logic.dart';
import 'package:android_remote/main.dart';
import 'package:path_provider/path_provider.dart';

class QueueSys {
  static Queue<String> _queue = new Queue<String>();
  static Timer _timer;
  static bool queueStatus = false;

  QueueSys() {
    _timer = Timer.periodic(Duration(seconds: 1),
        (timer) => {if ((_timer.tick % 3) == 0) checkQueue()});
  }

  static Future<void> checkQueue() async {
    // checks if system occupied.
    if (!queueStatus) {
      // if system is free, check if any task is queued.
      if (_queue.isNotEmpty) {
        String task = _queue.removeFirst();
        await _runTask(task);
      }
    }
  }

  static Future<void> _runTask(String task) async {
    queueStatus = true;
    List<String> command = task.split(':');
    String cmdClean = cleanCommand(command[0]);
    List params = command.sublist(1);
    try {
      streamController.add('Dequeuing: $cmdClean');
      logToFile(cmdClean, params, executeCommand(cmdClean, params));
    } catch (e) {
      logToFile(cmdClean, params, false);
      streamController.add(
          'Failed to execute a previously queued command: $cmdClean with parameters $params');
      print(e);
    }

    command = [];
    queueStatus = false;
  }

  static void queueTask(String task) {
    List<String> taskList = task.split('\n');
    _queue.addAll(taskList);
/*
    if (!queueStatus)
      checkQueue(); */ // checks if any task running. if system is free, execute first task
  }

  static Future<String> get _localPath async {
    final directory = await getExternalStorageDirectory();

    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/MDPGrp5_log.txt');
  }

  static Future<File> logToFile(String cmd, List params, bool status) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString('${_timer.tick}||$cmd||$params');
  }
}
