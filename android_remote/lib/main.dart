import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:android_remote/pages/bluetooth_connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'globals.dart' as globals;
import 'modules/arena.dart';
import 'router.dart';

void main() {
  runApp(MyApp());
}

ItemScrollController consoleController;

final TextEditingController textEditingController = new TextEditingController();

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
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  final BluetoothDevice server;

  const MyHomePage({this.server});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);

  String getText() {
    return this.text;
  }
}

class _MyHomePageState extends State<MyHomePage> {
  static final clientID = 0;

  Arena _arena = Arena();
  List<_Message> messages = List<_Message>();
  String _messageBuffer = '';

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (globals.isConnected) {
      globals.isDisconnecting = true;
      globals.connection.dispose();
      globals.connection = null;
    }

    super.dispose();
  }

  @override
  void initState() {
    consoleController = ItemScrollController();
    super.initState();
    _arena.setRobotPos();

    print("Checking is connected...");
    print(globals.isConnected);

    if (globals.isConnecting) {
      BluetoothConnection.toAddress(widget.server.address).then((_connection) {
        addConsoleAndScroll('Successfully connected to ' + widget.server.name);
        globals.bluetoothStatus = Colors.greenAccent;
        globals.isConnected = true;
        print('Connected to the device');
        globals.connection = _connection;
        setState(() {
          globals.isConnecting = false;
          globals.isDisconnecting = false;
        });

        globals.connection.input.listen(_onDataReceived).onDone(() {
          if (globals.isDisconnecting) {
            print('Disconnecting locally!');
            addConsoleAndScroll('Disconnecting locally!');
            globals.bluetoothStatus = Colors.red;
            globals.connection.dispose();
          } else {
            print('Disconnected remotely!');
            addConsoleAndScroll('Disconnecting remotely!');
            globals.bluetoothStatus = Colors.red;
            globals.connection.dispose();
          }
          if (this.mounted) {
            setState(() {});
          }
        });
      }).catchError((error) {
        print('Cannot connect, exception occurred');

        setState(() {
          addConsoleAndScroll('Cannot connect, Socket not opened!');
        });
        print(error);
      });
    }
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
        padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width - 110, 50, 0, 0),
        child:Icon(
                Icons.adb_outlined,
                color: globals.robotStatus,
                size: 30.0,
              ),
            ),
      Container(
        padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width - 55, 50, 0, 0),

              child: Icon(
                Icons.bluetooth,
                color: globals.bluetoothStatus,
                size: 30.0,
              ),
            ),
      Container(
        padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width - 175, 43, 0, 0),
        child:
            IconButton(
                  icon: Icon(
                    Icons.refresh,
                    size: 30.0,
                  ),
                  onPressed: () {
                    setState(() => _arena.setRobotPos());
                  }),
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
                title: Text('Connect / Disconnect'),
                onTap: () async {
                  if (globals.isConnected) {
                    try {
                      globals.isDisconnecting = true;
                      globals.isConnecting = false;
                      _sendMessage("quitting");
                      globals.connection.dispose();
                      globals.connection = null;
                      globals.isConnected = false;
                    } catch (e) {
                      globals.isDisconnecting = true;
                      globals.isConnecting = false;
                      if (globals.connection != null) {
                        _sendMessage("quitting");
                        globals.connection.dispose();
                        globals.connection = null;
                      }
                    }
                  }
                  globals.selectedDevice = await Navigator.of(context).push(
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

    return _arena.getArenaState(x, y);
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
                            child: new ScrollablePositionedList.builder(
                              itemScrollController: consoleController,
                              itemCount: globals.strArr.length,
                              itemBuilder: (context, index) {
                                return new Text(globals.strArr[index]);
                              },
                            ),
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
                                onPressed: () async {
                                  if (globals.isConnected) {
                                    _sendMessage(await _getFunctionString(1));
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
                                  if (globals.isConnected) {
                                    _sendMessage(await _getFunctionString(2));
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
                                    onPressed: () {
                                      if (globals.isConnected) {
                                        _sendMessage(globals.strForward);
                                        _arena.robot.moveForward();
                                      }
                                      if (globals.debugMode &&
                                          !globals.isConnected) {
                                        _arena.robot.moveForward();
                                      }
                                      if (!globals.updateMode) {
                                        setState(() {
                                          _arena.setRobotPos();
                                        });
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
                                      if (globals.isConnected) {
                                        _sendMessage(globals.strRotateLeft);
                                        _arena.robot.rotateLeft();
                                      }
                                      if (globals.debugMode &&
                                          !globals.isConnected) {
                                        _arena.robot.rotateLeft();
                                      }

                                      if (!globals.updateMode) {
                                        setState(() {
                                          _arena.setRobotPos();
                                        });
                                      }
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: IconButton(
                                    icon: Icon(Icons.arrow_circle_down),
                                    onPressed: () {
                                      if (globals.isConnected) {
                                        _sendMessage(globals.strReverse);
                                      }
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: IconButton(
                                    tooltip: 'Rotate Right',
                                    icon: Icon(Icons.rotate_right),
                                    onPressed: () {
                                      if (globals.isConnected) {
                                        _sendMessage(globals.strRotateRight);
                                        _arena.robot.rotateRight();
                                      }
                                      if (globals.debugMode &&
                                          !globals.isConnected) {
                                        _arena.robot.rotateRight();
                                      }
                                      if (!globals.updateMode) {
                                        setState(() {
                                          _arena.setRobotPos();
                                        });
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
                          onPressed: () {
                            if (globals.isConnected) {
                              _sendMessage(globals.strStartExplore);
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
                          onPressed: () {
                            if (globals.isConnected) {
                              _sendMessage(globals.strFastestPath);
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
                          onPressed: () {},
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

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    String name = widget.server.name;

    setState(() {
      String sdataString = dataString.trim();
      addConsoleAndScroll('Message Received from [$name]:\n[$sdataString]');
    });
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

  void _sendMessage(String text) async {
    text = text.trim();
    textEditingController.clear();
    setState(() {
      messages.add(_Message(clientID, text));
    });

    if (text.length > 0) {
      try {
        globals.connection.output.add(utf8.encode(text));
        await globals.connection.output.allSent;

        setState(() {
          messages.add(_Message(clientID, text));
          addConsoleAndScroll('Message sent to Bluetooth device:\n[$text]');
          consoleController.scrollTo(
              index: globals.strArr.length,
              duration: Duration(milliseconds: 333));
        });

        // Future.delayed(Duration(milliseconds: 333)).then((_) {
        //
        // });

      } catch (e) {
        // Ignore error, but notify state
        addConsoleAndScroll('Disconnected remotely!');
        addConsoleAndScroll(
            'Message was not sent to Bluetooth device. [$text]');
        globals.isDisconnecting = true;
        globals.isConnected = false;
        if (globals.connection != null) {
          globals.connection.dispose();
          globals.connection = null;
        }
        setState(() {});
      }
    }
  }
}

void addConsoleAndScroll(String message) {
  globals.strArr.add(message);
  consoleController.scrollTo(
      index: globals.strArr.length,
      duration: Duration(milliseconds: 333),
      curve: Curves.easeInOutCubic);
  // consoleController.scrollTo(
  //     index: globals.strArr.length, duration: Duration(milliseconds: 333));
  //consoleController.jumpTo(index: globals.strArr.length);
}
