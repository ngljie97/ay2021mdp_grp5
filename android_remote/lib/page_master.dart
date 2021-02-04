import 'package:flutter/material.dart';

import 'router.dart';

class CustomTheme {
  static MaterialColor themeColor = Colors.blueGrey;
  static Color textColor = Colors.white;
}

class AppMaster extends StatelessWidget {
  final Widget body;

  AppMaster({this.body});

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        iconTheme: IconThemeData(color: CustomTheme.themeColor),
      ),
      body: this.body,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
                margin: EdgeInsets.zero,
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: CustomTheme.themeColor,
                ),
                child: Stack(children: <Widget>[
                  Positioned(
                      bottom: 12.0,
                      left: 16.0,
                      child: Text('Remote Controller Module',
                          style: TextStyle(
                              color: CustomTheme.textColor,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w500))),
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
      ),
    );
  }
}
