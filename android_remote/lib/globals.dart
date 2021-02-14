library android_remote.globals;

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

bool updateMode = false;
bool debugMode = false;
BluetoothDevice selectedDevice;
List<String> strArr = [];
bool controlMode = false;
BluetoothConnection connection;
bool isConnecting = false;
bool isDisconnecting = false;
BluetoothDevice server;
bool isConnected = false;
Color robotStatus = Colors.red;
Color bluetoothStatus = Colors.red;

// Command strings: [SRC][DST][OP] 2 CHARACTERS EA
final String strStartExplore = 'ANADSE';
final String strFastestPath = 'ANADFP';
final String strForward = 'ANADFW';
final String strRotateLeft = 'ANADRL';
final String strRotateRight = 'ANADRR';
final String strReverse = 'ANADRV';

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
