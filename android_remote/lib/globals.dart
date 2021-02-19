library android_remote.globals;

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:intl/intl.dart';
import 'modules/bluetooth_manager.dart';

// Flags for application operations.
bool updateMode = false;
bool debugMode = false;
bool controlMode = false;
String Datetimeformat ='yyyy/MM/dd, kk:mm:ss';
String formattedDate = DateFormat(Datetimeformat).format(DateTime.now())+" | "+"Console initialized";
BluetoothDevice lastdevice;
List<String> strArr = ["Console initialized"]; // To store the console log outputs.
List<String> BackupstrArr = [formattedDate];
Color robotStatus = Colors.red;

BluetoothController btController;

// Command strings: [SRC][DST][OP] 2 CHARACTERS EA
final String strStartExplore = 'EX_START';
final String strFastestPath = 'FP_START';
final String strForward = 'ROBOT_FW';
final String strRotateLeft = 'ROBOT_RL';
final String strRotateRight = 'ROBOT_RR';
final String strReverse = 'ROBOT_RV';
final String strImgFind ='IF_START';

// Arena
/*List<List<String>> arenaState = [
  ['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''],
  ['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''],
  ['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''],
  ['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''],
  ['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''],
  ['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''],
  ['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''],
  ['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''],
  ['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''],
  ['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''],
  ['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''],
  ['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''],
  ['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''],
  ['aB', 'aG', 'aR', 'aW', '', 'A', 'B', 'C', 'D', 'E', '', '', '', '', ''],
  ['cY', '', '1', '2', '3', '4', '5', '', 'P1', '', '', '', '', '', ''],
  ['', '', '', 'T', '', '', '', '', '', '', '', '', '', '', ''],
  ['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''],
  ['R', 'RH', 'R', '', '', '', '', '', '', '', '', '', '', '', ''],
  ['R', 'R', 'R', '', '', '', '', '', '', '', '', '', '', '', ''],
  ['R', 'R', 'R', '', '', '', '', '', '', '', '', '', '', '', '']
];*/
