library android_remote.globals;

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

bool updateMode = false;
BluetoothDevice selectedDevice;
BluetoothConnection connection;
bool isConnecting=true;
bool isDisconnecting=false;
BluetoothDevice server;
bool isConnected=false;
