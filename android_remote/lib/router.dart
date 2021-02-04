import 'package:flutter/material.dart';

import 'main.dart';
import 'page_master.dart';
import 'pages/about.dart';
import 'pages/bluetooth_connection.dart';
import 'pages/settings.dart';

const String homeRoute = '/';
const String connectionRoute = '/bluetooth_connection';
const String settingsRoute = '/settings';
const String aboutRoute = '/about';

class CRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case homeRoute:
        return MaterialPageRoute(builder: (_) => AppMaster(body: App()));
      case connectionRoute:
        return MaterialPageRoute(
            builder: (_) => AppMaster(body: ConnectionPage()));
      case settingsRoute:
        return MaterialPageRoute(
            builder: (_) => AppMaster(body: SettingsPage()));
      case aboutRoute:
        return MaterialPageRoute(builder: (_) => AppMaster(body: AboutPage()));
      default:
        return MaterialPageRoute(
            builder: (_) => AppMaster(
                  body: Center(
                      child: Text('No route defined for ${settings.name}')),
                ));
    }
  }
}
