import 'package:android_remote/main.dart';
import 'package:android_remote/model/robot.dart';
import 'package:android_remote/model/waypoint.dart';
import 'package:flutter/material.dart';
import 'package:android_remote/modules/descriptor_decoder.dart';
import '../globals.dart';

class Arena {
  List<List<int>> explorationStatus, obstaclesRecords;
  WayPoint _wayPoint;
  Robot _robot;
  int _imagedirection = 0;

  Arena(String selector) {
    if (selector[0] == '1') {
      this.explorationStatus = List.generate(
        20,
            (index) => List.generate(15, (index) => 0, growable: false),
        growable: false,
      );
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

  bool setWayPoint(int x, int y) {
    if (WayPoint.isWayPoint(x, y) == 0) {
      // Sets the waypoint if the tile is not already a waypoint;
      this._wayPoint.update(x, y);
      return true;
    } else {
      // Remove the waypoint if is already there.
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

  void setImage(int x, int y, int imageid, int dir) {
    this.obstaclesRecords[x][y] = imageid * 10 + dir;
  }

  void setExplored(int x, int y) {
    this.explorationStatus[x][y] = 1;
  }

  void removeExplored(int x, int y) {
    this.explorationStatus[x][y] = 0;
  }

  void refreshArena() {}

  Widget getArenaState(int x, int y, Function onTapFunction) {
    String item = isRobot(x, y);

    if (item == '0') {
      // item = _inSpecialZone(x, y);
      item = '0';
      if (item == '0') {
        if (obstaclesRecords[x][y] >= 1) {
          int first = (obstaclesRecords[x][y] / 10).floor();
          int second = (obstaclesRecords[x][y] % 10);
          switch (first) {
            case 101:
              item = 'n1';
              this._imagedirection = second;
              break;
            case 102:
              item = 'n2';
              this._imagedirection = second;
              break;
            case 103:
              item = 'n3';
              this._imagedirection = second;
              break;
            case 104:
              item = 'n4';
              this._imagedirection = second;
              break;
            case 105:
              item = 'n5';
              this._imagedirection = second;
              break;
            case 106:
              item = 'n6';
              this._imagedirection = second;
              break;
            case 107:
              item = 'n7';
              this._imagedirection = second;
              break;
            case 108:
              item = 'n8';
              this._imagedirection = second;
              break;
            case 109:
              item = 'n9';
              this._imagedirection = second;
              break;
            case 110:
              item = 'n10';
              this._imagedirection = second;
              break;
            case 111:
              item = 'n11';
              this._imagedirection = second;
              break;
            case 112:
              item = 'n12';
              this._imagedirection = second;
              break;
            case 113:
              item = 'n13';
              this._imagedirection = second;
              break;
            case 114:
              item = 'n14';
              this._imagedirection = second;
              break;
            case 115:
              item = 'n15';
              this._imagedirection = second;
              break;
            default:
              item = 'O';
              break;
          }
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
      }
    }

    return _resolveItem(item, onTapFunction);
  }

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
      case 'A':
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/letter_a.PNG'),
              fit: BoxFit.fill,
            ),
            shape: BoxShape.rectangle,
          ),
        );
        break;

      case 'B':
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/letter_b.PNG'),
              fit: BoxFit.fill,
            ),
            shape: BoxShape.rectangle,
          ),
        );
        break;
      case 'C':
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/letter_c.PNG'),
              fit: BoxFit.fill,
            ),
            shape: BoxShape.rectangle,
          ),
        );
        break;
      case 'D':
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/letter_d.PNG'),
              fit: BoxFit.fill,
            ),
            shape: BoxShape.rectangle,
          ),
        );
        break;
      case 'aB':
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/arrow_blue.PNG'),
              fit: BoxFit.fill,
            ),
            shape: BoxShape.rectangle,
          ),
        );
        break;
      case 'aG':
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/arrow_green.PNG'),
              fit: BoxFit.fill,
            ),
            shape: BoxShape.rectangle,
          ),
        );
        break;
      case 'aR':
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/arrow_red.PNG'),
              fit: BoxFit.fill,
            ),
            shape: BoxShape.rectangle,
          ),
        );
        break;
      case 'aW':
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/arrow_white.PNG'),
              fit: BoxFit.fill,
            ),
            shape: BoxShape.rectangle,
          ),
        );
        break;
      case 'cY':
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/circle_yellow.PNG'),
              fit: BoxFit.fill,
            ),
            shape: BoxShape.rectangle,
          ),
        );
      case 'n1':
        return RotatedBox(
            quarterTurns: this._imagedirection,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/number_one.PNG'),
                  fit: BoxFit.fill,
                ),
                shape: BoxShape.rectangle,
              ),
            ));
      case 'n2':
        return RotatedBox(
            quarterTurns: this._imagedirection,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/number_two.PNG'),
                  fit: BoxFit.fill,
                ),
                shape: BoxShape.rectangle,
              ),
            ));
      case 'n3':
        return RotatedBox(
            quarterTurns: this._imagedirection,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/number_three.PNG'),
                  fit: BoxFit.fill,
                ),
                shape: BoxShape.rectangle,
              ),
            ));
      case 'n4':
        return RotatedBox(
            quarterTurns: this._imagedirection,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/number_four.PNG'),
                  fit: BoxFit.fill,
                ),
                shape: BoxShape.rectangle,
              ),
            ));
      case 'n5':
        return RotatedBox(
            quarterTurns: this._imagedirection,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/number_five.PNG'),
                  fit: BoxFit.fill,
                ),
                shape: BoxShape.rectangle,
              ),
            ));
        break;
    // End of Image Recognition
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
            quarterTurns: this._imagedirection,
            child: Container(
              color: Colors.black,
              child: Text(item.substring(1),
                  textAlign: TextAlign.center,
                  style:
                  TextStyle(fontSize: 30.0, fontWeight: FontWeight.w500)),
            ),
          ),
        );
        break;
        return RotatedBox(
            quarterTurns: this._imagedirection,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/number_five.PNG'),
                  fit: BoxFit.fill,
                ),
                shape: BoxShape.rectangle,
              ),
            ));
        break;
      case 'S':
        return Icon(Icons.play_arrow);
        break;
      case 'E':
        return Icon(Icons.golf_course);
        break;
      case 'SM':
        return Text('');
        break;
      case 'EM':
        return Text('');
        break;

      default:
        return Text(item);
        break;
    }
  }
}

String _inSpecialZone(int x, int y) {
  switch (x) {
    case 0:
    case 1:
    case 2:
      switch (y) {
        case 13:
          if (x == 1) return 'E';
          continue case14;
        case 12:
        case14:
        case 14:
          return 'EM';
          break;
      }
      break;
    case 17:
    case 18:
    case 19:
      switch (y) {
        case 1:
          if (x == 18) return 'S';
          continue case2;
        case 0:
        case2:
        case 2:
          return 'SM';
          break;
      }
      break;
  }
  return '0';
}