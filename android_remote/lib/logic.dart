import 'globals.dart' as globals;
import 'model/arena.dart';

bool executeCommand(String command, [List<String> args]) {
  Arena arena = globals.arena;
  switch (command) {
    case 'ROBOT_POS':
      if (args.isNotEmpty) {
        int x = args[0] as int;
        int y = args[1] as int;
        int dir = args[2] as int;

        arena.setRobotPos(x, y, dir);
      }
      break;
    case 'MAP':
      if (args.isNotEmpty) {
        String mapDescriptor1 = args[0];
        String mapDescriptor2 = args[2];

        arena.updateMapFromDescriptors(
            mapDescriptor1: mapDescriptor1, mapDescriptor2: mapDescriptor2);
      }
      break;
    case 'ADDOBSTACLE':
      if (args.isNotEmpty) {
        List<String> coord = args[0].split(',');
        int x = coord[0].trim() as int;
        int y = coord[1].trim() as int;

        arena.setObstacle(x, y);
      }
      break;
    case 'REMOVEOBSTACLE':
      if (args.isNotEmpty) {
        List<String> coord = args[0].split(',');
        int x = int.parse(coord[1].trim());
        int y = int.parse(coord[0].trim());

        arena.removeObstacle(x, y);
      }
      break;
    case 'grid':
      if (args.isNotEmpty) {
        String descriptor = args[0];

        arena.updateMapFromDescriptors(mapDescriptor2: descriptor);
      }
      break;
    default:
      break;
  }
}
