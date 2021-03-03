import 'dart:async';
import 'dart:ui';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:android_remote/modules/bluetooth_manager.dart';
import 'package:android_remote/pages/about.dart';
import 'package:android_remote/pages/bluetooth_connection.dart';
import 'package:android_remote/pages/consoleBackupPage.dart';
import 'package:android_remote/pages/unity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sensors/sensors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart' as globals;
import 'model/arena.dart';
import 'model/queueSystem.dart';

StreamController<String> streamController =
    StreamController<String>.broadcast();
AccelerometerEvent acceleration;
StreamSubscription<AccelerometerEvent> _streamSubscription;
Timer _timer;
UnityWidgetController unityWidgetController;
double _sliderValue = 0.0;
void main() {
  runApp(MyApp());
}

ItemScrollController consoleController;

final TextEditingController textEditingController = new TextEditingController();

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Remote Controller Module',
      theme: ThemeData(
        brightness: Brightness.dark,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(streamController.stream),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage(this.stream);

  final Stream<String> stream;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _setWayPoint = false;
  bool _setRobotStart = false;

  Future<void> mySetState(String message) async {
    await addConsoleAndScroll(message);
    if (message.contains('Disconnected remotely!')) {
      globals.backupArena = globals.arena;
      globals.arena = Arena('1110');
    }
  }

  void addConsoleAndScroll(String message) async {
    globals.strArr.add(message);
    globals.BackupstrArr.add(
        DateFormat(globals.Datetimeformat).format(DateTime.now()) +
            " | " +
            message);
    if (globals.strArr.length > 7 && !globals.updateMode)
      consoleController.jumpTo(index: globals.strArr.length - 7);
    consoleController.scrollTo(
        index: globals.strArr.length,
        duration: Duration(milliseconds: 1000),
        curve: Curves.easeInOutCubic);

    if (!globals.updateMode) setState(() {});
  }

  @override
  void initState() {
    consoleController = ItemScrollController();
    super.initState();
    QueueSys(); // starts timer.

    widget.stream.listen((message) {
      mySetState(message);
    });

    globals.arena = Arena('1111');

    if (globals.btController == null)
      globals.btController = BluetoothController();
    globals.btController.init();
  }

  Future<void> moveControls(String commandString) async {
    String globalString = '';
    switch (commandString) {
      case 'FW':
        globalString = globals.strForward;
        break;
      case 'RR':
        globalString = globals.strRotateRight;
        break;
      case 'RL':
        globalString = globals.strRotateLeft;
        break;
    }

    if (globals.debugMode) {
      globals.arena.moveRobot(commandString);
    } else if (globals.btController.isConnected && !globals.debugMode) {
      if (globals.arena.moveRobot(commandString)) {
        await globals.btController.sendMessage(globalString);
      }
    }
    if (!globals.updateMode) setState(() {});
  }

  void _motionControl() {
    //
    if (globals.gyroMode) {
      final AccelerometerEvent currentAcceleration = acceleration;
      if (currentAcceleration.x.truncateToDouble() < -2) {
        setState(() {
          //rotate right
          if (globals.arena.getRobotDir() == 1)
            moveControls('FW');
          else if (globals.arena.getRobotDir() == 2)
            moveControls('RL');
          else
            moveControls('RR');
        });
      } else if (currentAcceleration.x.truncateToDouble() > 2) {
        //rotate left
        if (globals.arena.getRobotDir() == 3)
          moveControls('FW');
        else if (globals.arena.getRobotDir() == 2)
          moveControls('RR');
        else
          moveControls('RL');
      } else if (currentAcceleration.y.truncateToDouble() < -2) {
        //move forward
        if (globals.arena.getRobotDir() == 0)
          moveControls('FW');
        else if (globals.arena.getRobotDir() == 3) {
          moveControls('RR');
        } else {
          moveControls('RL');
        }
      } else if (currentAcceleration.y.truncateToDouble() > 2) {
        //move forward
        //TILT bottom
        if (globals.arena.getRobotDir() == 2)
          moveControls('FW');
        else if (globals.arena.getRobotDir() == 1) {
          moveControls('RR');
        } else
          moveControls('RL');
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscription.cancel();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: _onWillPop,
      child: new Scaffold(
        body: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                _buildchecker(),
                _buildBottomPanel(),
              ],
            ),
            Visibility(
              visible: !_setWayPoint && !_setRobotStart,
              child: Container(
                child: Positioned(
                  //Place it at the top, and not use the entire screen
                  top: 12.0,
                  left: 0.0,
                  right: 0.0,
                  child: AppBar(
                    title: Text(''),
                    backgroundColor: Colors.transparent, //No more green
                    elevation: 0.0,
                    iconTheme: IconThemeData(color: Colors.blueAccent),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: !_setWayPoint && !_setRobotStart,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                    MediaQuery.of(context).size.width - 55, 50, 0, 0),
                child: Icon(
                  Icons.bluetooth,
                  color: (globals.btController.isConnected)
                      ? Colors.greenAccent
                      : Colors.red,
                  size: 30.0,
                ),
              ),
            ),
            Visibility(
              visible: !_setWayPoint && !_setRobotStart,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                    MediaQuery.of(context).size.width - 115, 43, 0, 0),
                child: IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: Colors.blueAccent,
                      size: 30.0,
                    ),
                    tooltip: 'Sync',
                    onPressed: () {
                      setState(() {
                        if (!globals.debugMode &&
                            globals.btController.isConnected)
                          globals.btController
                              .sendMessage(globals.strRefreshArena);
                      });
                    }),
              ),
            ),
            Visibility(
              visible: !_setWayPoint && !_setRobotStart,
              child: Center(
                child: Container(
                  child: Align(
                    alignment: Alignment(1, 0),
                    child: IconButton(
                      icon: Icon(Icons.stay_current_landscape),
                      color:
                          (globals.gyroMode) ? Colors.greenAccent : Colors.red,
                      tooltip: 'Motion Control',
                      onPressed: () {
                        setState(() {
                          if (globals.btController.isConnected ||
                              globals.debugMode) {
                            if (globals.gyroMode) {
                              globals.gyroMode = false;
                              addConsoleAndScroll("Motion Control Disabled.");
                              _streamSubscription.cancel();
                              _timer.cancel();
                            } else {
                              globals.gyroMode = true;
                              addConsoleAndScroll("Motion Control Enabled.");
                              _streamSubscription = accelerometerEvents
                                  .listen((AccelerometerEvent event) {
                                setState(() {
                                  acceleration = event;
                                });
                              });
                              _timer = Timer.periodic(
                                  const Duration(milliseconds: 800), (_) {
                                setState(() {
                                  _motionControl();
                                });
                              });
                            }
                          } else {
                            addConsoleAndScroll(
                                "Device need to be connected or in debug mode!");
                          }
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: !_setWayPoint && !_setRobotStart,
              child: Center(
                child: Container(
                  child: Align(
                    alignment: Alignment(1, 0.07),
                    child: IconButton(
                      icon: Icon(Icons.cached),
                      tooltip: 'Reset Robot',
                      color: Colors.blueAccent,
                      onPressed: () {
                        setState(() {
                          globals.arena.resetRobotPos();
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: !_setWayPoint && !_setRobotStart,
              child: Center(
                child: Container(
                  child: Align(
                    alignment: Alignment(1, 0.15),
                    child: IconButton(
                      icon: Icon(Icons.view_in_ar),
                      tooltip: 'Reset Robot',
                      color: Colors.blueAccent,
                      onPressed: () {
                        setState(() {
                          if (globals.arena2d)
                            globals.arena2d = false;
                          else
                            globals.arena2d = true;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                margin: EdgeInsets.zero,
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(color: Colors.black45),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                        bottom: 12.0,
                        left: 16.0,
                        child: Text('Remote Controller\nModule',
                            style: TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.w500))),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.bluetooth),
                title: Text((globals.btController.isConnected)
                    ? 'Disconnect'
                    : 'Connect'),
                onTap: () async {
                  if (globals.btController.isConnected) {
                    addConsoleAndScroll('Disconnecting locally!');
                    globals.btController.disconnect();
                    globals.btController.isReconnecting = false;
                    addConsoleAndScroll('Disconnected locally!');
                    globals.backupArena = globals.arena;
                    globals.arena = Arena('1110');
                  } else {
                    streamController.close();
                    globals.btController.selectedDevice =
                        await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return ConnectionPage(checkAvailability: false);
                        },
                      ),
                    );
                  }
                  setState(() {}());
                },
              ),
              Divider(),
              ListTile(
                title: Text('Edit persistent strings'),
              ),
              ListTile(
                leading: Icon(Icons.border_color),
                title: Text('Function 1'),
                onTap: () => _showEditForm(context, 1),
              ),
              ListTile(
                leading: Icon(Icons.border_color),
                title: Text('Function 2'),
                onTap: () => _showEditForm(context, 2),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.update_outlined),
                title: Text('Update Mode'),
                subtitle: Text(() {
                  if (!globals.updateMode) {
                    return 'Auto';
                  } else {
                    return 'Manual';
                  }
                }()),
                trailing: Switch(
                  value: globals.updateMode,
                  onChanged: (value) {
                    setState(() {
                      globals.updateMode = value;
                    });
                  },
                ),
              ),
              ListTile(
                leading: Icon(Icons.android_sharp),
                title: Text('Debug Mode'),
                subtitle: Text(() {
                  if (!globals.debugMode) {
                    return 'Off';
                  } else {
                    return 'On';
                  }
                }()),
                trailing: Switch(
                  value: globals.debugMode,
                  onChanged: (value) {
                    setState(() {
                      globals.debugMode = value;
                    });
                  },
                ),
              ),
              ListTile(
                leading: Icon(Icons.cleaning_services),
                title: Text('Clear state'),
                onTap: () {
                  globals.backupArena = globals.arena;
                  setState(() => globals.arena = new Arena('1110'));
                },
              ),
              ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('About'),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return AboutPage();
                    },
                  ));
                },
              ),
              ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Unity test'),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onUnityCreated(controller) {
    unityWidgetController = controller;
  }

  void onUnityMessage(message) {
    print('Received message from unity: ${message.toString()}');
  }

  void setRotationSpeed(String speed) {
    unityWidgetController.postMessage(
      'Cube',
      'SetRotationSpeed',
      speed,
    );
  }

  void unityMove(String xyz) {
    unityWidgetController.postMessage(
      'Player_Isometric_Witch',
      'moveWitch',
      xyz,
    );
  }

  void setUnityObstacle(String xyz) {
    //xyz = x:y
    unityWidgetController.postMessage(
      'Player_Isometric_Witch',
      'setObstacles',
      xyz,
    );
  }

  Widget _buildchecker() {
    if (globals.arena2d) {
      return _buildArena();
    } else {
      return _buildUnity();
    }
  }

  Widget _buildUnity() {
    return new Expanded(
        flex: 10,
        child: Scaffold(
          body: Card(
            margin: const EdgeInsets.all(8),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Stack(
              children: <Widget>[
                UnityWidget(
                  onUnityCreated: onUnityCreated,
                  isARScene: false,
                  fullscreen: false,
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Card(
                    elevation: 10,
                    child: Column(
                      children: <Widget>[
                        // Padding(
                        //   padding: const EdgeInsets.only(top: 20),
                        //   child: Text("Rotation speed:"),
                        // ),
                        // Slider(
                        //   onChanged: (value) {
                        //     setState(() {
                        //       _sliderValue = value;
                        //     });
                        //     setRotationSpeed(value.toString());
                        //   },
                        //   value: _sliderValue,
                        //   min: 0,
                        //   max: 20,
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildArena() {
    return new Expanded(
      flex: 10,
      child: AspectRatio(
        aspectRatio: MediaQuery.of(context).devicePixelRatio /
            (MediaQuery.of(context).devicePixelRatio +
                (MediaQuery.of(context).devicePixelRatio *
                    (MediaQuery.of(context).size.aspectRatio / 4))),
        child: Center(
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 15,
                  childAspectRatio: MediaQuery.of(context).size.width /
                      (MediaQuery.of(context).size.height / 1.8),
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                ),
                shrinkWrap: true,
                itemCount: 15 * 20,
                itemBuilder: (BuildContext context, int index) {
                  return _resolveGridItem(context, index);
                }),
          ),
        ),
      ),
    );
  }

  Widget _resolveGridItem(BuildContext context, int index) {
    int x, y = 0;
    x = 19 - (index / 15).floor();
    y = (index % 15);

    void onTapFunction() {
      if (_setWayPoint) {
        _setWayPoint = false;
        _setRobotStart = false;

        if (globals.arena.setWayPoint(x, y)) {
          addConsoleAndScroll('WayPoint set at [$x,$y].');
          globals.btController.sendMessage('${globals.strWayPoint}:$x:$y');
        } else {
          addConsoleAndScroll('WayPoint[$x,$y] removed.');
          globals.btController
              .sendMessage('${globals.strRemoveWayPoint}:$x:$y');
        }
      }

      if (_setRobotStart) {
        globals.backupArena = globals.arena;
        globals.arena = Arena('1000');
        _setWayPoint = false;
        _setRobotStart = false;
        if (globals.arena.setRobotPos(x, y, 0)) {
          addConsoleAndScroll('Robot position set.');
          globals.btController.sendMessage('ROBOT:$x:$y');
        } else {
          addConsoleAndScroll('Robot cannot be place at the edge of arena!');
        }
      }
    }

    return globals.arena.getArenaState(x, y, onTapFunction);
  }

  Widget _buildBottomPanel() {
    return Expanded(
      flex: 3,
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 6,
            child: Container(
              padding: EdgeInsets.fromLTRB(3, 1, 3, 1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        RichText(
                          text: TextSpan(text: 'Console output:'),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Robot Status',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: (globals.btController.isConnected)
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              TextSpan(text: ': ${globals.robotStatus}'),
                            ],
                          ),
                        ),
                      ]),
                  Expanded(
                    child: Flex(
                      direction: Axis.horizontal,
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(3, 1, 3, 1),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                            ),
                            child: Stack(children: [
                              new ScrollablePositionedList.builder(
                                itemScrollController: consoleController,
                                itemCount: globals.strArr.length,
                                itemBuilder: (context, index) {
                                  return new Padding(
                                      padding: EdgeInsets.fromLTRB(5, 10, 0, 0),
                                      child: Text(globals.strArr[index]));
                                },
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  tooltip: 'Clear console log.',
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      globals.strArr = ["Console log cleared."];
                                      globals.BackupstrArr.add(
                                          DateFormat(globals.Datetimeformat)
                                                  .format(DateTime.now()) +
                                              " | " +
                                              "Console log cleared.");
                                    });
                                  },
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: IconButton(
                                  tooltip: 'View console log.',
                                  icon: Icon(Icons.bookmarks),
                                  onPressed: () {
                                    Navigator.of(context).push(PageRouteBuilder(
                                      opaque: false,
                                      pageBuilder:
                                          (BuildContext context, _, __) {
                                        return ConsoleBackupPage();
                                      },
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        var begin = Offset(0.0, 1.0);
                                        var end = Offset.zero;
                                        var curve = Curves.ease;

                                        var tween = Tween(
                                                begin: begin, end: end)
                                            .chain(CurveTween(curve: curve));

                                        return SlideTransition(
                                          position: animation.drive(tween),
                                          child: child,
                                        );
                                      },
                                      transitionDuration:
                                          Duration(milliseconds: 500),
                                    ));
                                  },
                                ),
                              ),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          () {
            if (globals.controlMode) {
              return Expanded(
                flex: 4,
                child: Container(
                  padding: EdgeInsets.fromLTRB(7.5, 0, 7.5, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              flex: 1,
                              child: RaisedButton(
                                color: Colors.indigo,
                                onPressed: () async {
                                  if (globals.btController.isConnected) {
                                    await globals.btController.sendMessage(
                                        await _getFunctionString(1));
                                  }
                                },
                                child: Container(
                                  child: const Text(
                                    'F1',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: RaisedButton(
                                color: Colors.indigo[400],
                                onPressed: () async {
                                  if (globals.btController.isConnected) {
                                    await globals.btController.sendMessage(
                                        await _getFunctionString(2));
                                  }
                                },
                                child: Container(
                                  child: const Text(
                                    'F2',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Column(
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: IconButton(
                                      icon: Icon(Icons.arrow_circle_up),
                                      tooltip: 'Move Forward',
                                      onPressed: () async {
                                        moveControls('FW');
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: IconButton(
                                      icon: Icon(Icons.rotate_left),
                                      tooltip: 'Rotate Left',
                                      onPressed: () {
                                        moveControls('RL');
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: Icon(Icons.circle),
                                  ),
                                  Expanded(
                                    child: IconButton(
                                      tooltip: 'Rotate Right',
                                      icon: Icon(Icons.rotate_right),
                                      onPressed: () {
                                        moveControls('RR');
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: RaisedButton(
                          color: Colors.indigo[300],
                          onPressed: () {
                            setState(() {
                              globals.controlMode = false;
                            });
                          },
                          child: Container(
                            child: const Text(
                              'Hide controls',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            } else {
              return Expanded(
                flex: 4,
                child: Container(
                  padding: EdgeInsets.fromLTRB(7.5, 0, 7.5, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Container(
                                color: Colors.indigo[800],
                                child: IconButton(
                                  onPressed: () {
                                    if (globals.btController.isConnected) {
                                      globals.btController
                                          .sendMessage(globals.strStartExplore);
                                      setState(() {
                                        globals.robotStatus = 'EXPLORING';
                                      });
                                    }
                                  },
                                  icon: Icon(Icons.explore),
                                  tooltip: 'Start Exploration',
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                color: Colors.indigo[700],
                                child: IconButton(
                                  onPressed: () {
                                    if (globals.btController.isConnected) {
                                      globals.btController
                                          .sendMessage(globals.strFastestPath);
                                      setState(() {
                                        globals.robotStatus = 'RUNNING';
                                      });
                                    }
                                  },
                                  icon: Icon(Icons.directions_run),
                                  tooltip: 'Start Fastest Path',
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                color: Colors.indigo[600],
                                child: IconButton(
                                  onPressed: () {
                                    if (globals.btController.isConnected) {
                                      globals.btController
                                          .sendMessage(globals.strImgFind);
                                      setState(() {
                                        globals.robotStatus = 'SCANNING';
                                      });
                                    }
                                  },
                                  icon: Icon(Icons.camera_alt),
                                  tooltip: 'Start Image Recognition',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Container(
                                color: (_setWayPoint)
                                    ? Colors.grey
                                    : Colors.indigo[600],
                                child: IconButton(
                                  onPressed: () {
                                    if (_setWayPoint) {
                                      _setWayPoint = false;
                                      _setRobotStart = false;
                                      addConsoleAndScroll(
                                          'Stop setting WayPoint.');
                                    } else {
                                      _setWayPoint = true;
                                      _setRobotStart = false;
                                      addConsoleAndScroll(
                                          'Tap on the map to set WayPoint.');
                                    }
                                  },
                                  icon: Icon(Icons.pin_drop),
                                  tooltip: 'Set WayPoint',
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                color: (_setRobotStart)
                                    ? Colors.grey
                                    : Colors.indigo,
                                child: IconButton(
                                  icon: Icon(Icons.android),
                                  onPressed: () {
                                    if (_setRobotStart) {
                                      _setRobotStart = false;
                                      _setWayPoint = false;
                                      addConsoleAndScroll(
                                          'Stop setting position.');
                                    } else {
                                      _setRobotStart = true;
                                      _setWayPoint = false;
                                      addConsoleAndScroll(
                                          'Tap on the map to set start position for robot.');
                                    }
                                  },
                                  tooltip: 'Set robot start position',
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 1,
                              child: RaisedButton(
                                color: Colors.indigo[300],
                                onPressed: () {
                                  setState(() {
                                    globals.controlMode = true;
                                  });
                                },
                                child: Container(
                                  child: const Text(
                                    'Show controls 🎮',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          }(),
        ],
      ),
    );
  }

  Future<String> _getFunctionString(int i) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('function$i') ?? '0';

    return value;
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit an App'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: new Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  void _showEditForm(BuildContext context, int i) async {
    final prefs = await SharedPreferences.getInstance();
    final _formKey = GlobalKey<FormState>();
    final myController = TextEditingController();

    String key = '';

    switch (i) {
      case 1:
        key = 'function1';
        break;
      case 2:
        key = 'function2';
        break;
    }

    final value = prefs.getString(key) ?? 0;

    _save(int num, String functionStr) async {
      String key = '';

      switch (num) {
        case 1:
          key = 'function1';
          break;
        case 2:
          key = 'function2';
          break;
      }

      if (key.length > 0) prefs.setString(key, functionStr);
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Stack(
              overflow: Overflow.visible,
              children: <Widget>[
                Positioned(
                  right: -40.0,
                  top: -40.0,
                  child: InkResponse(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: CircleAvatar(
                      child: Icon(Icons.close),
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Edit function $i'),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: myController,
                          decoration: InputDecoration(
                            hintText: '$value',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton(
                          child: Text('Save'),
                          onPressed: () {
                            _save(i, myController.text);
                            Navigator.of(context).pop();
                          },
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }
}
