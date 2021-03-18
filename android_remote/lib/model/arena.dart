import 'dart:math';

import 'package:android_remote/main.dart';
import 'package:android_remote/model/robot.dart';
import 'package:android_remote/model/waypoint.dart';
import 'package:flutter/material.dart';
import 'package:android_remote/modules/descriptor_manager.dart';
import '../globals.dart';

class Arena {
  List<List<int>> explorationStatus, obstaclesRecords;
  WayPoint _wayPoint;
  Robot _robot;
  List<String> _imagesCoord;
  List<int> _imagesStatus;
  int temp = 0;
  int _imageDirection = 0;

  Arena(String selector, bool unity) {
    _imagesCoord = List.generate(15, (index) => '-1,-1');
    _imagesStatus = List.generate(15, (index) => 0);
    if (selector[0] == '1') {
      this.explorationStatus = List.generate(
        20,
        (index) => List.generate(15, (index) => 0, growable: false),
        growable: false,
      );
      if (unity) {
        unityWidgetController.postMessage(
            'Tilemap - Level 1 - Detail', 'ResetArena', '');
      }
    } else if (backupArena != null) {
      this.explorationStatus = backupArena.explorationStatus;
    }

    if (selector[1] == '1') {
      this.obstaclesRecords = List.generate(
        20,
        (index) => List.generate(15, (index) => 0, growable: false),
        growable: false,
      );
    } else if (backupArena != null) {
      this.obstaclesRecords = backupArena.obstaclesRecords;
    }

    if (selector[2] == '1') {
      this._robot = Robot(1, 1, 1, 1, 0);
      if (unity) {
        unityWidgetController.postMessage(
          'Player_Isometric_Witch',
          'setUnityRobot',
          '1:1:0',
        );
      }
    } else if (backupArena != null) {
      this._robot = backupArena._robot;
    }

    if (selector[3] == '1') {
      this._wayPoint = WayPoint(-1, -1);
    } else if (backupArena != null) {
      this._wayPoint = backupArena._wayPoint;
    }

    backupArena = null;
  }

  bool setWayPoint(int x, int y, bool isUnity) {
    int checker = explorationStatus[x][y] + WayPoint.isWayPoint(x, y);
    if (WayPoint.isWayPoint(x, y) == 0) {
      // Sets the waypoint if the tile is not already a waypoint;
      if (!isUnity)
        unityWidgetController.postMessage(
          'Tilemap - Level 1 - Detail',
          'SetWaypointByFlutter',
          "$x:$y:$checker",
        );
      this._wayPoint.update(x, y);
      return true;
    } else {
      // Remove the waypoint if is already there.
      if (!isUnity)
        unityWidgetController.postMessage(
          'Tilemap - Level 1 - Detail',
          'DisableWaypointByFlutter',
          "$x:$y:$checker",
        );
      this._wayPoint.update(-1, -1);
      return false;
    }
  }

  Future<void> updateMapFromDescriptors(
      bool isAMDTool, String mapDescriptor1, String mapDescriptor2) async {
    List<String> obstaclesCoords =
        DescriptorDecoder.decodeDescriptor1(isAMDTool, mapDescriptor1);

    DescriptorDecoder.decodeDescriptor2(
        isAMDTool, obstaclesCoords, mapDescriptor2);
  }

  int getRobotDir() {
    return _robot.direction;
  }

  bool moveRobot(String operation) {
    bool isRotate = false;
    robotStatus = 'Moving';
    switch (operation) {
      case 'FW':
        _robot.moveForward();
        break;
      case 'RL':
        _robot.rotate(-1);
        isRotate = true;
        break;
      case 'RR':
        _robot.rotate(1);
        isRotate = true;
        break;
    }

    return isRotate || (_robot.isDisplaced() != 0);
  }

  void resetRobotPos() {
    streamController.add('Reset Robot to Start Location.');
    this._robot = Robot(18, 1, 18, 1, 0);
  }

  bool setRobotPos(int x, int y, int dir) {
    if (dir >= 90) dir = ((dir / 90).floor()) % 4; // for amdtool compatibility.

    if (y == 0 || y == 14 || x == 0 || x == 19) {
      return false;
    } else {
      _robot.prevX = _robot.x;
      _robot.prevY = _robot.y;

      _robot.x = x;
      _robot.y = y;
      _robot.direction = dir;
      unityWidgetController.postMessage(
        'Player_Isometric_Witch',
        'setUnityRobot',
        '$x:$y:$dir',
      );
      return true;
    }
  }

  String isRobot(int x, int y) {
    int xi = 0;
    int yj = 0;

    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        if ((this._robot.x + i) == x && (this._robot.y + j) == y) {
          if (xi + yj == 0) {
            // directions
            switch (this._robot.direction) {
              case 0:
                xi = this._robot.x + 1;
                yj = this._robot.y;
                break;
              case 1:
                xi = this._robot.x;
                yj = this._robot.y + 1;
                break;
              case 2:
                xi = this._robot.x - 1;
                yj = this._robot.y;
                break;
              case 3:
                xi = this._robot.x;
                yj = this._robot.y - 1;
                break;
            }
          }

          explorationStatus[x][y] = 1;

          if (xi == x && yj == y) {
            return 'RH';
          } else {
            return 'RB';
          }
        }
      }
    }

    return '0';
  }

  void setObstacle(int x, int y) {
    this.obstaclesRecords[x][y] = 1;
    unityWidgetController.postMessage(
      'Player_Isometric_Witch',
      'setObstacles',
      '$x:$y:2',
    );
  }

  void removeObstacle(int x, int y) {
    this.obstaclesRecords[x][y] = 0;
    unityWidgetController.postMessage(
      'Player_Isometric_Witch',
      'setObstacles',
      '$x:$y:0',
    );
  }

  void setImage(int x, int y, int imageId, int dir) {
    if ((x >= 0 && x < 20) && (y >= 0 && y < 15)) {
      this.obstaclesRecords[x][y] = 0;
      String oldx = _imagesCoord[imageId - 1].split(',')[0];
      String oldy = _imagesCoord[imageId - 1].split(',')[1];
      _imagesCoord[imageId - 1] = '$x,$y';
      _imagesStatus[imageId - 1] = dir;

      // unityWidgetController.postMessage(
      //   'Tilemap - Level 1 - Detail',
      //   'SetImageRecTiles',
      //   '$x:$y:$imageId:$dir:$oldx:$oldy',
      // );
    } else {
      _imagesCoord[imageId - 1] = getRandomObstacle();
      _imagesStatus[imageId - 1] = -1;
    }
  }

  void rmvImage(int x, int y, int imageId, int dir) {
    if ((x >= 0 && x < 20) && (y >= 0 && y < 15)) {
      this.obstaclesRecords[x][y] = 0;

      _imagesCoord[imageId - 1] = '';
      _imagesStatus[imageId - 1] = 0;
    } else {}
  }

  void setExplored(int x, int y) {
    this.explorationStatus[x][y] = 1;
  }

  void removeExplored(int x, int y) {
    this.explorationStatus[x][y] = 0;
  }

  void refreshArena() {}

  Widget getArenaState(int x, int y, Function onTapFunction) {
    _imageDirection = 0;
    String item = isRobot(x, y);

    if (item == '0') {
      item = _inSpecialZone(x, y);
      if (item == '0') {
        int id = _imagesCoord.indexOf('$x,$y');
        if (id == -1) {
          if (obstaclesRecords[x][y] == 1) {
            item = 'O';
          } else {
            switch (explorationStatus[x][y] + WayPoint.isWayPoint(x, y)) {
              case 0:
                item = '0';
                break;
              case 1:
                item = '1';
                break;
              case 3:
                item = 'WP0';
                break;
              case 4:
                item = 'WP1';
                break;
            }
          }
        } else {
          item = 'n${id + 1}';
          _imageDirection = _imagesStatus[id];
        }
      } else if (item == 'lblX') {
        temp = y;
        item = 'lbl';
      } else if (item == 'lblY') {
        temp = x;
        item = 'lbl';
      }
    }
    return _resolveItem(item, onTapFunction);
  }

  // ignore: missing_return
  Widget _resolveItem(String item, Function onTapFunction) {
    switch (item) {
      case 'RB':
        return Container(
          color: Colors.grey,
          child: Container(
            color: Colors.blueGrey,
          ),
        );
        break;

      case 'RH':
        return Container(
          color: Colors.grey,
          child: Container(
            color: Colors.redAccent,
          ),
        );
        break;

      case '0': // Unexplored
        return Padding(
          padding: const EdgeInsets.all(1),
          child: GestureDetector(
            child: Container(
              color: Colors.grey,
              child: Text(''),
            ),
            onTap: onTapFunction,
          ),
        );
        break;
      case '1': // Explored
        return Padding(
          padding: const EdgeInsets.all(1),
          child: GestureDetector(
            child: Container(
              color: Colors.white,
              child: Text(''),
            ),
            onTap: onTapFunction,
          ),
        );
        break;

      case 'WP0': // WayPoint on unexplored tile
        return Padding(
          padding: const EdgeInsets.all(1),
          child: GestureDetector(
            child: Container(
              color: Colors.grey,
              child: Icon(
                Icons.pin_drop,
                color: Colors.white,
              ),
            ),
            onTap: onTapFunction,
          ),
        );
        break;

      case 'WP1': // WayPoint on explored tile
        return Padding(
          padding: const EdgeInsets.all(1),
          child: GestureDetector(
            child: Container(
              color: Colors.white,
              child: Icon(
                Icons.pin_drop,
                color: Colors.black,
              ),
            ),
            onTap: onTapFunction,
          ),
        );
        break;

      case 'O':
        return Padding(
          padding: const EdgeInsets.all(1),
          child: Container(
            color: Colors.black,
            child: Text(''),
          ),
        );
        break;

      // Image Recognition
      case 'n1':
      case 'n2':
      case 'n3':
      case 'n4':
      case 'n5':
      case 'n6':
      case 'n7':
      case 'n8':
      case 'n9':
      case 'n10':
      case 'n11':
      case 'n12':
      case 'n13':
      case 'n14':
      case 'n15':
        return Padding(
          padding: const EdgeInsets.all(1),
          child: RotatedBox(
            quarterTurns: _imageDirection,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/${item.substring(1)}.png'),
                  fit: BoxFit.fill,
                ),
                shape: BoxShape.rectangle,
              ),
            ),
          ),
        );
        break;
      case 'S':
        return Icon(Icons.play_arrow);
        break;
      case 'E':
        return Icon(Icons.golf_course);
        break;
      case 'SM':
      case 'EM':
        return Text('');
        break;
      case 'lbl':
        item = '$temp';
        return Center(
          child: Text(item),
        );
        break;
      default:
        return Center(
          child: Text(item),
        );
        break;
    }
  }

  String getRandomObstacle() {
    int x, y, rep;
    rep = 1;
    while (true) {
      x = 3 + Random().nextInt(13);
      y = obstaclesRecords[x].indexOf(1, rep++);
      if (y < 0 || y > 14) {
        continue;
      }
      if (_imagesCoord.contains('$x,$y')) {
        continue;
      } else {
        break;
      }
    }

    return '$x,$y';
  }

  String getImageStrings() {
    String result = '';
    for (int i = 0; i < _imagesCoord.length; i++) {
      if (_imagesCoord[i] != '-1,-1') {
        result += '(${i + 1},${_imagesCoord[i]})\n';
      }
    }
    return result;
  }
}

String _inSpecialZone(int x, int y) {
  if (x == 20 && y == 15) return 'SM';
  if (x == 20) return 'lblX';
  if (y == 15) return 'lblY';
  switch (x) {
    case 0:
    case 1:
    case 2:
      switch (y) {
        case 1:
          if (x == 1) return 'S';
          continue case2;
        case 0:
        case2:
        case 2:
          return 'SM';
          break;
      }
      break;
    case 17:
    case 18:
    case 19:
      switch (y) {
        case 13:
          if (x == 18) return 'E';
          continue case14;
        case 12:
        case14:
        case 14:
          return 'EM';
          break;
      }
      break;
  }
  return '0';
}
