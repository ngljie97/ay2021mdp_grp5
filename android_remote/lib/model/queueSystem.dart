import 'dart:async';
import 'dart:collection';

import 'package:android_remote/logic.dart';
import 'package:android_remote/main.dart';

class QueueSys {
  static Queue<String> _queue = new Queue<String>();
  static Timer _timer;
  static bool queueStatus = false;

  QueueSys() {
    _timer =
        Timer.periodic(Duration(milliseconds: 1500), (timer) => checkQueue());
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

    try {
      await executeCommand(command[0], command.sublist(1));
    } catch (e) {
      streamController
          .add('Failed to execute a previously queued command: ${command[0]}');
      print(e);
    }

    command = [];
    queueStatus = false;
  }

  static void queueTask(String task) {
    List<String> taskList = task.split('\n');
    _queue.addAll(taskList);

    checkQueue(); // checks if any task running. if system is free, execute first task.
    QueueSys(); // reset timer.
  }
}
