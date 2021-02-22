import 'globals.dart' as globals;
import 'model/arena.dart';

bool executeCommand(String command, [List<String> args]) {
  Arena arena = globals.arena;
  switch (command) {
    case 'ROBOT_POS':
    case 'ROBOTPOSITION':
    //forchecklist
      globals.robotStatus='IDLE';
      if (args.isNotEmpty) {
        List<String> coord = args[0].split(',');
        int x = int.parse(coord[1].trim())+1;
        int y = int.parse(coord[0].trim())+1;
        int dir = int.parse(coord[2].trim());
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
        int x = int.parse(coord[1].trim());
        int y = int.parse(coord[0].trim());

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
    case "{\"grid\" ":
      if (args.isNotEmpty) {
        String descriptor = args[0];

        arena.updateMapFromDescriptors(mapDescriptor2: descriptor);
      }
      break;
    default:
      break;
  }
}
