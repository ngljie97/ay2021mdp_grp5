import 'dart:async';
import 'dart:ui';

import 'package:android_remote/modules/bluetooth_manager.dart';
import 'package:android_remote/pages/bluetooth_connection.dart';
import 'package:android_remote/pages/consoleBackupPage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sensors/sensors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'globals.dart' as globals;
import 'modules/arena.dart';
import 'router.dart';

StreamController<String> streamController =
    StreamController<String>.broadcast();
AccelerometerEvent acceleration;
StreamSubscription<AccelerometerEvent> _streamSubscription;
Timer _timer;

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
      onGenerateRoute: PageRouter.generateRoute,
      initialRoute: homeRoute,
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
  static Arena _arena;
  bool _setWaypoint = false;

  void mySetState(String message) {
    addConsoleAndScroll(message);
    if (message.contains('Disconnected remotely!')) {
      _arena.resetRobotPos();
    }
  }

  void addConsoleAndScroll(String message) {
    setState(() {
      globals.strArr.add(message);
      globals.BackupstrArr.add(
          DateFormat(globals.Datetimeformat).format(DateTime.now()) +
              " | " +
              message);
      consoleController.scrollTo(
          index: globals.strArr.length,
          duration: Duration(milliseconds: 333),
          curve: Curves.easeInOutCubic);
    });
  }

  @override
  void initState() {
    consoleController = ItemScrollController();
    super.initState();

    _streamSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        acceleration = event;
      });
    });

    widget.stream.listen((message) {
      mySetState(message);
    });
    _arena = Arena();
    // _arena.displayRobot();
    if (globals.btController == null)
      globals.btController = BluetoothController();
    globals.btController.init();
  }

  Future<void> moveControls(String commandString, String globalString) async {
    //commandString = 'FW','RR'
    //globalString = globals.strForward
    if (globals.debugMode) {
      _arena.moveRobot(commandString);
    } else if (globals.btController.isConnected && !globals.debugMode) {
      if (_arena.moveRobot(commandString)) {
        await globals.btController.sendMessage(globalString);
      }
    }
    if (!globals.updateMode)
      setState(() {
        //_arena.setRobotPos();
      });
  }

  void _motionControl() {
    if (globals.gyroMode) {
      final AccelerometerEvent currentAcceleration = acceleration;
      if (currentAcceleration.x.truncateToDouble() < -2) {
        setState(() {
          //rotate right
          moveControls('RR', globals.strRotateRight);
        });
      } else if (currentAcceleration.x.truncateToDouble() > 2) {
        //rotate left
        moveControls('RL', globals.strRotateLeft);
      } else if (currentAcceleration.y.truncateToDouble() < -2) {
        //move forward
        moveControls('FW', globals.strForward);
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
                _buildArena(),
                _buildBottomPanel(),
              ],
            ),
            Container(
              child: Positioned(
                //Place it at the top, and not use the entire screen
                top: 5.0,
                left: 0.0,
                right: 0.0,
                child: AppBar(
                  title: Text(''),
                  backgroundColor: Colors.transparent, //No more green
                  elevation: 0.0,
                  iconTheme: IconThemeData(color: Colors.white),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(
                  MediaQuery.of(context).size.width - 110, 50, 0, 0),
              child: Icon(
                Icons.adb_outlined,
                color: (globals.robotStatus == 0) ? Colors.red : Colors.green,
                size: 30.0,
              ),
            ),
            Container(
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
            Container(
              padding: EdgeInsets.fromLTRB(
                  MediaQuery.of(context).size.width - 175, 43, 0, 0),
              child: IconButton(
                  icon: Icon(
                    Icons.refresh,
                    size: 30.0,
                  ),
                  onPressed: () {
                    setState(() {});
                  }),
            ),
            Center(
              child: Container(
                child: Align(
                  alignment: Alignment(1, 0),
                  child: IconButton(
                    icon: Icon(Icons.stay_current_landscape),
                    color: (globals.gyroMode) ? Colors.greenAccent : Colors.red,
                    onPressed: () {
                      setState(() {
                        if (globals.btController.isConnected ||
                            globals.debugMode) {
                          if (globals.gyroMode) {
                            globals.gyroMode = false;
                            addConsoleAndScroll("Motion Control Disabled.");
                            _timer.cancel();
                          } else {
                            globals.gyroMode = true;
                            addConsoleAndScroll("Motion Control Enabled.");
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
            Center(
              child: Container(
                child: Align(
                  alignment: Alignment(1, 0.1),
                  child: IconButton(
                    icon: Icon(Icons.cached),
                    onPressed: () {
                      addConsoleAndScroll('Resetted robot to start position');
                      setState(() {
                        _arena.resetRobotPos();
                      });
                    },
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
                        child: Text('Remote Controller Module',
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
                    addConsoleAndScroll('Disconnected locally!');
                    _arena.resetRobotPos();
                  }
                  if (!globals.btController.isConnected) {
                    streamController.close();
                  }
                  globals.btController.selectedDevice =
                      await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return ConnectionPage(checkAvailability: false);
                      },
                    ),
                  );
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
                leading: Icon(Icons.info_outline),
                title: Text('About'),
                onTap: () {
                  Navigator.popAndPushNamed(context, aboutRoute);
                },
              ),
            ],
          ),
        ),
      ),
    );
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
    x = (index / 15).floor();
    y = (index % 15);

    void onTapFunction() {
      if (_setWaypoint) {
        _setWaypoint = false;

        _arena.setWayPoint(x, y);
      }
    }

    return _arena.getArenaState(x, y, onTapFunction);
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
                  Text(
                    'Console output:',
                    textAlign: TextAlign.left,
                  ),
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
                                color: Colors.blue[400],
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: IconButton(
                                    icon: Icon(Icons.arrow_circle_up),
                                    onPressed: () async {
                                      if (globals.debugMode) {
                                        _arena.moveRobot('FW');
                                      } else if (globals
                                              .btController.isConnected &&
                                          !globals.debugMode) {
                                        if (_arena.moveRobot('FW')) {
                                          await globals.btController
                                              .sendMessage(globals.strForward);
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: IconButton(
                                    icon: Icon(Icons.rotate_left),
                                    tooltip: 'Rotate Left',
                                    onPressed: () {
                                      if (globals.debugMode) {
                                        _arena.moveRobot('RL');
                                      } else if (globals
                                              .btController.isConnected &&
                                          !globals.debugMode) {
                                        if (_arena.moveRobot('RL'))
                                          globals.btController.sendMessage(
                                              globals.strRotateLeft);
                                      }
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
                                      if (globals.debugMode) {
                                        _arena.moveRobot('RR');
                                      } else if (globals
                                              .btController.isConnected &&
                                          !globals.debugMode) {
                                        if (_arena.moveRobot('RR'))
                                          globals.btController.sendMessage(
                                              globals.strRotateRight);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: RaisedButton(
                          color: Colors.indigo[200],
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
                        flex: 2,
                        child: RaisedButton(
                          color: Colors.indigo[800],
                          onPressed: () {
                            if (globals.btController.isConnected) {
                              globals.btController
                                  .sendMessage(globals.strStartExplore);
                              globals.robotStatus = 1;
                            }
                          },
                          child: Container(
                            child: const Text(
                              'Start Exploration',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: RaisedButton(
                          color: Colors.indigo[700],
                          onPressed: () {
                            if (globals.btController.isConnected) {
                              globals.btController
                                  .sendMessage(globals.strFastestPath);
                              globals.robotStatus = 1;
                            }
                          },
                          child: Container(
                            child: const Text(
                              'Run Fastest Path',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: RaisedButton(
                          color:
                              (_setWaypoint) ? Colors.grey : Colors.indigo[600],
                          onPressed: () {
                            _setWaypoint = true;
                          },
                          child: Container(
                            child: const Text(
                              'Set Waypoint',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: RaisedButton(
                          color: Colors.indigo[200],
                          onPressed: () {
                            setState(() {
                              globals.controlMode = true;
                            });
                          },
                          child: Container(
                            child: const Text(
                              'Show controls',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
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
    final value = prefs.getString('function$i') ?? 0;

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
