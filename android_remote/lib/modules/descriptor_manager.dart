import 'package:android_remote/globals.dart';
import 'package:android_remote/main.dart';
class DescriptorDecoder {
  static const int GRID_COUNT = 300;
  static int x = 0, y = 0;
  static int bitCount = 0, hexCount = 0;
  static String hexCharacter = '';
  static String descriptorP1 = '';
  static String descriptorP2 = '';

  static List<String> decodeDescriptor1(bool isAMDTool, String descriptor) {
    descriptorP1 = descriptor;
    if (descriptor.replaceAll('F', '').length == 0) {
      arena.explorationStatus = List.generate(
        20, (index) => List.generate(15, (index) => 1, growable: false),
        growable: false,
      );
      return null;
    } else {
     clear();
      List<String> _obstaclesCord = [];

      for (int i = 0; i < GRID_COUNT; i++) {
        x = (i / 15).floor();
        y = (i % 15);

        if (isAMDTool && !debugMode) {
          x = 19 - x;
        }

        int bit = readDescriptor(descriptor);

        if (x == 0 && y == 0) {
          bitCount = 2;
          bit = readDescriptor(descriptor);
        }

        if (bit == 1) {
          arena.explorationStatus[x][y] = 1;
          _obstaclesCord.add('$x,$y');
        }
        unityWidgetController.postMessage(
          'Player_Isometric_Witch',
          'setExploration',
          '$x:$y:$bit',
        );
      }
      return _obstaclesCord;
    }
  }

  static void decodeDescriptor2(
      bool isAMDTool, List<String> obstaclesCords, String descriptor) {
    descriptorP2 = descriptor;
    clear();

    if (obstaclesCords == null) {
      for (int i = 0; i < GRID_COUNT; i++) {
        x = (i / 15).floor();
        y = (i % 15);

        // if (isAMDTool && !debugMode) {
        //   x = 19 - x;
        // }
        int obs = readDescriptor(descriptor);
        arena.obstaclesRecords[x][y] = obs;
        unityWidgetController.postMessage(
          'Player_Isometric_Witch',
          'setObstacles',
          '$x:$y:${obs*2}',
        );

      }
    } else {
      Iterator<String> obsItr = obstaclesCords.iterator;
      while (obsItr.moveNext()) {
        List<String> coord = obsItr.current.split(',');
        x = int.parse(coord[0]);
        y = int.parse(coord[1]);
        int obs = readDescriptor(descriptor);
        arena.obstaclesRecords[x][y] = obs;
        unityWidgetController.postMessage(
          'Player_Isometric_Witch',
          'setObstacles',
          '$x:$y:${obs*2}',
        );
      }
    }
  }

  static int readDescriptor(String descriptor) {
    if (bitCount % 4 == 0) {
      hexCharacter = int.parse(descriptor[hexCount], radix: 16)
          .toRadixString(2)
          .padLeft(4, '0');

      hexCount++;
      bitCount = 0;
    }

    return int.parse(hexCharacter[bitCount++]);
  }
  static void clear() {
    x = 0;
    y = 0;
    bitCount = 0;
    hexCount = 0;
    hexCharacter = '';
  }
}
