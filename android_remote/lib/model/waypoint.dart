class WayPoint {
  static int _x;
  static int _y;

  WayPoint(x, y) {
    _x = x;
    _y = y;
  }

  void update(int x, int y) {
    _x = x;
    _y = y;
  }

  static int isWayPoint(int x, int y) {
    if (_x + _y == -2) {
      return 0;
    } else {
      return ((_x == x) && (_y == y)) ? 3 : 0;
    }
  }
}
