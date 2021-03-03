import 'package:android_remote/globals.dart';

class DescriptorDecoder {
  static int x = 0, y = 0;
  static int bitCount = 0, hexCount = 0;
  static String hexCharacter = '';

  static List<String> decodeDescriptor1(bool isAMDTool, String descriptor) {
    if (descriptor.replaceAll('F', '').length == 0) {
      arena.explorationStatus = List.generate(
        20,
        (index) => List.generate(15, (index) => 1, growable: false),
        growable: false,
      );
      return null;
    } else {
      x = 0;
      y = 0;
      bitCount = 0;
      hexCount = 0;
      hexCharacter = '';
      List<String> _obstaclesCord = [];

      for (int i = 0; i <= 300; i++) {
        x = (i / 15).floor();
        y = (i % 15);

        if (isAMDTool && !debugMode) {
          x = 19 - x;
        }

        if (x == 0 && y == 0) {
          bitCount += 2;
        }

        int bit = readDescriptor(descriptor);

        if (bit == 1) {
          arena.explorationStatus[x][y] = 1;
          _obstaclesCord.add('$x,$y');
        }
      }
      return _obstaclesCord;
    }
  }

  static void decodeDescriptor2(
      bool isAMDTool, List<String> obstaclesCords, String descriptor) {
    x = 0;
    y = 0;
    bitCount = 0;
    hexCount = 0;
    hexCharacter = '';

    if (obstaclesCords == null) {
      for (int i = 0; i <= 300; i++) {
        x = (i / 15).floor();
        y = (i % 15);

        if (isAMDTool && !debugMode) {
          x = 19 - x;
        }

        arena.obstaclesRecords[x][y] = readDescriptor(descriptor);
      }
    } else {
      Iterator<String> obsItr = obstaclesCords.iterator;
      while (obsItr.moveNext()) {
        List<String> coord = obsItr.current.split(',');
        x = int.parse(coord[0]);
        y = int.parse(coord[1]);

        arena.obstaclesRecords[x][y] = readDescriptor(descriptor);
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
}
