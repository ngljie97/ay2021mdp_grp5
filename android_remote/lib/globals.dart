library android_remote.globals;

import 'package:flutter/material.dart';

import 'modules/bluetooth_manager.dart';

// Flags for application operations.
bool updateMode = false;
bool debugMode = false;
bool controlMode = false;

List<String> strArr = ["Console initialized"]; // To store the console log outputs.

Color robotStatus = Colors.red;

BluetoothController btController;

// Command strings: [SRC][DST][OP] 2 CHARACTERS EA
final String strStartExplore = 'AN:AD:SE';
final String strFastestPath = 'AN:AD:FP';
final String strForward = 'AN:AD:FW';
final String strRotateLeft = 'AN:AD:RL';
final String strRotateRight = 'AN:AD:RR';
final String strReverse = 'AN:AD:RV';

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
