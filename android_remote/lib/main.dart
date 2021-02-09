import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:android_remote/pages/bluetooth_connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'globals.dart' as globals;
import 'router.dart';

final TextEditingController textEditingController = new TextEditingController();
final ScrollController listScrollController = new ScrollController();

void main() {
  runApp(MyApp());
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
    );
  }
}

class MyHomePage extends StatefulWidget {
  final BluetoothDevice server;

  const MyHomePage({this.server});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static final clientID = 0;

  List<_Message> messages = List<_Message>();
  String _messageBuffer = '';

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
    super.initState();
    print("fkgerald");
    print(globals.isConnected);
    if (globals.isConnected) {
      BluetoothConnection.toAddress(widget.server.address).then((_connection) {
        print('Connected to the device');
        globals.connection = _connection;
        setState(() {
          globals.isConnecting = false;
          globals.isDisconnecting = false;
        });

        globals.connection.input.listen(_onDataReceived).onDone(() {
          if (globals.isDisconnecting) {
            print('Disconnecting locally!');
            globals.strArr.add('Disconnecting locally!');
          } else {
            print('Disconnected remotely!');
            globals.strArr.add('Disconnecting remotely!');
          }
          if (this.mounted) {
            setState(() {});
          }
        });
      }).catchError((error) {
        print('Cannot connect, exception occured');
        print(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: _onWillPop,
      child: new Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
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
                leading: Icon(Icons.info_outline),
                title: Text('About'),
                onTap: () {
                  Navigator.popAndPushNamed(context, aboutRoute);
                },
              ),
            ],
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildArena(),
            _buildBottomPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildArena() {
    return new Expanded(
      flex: 7,
      child: Center(
        child: Text(() {
          if (globals.updateMode) {
            return 'This is the home page. Manual update is on.';
          } else {
            return 'This is the home page. Manual update is off.';
          }
        }()),
      ),
    );
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
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                    0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }

  void _sendMessage(String text) async {
    text = text.trim();
    textEditingController.clear();

    if (text.length > 0) {
      try {
        globals.connection.output.add(utf8.encode(text + "fku"));
        await globals.connection.output.allSent;

        setState(() {
          messages.add(_Message(clientID, text));
        });

        Future.delayed(Duration(milliseconds: 333)).then((_) {
          listScrollController.animateTo(
              listScrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 333),
              curve: Curves.easeOut);
        });

        globals.strArr.add('Message sent to Bluetooth device. [$text]');
      } catch (e) {
        // Ignore error, but notify state
        globals.strArr.add('Message was not sent to Bluetooth device. [$text]');
        setState(() {});
      }
    }
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
                            child: new ListView.builder(
                              itemCount: globals.strArr.length,
                              itemBuilder: (BuildContext context, int index) {
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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                      Expanded(
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
                                    onPressed: () {
                                      if (globals.isConnected) {
                                        _sendMessage(globals.strRotateLeft);
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
                                    icon: Icon(Icons.rotate_right),
                                    onPressed: () {
                                      if (globals.isConnected) {
                                        _sendMessage(globals.strRotateRight);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      RaisedButton(
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
                      RaisedButton(
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
                      RaisedButton(
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
                      RaisedButton(
                        onPressed: () {},
                        child: Container(
                          child: const Text(
                            'Set Waypoint',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      RaisedButton(
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

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}
