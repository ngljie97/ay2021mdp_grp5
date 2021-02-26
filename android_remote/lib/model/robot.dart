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
        this.x = (newPos > 0 && newPos < 19) ? newPos : x;
        break;
      case 2:
        newPos = this.x - 1;
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
