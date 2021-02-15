import 'package:android_remote/globals.dart' as globals;
import 'package:flutter/material.dart';

class _Robot {
  int prevX;
  int prevY;
  int x;
  int y;
  String direction;

  _Robot(this.x, this.y, this.prevX, this.prevY, this.direction);

  void moveForward() {
    int newPos = 0;
    prevX = x;
    prevY = y;

    switch (this.direction) {
      case 'N':
        newPos = this.x - 1;
        this.x = (newPos > 0 && newPos < 19) ? newPos : x;
        break;
      case 'S':
        newPos = this.x + 1;
        this.x = (newPos > 0 && newPos < 19) ? newPos : x;
        break;
      case 'E':
        newPos = this.y + 1;
        this.y = (newPos > 0 && newPos < 14) ? newPos : y;
        break;
      case 'W':
        newPos = this.y - 1;
        this.y = (newPos > 0 && newPos < 14) ? newPos : y;
        break;
    }
  }

  void rotateLeft() {
    switch (this.direction) {
      case 'N':
        this.direction = 'W';
        break;
      case 'S':
        this.direction = 'E';
        break;
      case 'E':
        this.direction = 'N';
        break;
      case 'W':
        this.direction = 'S';
        break;
    }
  }

  void rotateRight() {
    switch (this.direction) {
      case 'N':
        this.direction = 'E';
        break;
      case 'S':
        this.direction = 'W';
        break;
      case 'E':
        this.direction = 'S';
        break;
      case 'W':
        this.direction = 'N';
        break;
    }
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

  List<List<String>> _arenaState = List.generate(
    20,
    (index) => List.generate(15, (index) => '0', growable: false),
    growable: false,
  );
  _WayPoint _wayPoint = _WayPoint(0, 0);
  _Robot _robot = _Robot(18, 1, 18, 1, 'N');

  void setWayPoint(int x, int y) {
    this._wayPoint = _WayPoint(x, y);
  }

  bool moveRobot(String operation) {
    switch (operation) {
      case 'FW':
        _robot.moveForward();
        break;
      case 'RL':
        _robot.rotateLeft();
        break;
      case 'RR':
        _robot.rotateRight();
        break;
    }

    if (globals.updateMode) setRobotPos();

    return (_robot.isDisplaced() != 0);
  }

  void setRobotPos() {
    void _clearPrev(int flag) {
      switch (flag) {
        case 1:
          _arenaState[_robot.x + 2][_robot.y - 1] = '1';
          _arenaState[_robot.x + 2][_robot.y - 0] = '1';
          _arenaState[_robot.x + 2][_robot.y + 1] = '1';
          break;
        case -1:
          _arenaState[_robot.x - 2][_robot.y - 1] = '1';
          _arenaState[_robot.x - 2][_robot.y - 0] = '1';
          _arenaState[_robot.x - 2][_robot.y + 1] = '1';
          break;
        case 2:
          _arenaState[_robot.x - 1][_robot.y + 2] = '1';
          _arenaState[_robot.x - 0][_robot.y + 2] = '1';
          _arenaState[_robot.x + 1][_robot.y + 2] = '1';
          break;
        case -2:
          _arenaState[_robot.x - 1][_robot.y - 2] = '1';
          _arenaState[_robot.x - 0][_robot.y - 2] = '1';
          _arenaState[_robot.x + 1][_robot.y - 2] = '1';
          break;
      }
    }

    int xi = 0;
    int yj = 0;

    int flag = ((_robot.prevX - _robot.x) + ((_robot.prevY - _robot.y) * 2));
    if (flag != 0) {
      _clearPrev(flag);
    }

    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        _arenaState[this._robot.x + i][this._robot.y + j] = 'R';
      }
    }

    switch (this._robot.direction) {
      case 'N':
        xi = this._robot.x - 1;
        yj = this._robot.y;
        break;
      case 'S':
        xi = this._robot.x + 1;
        yj = this._robot.y;
        break;
      case 'E':
        xi = this._robot.x;
        yj = this._robot.y + 1;
        break;
      case 'W':
        xi = this._robot.x;
        yj = this._robot.y - 1;
        break;
    }
    _arenaState[xi][yj] = 'RH';
  }

  Widget getArenaState(int x, int y) {
    String state = _arenaState[x][y];
    switch (state) {
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

      case '0':
        return Padding(
            padding: const EdgeInsets.all(1),
            child: Container(
              color: Colors.black54,
              child: Text(''),
            ));
        break;

      case '1':
        return Padding(
            padding: const EdgeInsets.all(1),
            child: Container(
              color: Colors.white24,
              child: Text(''),
            ));
        break;

      default:
        return Text(state);
    }
  }
}
