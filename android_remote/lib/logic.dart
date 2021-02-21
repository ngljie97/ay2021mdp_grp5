import 'model/arena.dart';

bool executeCommand(Arena arena, String command, [List<String> args]) {
  switch (command) {
    case "ROBOT_POS":
      if (args.isNotEmpty) {
        int x = args[0] as int;
        int y = args[1] as int;
        int dir = args[2] as int;

        arena.setRobotPos(x, y, dir);
      }
      break;
    case "MAP":
      break;
    default:
      break;
  }
}
