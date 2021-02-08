import 'dart:ui';

import 'package:android_remote/pages/ChatPage.dart';
import 'package:android_remote/pages/bluetooth_connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'globals.dart' as globals;
import 'globals.dart';
import 'router.dart';

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
      home: MyHomePage(title: 'Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
                  child: Stack(children: <Widget>[
                    Positioned(
                        bottom: 12.0,
                        left: 16.0,
                        child: Text('Remote Controller Module',
                            style: TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.w500))),
                  ])),
              ListTile(
                leading: Icon(Icons.bluetooth),
                title: Text('Connect / Disconnect'),
                onTap: () async {
                  //Navigator.popAndPushNamed(context, connectionRoute);
                  selectedDevice = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return ConnectionPage(checkAvailability: false);
                      },
                    ),
                  );

                  if (selectedDevice != null) {
                    print('Connect -> selected ' + selectedDevice.address);
                    startChat(context, selectedDevice);
                  } else {
                    print('Connect -> no device selected');
                  }
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
            () {
              if (globals.controlMode) {
                return _buildDefaultPanel();
              } else {
                return _buildControllerPanel();
              }
            } (),
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

  Widget _buildControllerPanel() {
    return new Expanded(
      flex: 3,
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 6,
            child: null,
          ),
          Expanded(
            flex: 4,
            child: Container(
              padding: EdgeInsets.fromLTRB(7.5, 0, 7.5, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  RaisedButton(
                    onPressed: () {},
                    child: Container(
                      child: const Text(
                        'Function 1',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  RaisedButton(
                    onPressed: () {},
                    child: Container(
                      child: const Text(
                        'Function 2',
                        overflow: TextOverflow.ellipsis,
                      ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultPanel() {
    return new Expanded(
      flex: 3,
      child: Container(
        child: Center(
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
                                  itemBuilder:
                                      (BuildContext context, int index) {
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
              Expanded(
                flex: 4,
                child: Container(
                  padding: EdgeInsets.fromLTRB(7.5, 0, 7.5, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      RaisedButton(
                        onPressed: () {},
                        child: Container(
                          child: const Text(
                            'Start Exploration',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      RaisedButton(
                        onPressed: () {},
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
                          globals.strArr.add('Show controls pressed.');
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
              ),
            ],
          ),
        ),
        color: Colors.white60,
      ),
    );
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

void startChat(BuildContext context, BluetoothDevice server) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) {
        return ChatPage(server: server);
      },
    ),
  );
}
