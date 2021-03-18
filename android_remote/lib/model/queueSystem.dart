import 'dart:async';
import 'dart:io';

import 'package:android_remote/logic.dart';
import 'package:android_remote/main.dart';
import 'package:path_provider/path_provider.dart';

class QueueSys {
  static List<String> _queue = [];
  static Timer _timer;
  static bool running = false;
  static int taskNo = 0;

  QueueSys() {
    _timer =
        Timer.periodic(Duration(milliseconds: 500), (timer) => {checkQueue()});
    prepareFile();
  }

  static Future<void> checkQueue() async {
    // checks if system occupied.
    if (!running) {
      // if system is free, check if any task is queued.
      if (_queue.isNotEmpty && ((taskNo % 2) == (_timer.tick % 2))) {
        String task = _queue[taskNo];
        await _runTask(task);
      }
      if (taskNo == _queue.length && taskNo != 0) {
        taskNo = 0;
        _queue.clear();
      }
    }
  }

  static Future<void> _runTask(String task) async {
    running = true;
    List<String> tmp = task.split(':');
    String command = cleanCommand(tmp[0]);
    command = (command.startsWith('B')) ? command.substring(1) : command;
    List params = tmp.sublist(1);

    try {
      streamController.add('Dequeuing: $command');
      bool success = await _executionStatus(command, params);
      await logToFile(command, params, success);
      streamController.add('Task finished: $command');
    } catch (e) {
      await logToFile(command, params, false);
      streamController.add(
          'Failed to execute a previously queued command: $command with parameters $params');
      print(e);
    }

    tmp = [];
    taskNo++;
    running = false;
  }

  static Future<bool> _executionStatus(String cmd, List params) async {
    return await executeCommand(cmd, params);
  }

  static void queueTask(String task) {
    List<String> taskList = task.split('\n');
    taskList.forEach((element) {if(element.contains('\n')) element.replaceAll('\n', '');});
    _queue.addAll(taskList);
  }

  static Future<String> get _localPath async {
    final directory =
        await getExternalStorageDirectories(type: StorageDirectory.documents);

    return directory.first.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/MDPGrp5_log.csv');
  }

  static Future<File> _writeToFile(String toWrite) async {
    final file = await _localFile;

    return file.writeAsString(toWrite, mode: FileMode.append, flush: true);
  }

  static Future<File> logToFile(String cmd, List params, bool status) async {
    // Write the file
    return _writeToFile('${_timer.tick},$cmd,${params.join(',')}\n');
  }

  static Future<void> prepareFile() async {
    DateTime _now = DateTime.now();

    // Write the file
    return _writeToFile(
        'Application started at ${_now.day}/${_now.month}/${_now.year} ${_now.hour}:${_now.minute}:${_now.second}|| || \n');
  }
}
