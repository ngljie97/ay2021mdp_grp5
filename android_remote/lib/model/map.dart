import 'package:convert/convert.dart';

class ArenaMap {
  String _explorationStatus = List.generate(76, (index) => '0').toString();
  String _obstaclesData = List.generate(76, (index) => '0').toString();

  ArenaMap();

  void updateMap(String mapDescriptor1, String mapDescriptor2) {
    _explorationStatus = mapDescriptor1;
    _obstaclesData = mapDescriptor2;
  }

  int whatsAt(int index) {
    int x = (index / (15 * 4)).floor();
    int y = (index % (15 * 4));

    if (hex.decode(_explorationStatus[x]).elementAt(y) == 1) {
      return hex.decode(_explorationStatus[x]).elementAt(y) +
          hex.decode(_obstaclesData[x]).elementAt(y);
    } else
      return 0;
  }

  void updateExplored() {}

  void addObstaclesAt(int x, int y) {
    int index = ((x * 15) / 4).floor() + y;
  }
}
