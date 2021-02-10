library android_remote.globals;

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

bool updateMode = false;
BluetoothDevice selectedDevice;
List<String> strArr = [];
bool controlMode = true;
BluetoothConnection connection;
bool isConnecting = false;
bool isDisconnecting = false;
BluetoothDevice server;
bool isConnected = false;


final String strStartExplore = 'startExplore:151';
final String strFastestPath = 'fastestPath:234';
final String strForward = 'forward:123';
final String strRotateLeft = 'rotateLeft:321';
final String strRotateRight = 'rotateRight:654';
final String strReverse = 'reverse:345';
