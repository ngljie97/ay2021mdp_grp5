import 'globals.dart' as globals;
import 'main.dart';
import 'model/arena.dart';
import 'modules/descriptor_manager.dart';

String cleanCommand(String command) {
  return command
      .replaceAllMapped(RegExp(r'[^a-zA-Z0-9_]+'), (match) {
        return '';
      })
      .trim()
      .toUpperCase()
      .replaceAll('\N', '');
}

Future<bool> executeCommand(String command, [List<String> args]) async {
  command = cleanCommand(command);

  int x, y, dir;

  Arena arena = globals.arena;
  switch (command) {
    case globals.amdRobotPos:
      List<String> coord = args[0].split(',');
      x = (int.parse(cleanCommand(coord[1].trim())) + 1 - 19).abs();
      y = int.parse(cleanCommand(coord[0].trim())) + 1;
      dir = int.parse(cleanCommand(coord[2].trim()));
      continue setRobotPos;
    case globals.strRobotPos:
      x = int.parse(cleanCommand(args[0].trim()));
      y = int.parse(cleanCommand(args[1].trim()));
      dir = int.parse(cleanCommand(args[2].trim()));
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
        String mapDescriptor1 = cleanCommand(args[0].trim());
        String mapDescriptor2 = cleanCommand(args[1].trim());

        arena.updateMapFromDescriptors(false, mapDescriptor1, mapDescriptor2);
      }
      break;

    case globals.strAddObs:
      if (args.isNotEmpty) {
        List<String> coord = args[0].split(',');
        int x = int.parse(cleanCommand(coord[1].trim()));
        int y = int.parse(cleanCommand(coord[0].trim()));

        arena.setObstacle(x, y);
      }
      break;

    case globals.strRmObs:
      if (args.isNotEmpty) {
        List<String> coord = args[0].split(',');
        int x = int.parse(cleanCommand(coord[1].trim()));
        int y = int.parse(cleanCommand(coord[0].trim()));

        arena.removeObstacle(x, y);
      }
      break;

    case globals.amdUpdateObs:
      if (args.isNotEmpty) {
        String descriptor = cleanCommand(args[0].trim());

        arena.updateMapFromDescriptors(
            true, List.generate(76, (index) => 'F').join(), descriptor);
      }
      break;

    case globals.strWayPoint:
    case globals.strSetWayPoint:
      if (args.isNotEmpty) {
        int x = int.parse(cleanCommand(args[0].trim()));
        int y = int.parse(cleanCommand(args[1].trim()));

        arena.setWayPoint(x, y, false);
      }
      break;

    case globals.strAddImage:
      int id = int.parse(cleanCommand(args[0].trim()));
      if (id > 0 && id < 16) {
        int x = int.parse(cleanCommand(args[1].trim()));
        int y = int.parse(cleanCommand(args[2].trim()));
        int dir = int.parse(cleanCommand(args[3].trim()));
        arena.setImage(x, y, id, dir);
      } else {
        streamController.add("Invalid id range. id = $id");
      }

      break;

    case globals.strDelImage:
      int id = int.parse(cleanCommand(args[0].trim()));
      int x = int.parse(cleanCommand(args[1].trim()));
      int y = int.parse(cleanCommand(args[2].trim()));
      arena.rmvImage(x, y, id, dir);
      //arena.removeObstacle(x, y);
      break;

    case globals.strFinishedAlgo:
      globals.robotStatus = 'IDLE';
      streamController
          .add('Robot has finished executing the previous command.');
      streamController.add(
          'Map descriptors\n==========================\nP1:\n${DescriptorDecoder.descriptorP1}\nP2:\n${DescriptorDecoder.descriptorP2}\n');
      String res = arena.getImageStrings();
      if (res != '') {
        streamController.add('Images found:');
        streamController.add(res);
      }
      break;
    default:
      streamController.add('Command not resolved. $command');
      return false;
  }
  return true;
}
