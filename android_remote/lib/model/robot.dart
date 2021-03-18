import 'package:android_remote/main.dart';

class Robot {
  int prevX;
  int x;
  int y;
  int prevY;
  int direction;

  Robot(this.x, this.y, this.prevX, this.prevY, this.direction);

  void moveForward() {
    int newPos = 0;
    prevX = x;
    prevY = y;

    switch (this.direction) {
      case 0:
        newPos = this.x + 1;
        if (newPos > 0 && newPos < 19) {
          this.x = newPos;
          continue unityPostCall;
        } else
          this.x = x;
        break;
      case 2:
        newPos = this.x - 1;
        if (newPos > 0 && newPos < 19) {
          this.x = newPos;
          continue unityPostCall;
        } else
          this.x = x;
        break;
      case 1:
        newPos = this.y + 1;
        if (newPos > 0 && newPos < 14) {
          this.y = newPos;
          continue unityPostCall;
        } else
          this.y = y;
        break;
      case 3:
        newPos = this.y - 1;
        if (newPos > 0 && newPos < 14) {
          this.y = newPos;
          continue unityPostCall;
        } else
          this.y = y;
        break;
      unityPostCall:
      case 99:
        unityWidgetController.postMessage(
          'Player_Isometric_Witch',
          'setUnityRobot',
          '$x:$y:$direction',
        );
        break;
    }
  }

  void rotate(int modifier) {
    this.direction = (this.direction + modifier) % 4;
    unityWidgetController.postMessage(
      'Player_Isometric_Witch',
      'setUnityRobot',
      '$x:$y:$direction',
    );
  }

  int isDisplaced() {
    return ((prevX - x) + (prevY - y));
  }
}
