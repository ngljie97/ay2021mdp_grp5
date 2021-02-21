import 'package:android_remote/globals.dart' as globals;
import 'package:android_remote/main.dart';
import 'package:flutter/material.dart';

class _Robot {
  int prevX;
  int x;
  int y;
  int prevY;
  int direction;

  _Robot(this.x, this.y, this.prevX, this.prevY, this.direction);

  void moveForward() {
    int newPos = 0;
    prevX = x;
    prevY = y;

    switch (this.direction) {
      case 0:
        newPos = this.x - 1;
        this.x = (newPos > 0 && newPos < 19) ? newPos : x;
        break;
      case 2:
        newPos = this.x + 1;
        this.x = (newPos > 0 && newPos < 19) ? newPos : x;
        break;
      case 1:
        newPos = this.y + 1;
        this.y = (newPos > 0 && newPos < 14) ? newPos : y;
        break;
      case 3:
        newPos = this.y - 1;
        this.y = (newPos > 0 && newPos < 14) ? newPos : y;
        break;
    }
  }

  void rotate(int modifier) {
    this.direction = (this.direction + modifier) % 4;
  }

  int isDisplaced() {
    return ((prevX - x) + (prevY - y));
  }
}

class _WayPoint {
  int x;
  int y;

  _WayPoint(this.x, this.y);
}

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

/*  List<List<int>> _arenaState = List.generate(
    20,
        (index) => List.generate(15, (index) => 0, growable: false),
    growable: false,
  );*/

  _WayPoint _wayPoint = _WayPoint(0, 0);
  _Robot _robot = _Robot(18, 1, 18, 1, 0);

  void setWayPoint(int x, int y) {
    this._wayPoint = _WayPoint(x, y);
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

/*    if (globals.updateMode) displayRobot();*/

    return isRotate || (_robot.isDisplaced() != 0);
  }

  void resetRobotPos() {
    streamController.add('Reset Robot to Start Location.');
    this._robot = _Robot(18, 1, 18, 1, 0);
/*    this.displayRobot();*/
  }

  void setRobotPos(int x, int y, int dir) {
    _robot.prevX = _robot.x;
    _robot.prevY = _robot.y;

    _robot.x = x;
    _robot.y = y;
    _robot.direction = dir;
  }

  int isRobot(int x, int y) {
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        if ((this._robot.x + 1) == x || (this._robot.y + 1) == y) {
          int xi = 0;
          int yj = 0;

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

          if (xi == x && yj == y)
            return 4;
          else
            return 3;
        }
      }
    }
    return 0;
  }

  Widget getArenaState(int x, int y, Function onTapFunction) {
    int item = isRobot(x, y);

    if (item == 0) {
      item = _obstaclesRecords[x][y];
    }

    if (item == 0) {
      item = _explorationStatus[x][y];
    }

    return _resolveItem ('$item', onTapFunction);
  }

  Widget _resolveItem(String item, Function onTapFunction) {
    switch (item) {
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

      case 'R':
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

      default:
        return Text(item);
    }
  }
}
