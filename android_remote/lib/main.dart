import 'package:flutter/material.dart';

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
        drawer: _mainDrawer(context),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'This is the home page.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _mainDrawer(BuildContext context) {
  return new Drawer(
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
          onTap: () {
            Navigator.popAndPushNamed(context, connectionRoute);
          },
        ),
        Divider(),
        ListTile(
          title: Text('Edit persistent strings'),
        ),
        ListTile(
          leading: Icon(Icons.border_color),
          title: Text('Function 1'),
        ),
        ListTile(
          leading: Icon(Icons.border_color),
          title: Text('Function 2'),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Settings'),
          onTap: () {
            Navigator.popAndPushNamed(context, settingsRoute);
          },
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
  );
}

Future<String> _onWillPop() async {
  return (await showDialog(
        builder: (context) => new AlertDialog(
          title: new Text('Are you sure?'),
          content: new Text('Do you want to exit an App'),
          actions: <Widget>[
            new FlatButton(
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
