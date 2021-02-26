library android_remote.globals;

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:intl/intl.dart';

import 'model/arena.dart';
import 'modules/bluetooth_manager.dart';

// Flags for application operations.
bool updateMode = false;
bool debugMode = false;
bool controlMode = false;
bool gyroMode = false;
String robotStatus = 'MOVING';
String Datetimeformat = 'yyyy/MM/dd, kk:mm:ss';
String formattedDate = DateFormat(Datetimeformat).format(DateTime.now()) +
    " | " +
    "Console initialized";
BluetoothDevice lastDevice;

List<String> strArr = [
  "Console initialized"
]; // To store the console log outputs.
List<String> BackupstrArr = [formattedDate];

BluetoothController btController;
Arena arena;
Arena backupArena;

// Command strings (sending)
final String strStartExplore = 'EX_START';
final String strFastestPath = 'FP_START';
final String strImgFind = 'IF_START';

// Move robot
final String strForward = 'ROBOT_FW';
final String strRotateLeft = 'ROBOT_RL';
final String strRotateRight = 'ROBOT_RR';

const String strSetWayPoint = 'SET_WAYPOINT';
const String strRemoveWayPoint = 'RM_WAYPOINT';

// Command list (receiving)
const String strRobotPos = 'ROBOT_POS';
const String strAddObs = 'ADD_OBSTACLE';
const String strRmObs = 'RM_OBSTACLE';

const String strAddImage = 'IMAGE';
const String strDelImage = 'DELETE_IMAGE';

const String strUpdateMap = 'MAP';

// Command list to indicate robot status
const String strFinishedIR = 'FINISH_IR';
const String strFinishedEx = 'FINISH_EX';
const String strFinishedFP = 'FINISH_FP';
const String strWayPoint = 'WAYPOINT';

// Command list (from AMDTOOLS)
const String amdRobotPos = 'ROBOTPOSITION';
const String amdUpdateObs = 'GRID';

// Command prefixes (receive)
final String strCommand1 = '';
