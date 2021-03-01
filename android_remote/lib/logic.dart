import 'globals.dart' as globals;
import 'main.dart';
import 'model/arena.dart';

String cleanCommand(String command) {
  return command.replaceAllMapped(RegExp(r'[^a-zA-Z0-9_]+'), (match) {
    return '';
  }).trim().toUpperCase();
}

Future<bool> executeCommand(String command, [List<String> args]) async {
  command = cleanCommand(command);

  int x, y, dir;

  Arena arena = globals.arena;
  switch (command) {
    case globals.amdRobotPos:
      List<String> coord = args[0].split(',');
      x = (int.parse(cleanCommand(coord[1]).trim()) + 1 - 19).abs();
      y = int.parse(cleanCommand(coord[0]).trim()) + 1;
      dir = int.parse(cleanCommand(coord[2]).trim());
      continue setRobotPos;
    case globals.strRobotPos:
      x = int.parse(cleanCommand(args[0]).trim());
      y = int.parse(cleanCommand(args[1]).trim());
      dir = int.parse(cleanCommand(args[2]).trim());
      continue setRobotPos;
    setRobotPos:
    case 'setRobotPos':
      globals.robotStatus = 'IDLE';
      if (args.isNotEmpty) {
        arena.setRobotPos(x, y, dir);
      }
      break;

    case globals.strUpdateMap:
      if (args.isNotEmpty) {
        String mapDescriptor1 = cleanCommand(args[0]);
        String mapDescriptor2 = cleanCommand(args[1]);

        arena.updateMapFromDescriptors(false, mapDescriptor1, mapDescriptor2);
      }
      break;

    case globals.strAddObs:
      if (args.isNotEmpty) {
        List<String> coord = args[0].split(',');
        int x = int.parse(cleanCommand(coord[1]).trim());
        int y = int.parse(cleanCommand(coord[0]).trim());

        arena.setObstacle(x, y);
      }
      break;

    case globals.strRmObs:
      if (args.isNotEmpty) {
        List<String> coord = args[0].split(',');
        int x = int.parse(cleanCommand(coord[1]).trim());
        int y = int.parse(cleanCommand(coord[0]).trim());

        arena.removeObstacle(x, y);
      }
      break;

    case globals.amdUpdateObs:
      if (args.isNotEmpty) {
        String descriptor = cleanCommand(args[0]);

        arena.updateMapFromDescriptors(
            true, List.generate(38, (index) => 'F').toString(), descriptor);
      }
      break;

    case globals.strWayPoint:
    case globals.strSetWayPoint:
      if (args.isNotEmpty) {
        int x = int.parse(cleanCommand(args[0]).trim());
        int y = int.parse(cleanCommand(args[1]).trim());

        arena.setWayPoint(x, y);
      }
      break;

    case globals.strAddImage:
      int checker = int.parse(cleanCommand(args[0]).trim());
      if (checker > 0 && checker < 16) {
        int image = checker + 100;
        int x = int.parse(cleanCommand(args[1]).trim());
        int y = int.parse(cleanCommand(args[2]).trim());
        int dir = int.parse(cleanCommand(args[3]).trim());
        arena.setImage(x, y, image, dir);
      } else {
        streamController.add("Invalid id range. id = $checker");
      }

      break;

    case globals.strDelImage:
      int x = int.parse(cleanCommand(args[1]).trim());
      int y = int.parse(cleanCommand(args[2]).trim());
      arena.removeObstacle(x, y);
      break;

    case globals.strFinishedEx:
    case globals.strFinishedFP:
    case globals.strFinishedIR:
      globals.robotStatus = 'IDLE';
      streamController
          .add('Robot has finished executing the command: $command');
      break;
    default:
      streamController.add('Command not resolved. $command');
      return false;
  }
  return true;
}
