import 'package:android_remote/globals.dart' as globals;
import 'package:android_remote/main.dart';
import 'package:android_remote/model/robot.dart';
import 'package:android_remote/model/waypoint.dart';
import 'package:flutter/material.dart';

class Arena {
  Arena();

  List<List<int>> _explorationStatus = List.generate(
    20,
    (index) => List.generate(15, (index) => 0, growable: false),
    growable: false,
  );
  List<List<int>> _obstaclesRecords = List.generate(
    20,
    (index) => List.generate(15, (index) => 0, growable: false),
    growable: false,
  );

  WayPoint _wayPoint = WayPoint(-1, -1);
  Robot _robot = Robot(18, 1, 18, 1, 0);

  void setWayPoint(int x, int y) {
    this._wayPoint.update(x, y);
  }

  bool moveRobot(String operation) {
    bool isRotate = false;

    if (globals.debugMode)
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

  void setRobotPos(int x, int y, int dir) {
    _robot.prevX = _robot.x;
    _robot.prevY = _robot.y;

    _robot.x = x;
    _robot.y = y;
    _robot.direction = dir;
  }

  String isRobot(int x, int y) {
    int xi = 0;
    int yj = 0;

    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        if ((this._robot.x + i) == x && (this._robot.y + j) == y) {
          if (xi + yj == 0) {
            switch (this._robot.direction) {
              case 0:
                xi = this._robot.x - 1;
                yj = this._robot.y;
                break;
              case 1:
                xi = this._robot.x;
                yj = this._robot.y + 1;
                break;
              case 2:
                xi = this._robot.x + 1;
                yj = this._robot.y;
                break;
              case 3:
                xi = this._robot.x;
                yj = this._robot.y - 1;
                break;
            }
          }

          _explorationStatus[x][y] = 1;

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
    this._obstaclesRecords[x][y] = 1;
  }

  void removeObstacle(int x, int y) {
    this._obstaclesRecords[x][y] = 0;
  }

  void setExplored(int x, int y) {
    this._explorationStatus[x][y] = 1;
  }

  void removeExplored(int x, int y) {
    this._explorationStatus[x][y] = 0;
  }

  void refreshArena() {

  }

  Widget getArenaState(int x, int y, Function onTapFunction) {
    String item = isRobot(x, y);

    if (item == '0') {
      item = _inSpecialZone(x, y);

      if (item == '0') {
        if (_obstaclesRecords[x][y] == 1) {
          item = 'O';
        } else {
          switch (_explorationStatus[x][y] + WayPoint.isWayPoint(x, y)) {
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
            child: Text('X'),
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
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/number_one.PNG'),
              fit: BoxFit.fill,
            ),
            shape: BoxShape.rectangle,
          ),
        );
      case 'n2':
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/number_two.PNG'),
              fit: BoxFit.fill,
            ),
            shape: BoxShape.rectangle,
          ),
        );
      case 'n3':
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/number_three.PNG'),
              fit: BoxFit.fill,
            ),
            shape: BoxShape.rectangle,
          ),
        );
      case 'n4':
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/number_four.PNG'),
              fit: BoxFit.fill,
            ),
            shape: BoxShape.rectangle,
          ),
        );
      case 'n5':
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/number_five.PNG'),
              fit: BoxFit.fill,
            ),
            shape: BoxShape.rectangle,
          ),
        );
        break;
      // End of Image Recognition

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
