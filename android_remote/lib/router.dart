import 'package:flutter/material.dart';

import 'main.dart';
import 'pages/about.dart';
import 'pages/bluetooth_connection.dart';
import 'pages/settings.dart';

const String homeRoute = '/';
const String connectionRoute = '/bluetooth_connection';
const String settingsRoute = '/settings';
const String aboutRoute = '/about';

class PageRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case homeRoute:
        return MaterialPageRoute(builder: (_) => MyHomePage());
      case connectionRoute:
        return MaterialPageRoute(builder: (_) => ConnectionPage());
      case settingsRoute:
        return MaterialPageRoute(builder: (_) => SettingsPage());
      case aboutRoute:
        return MaterialPageRoute(builder: (_) => AboutPage());
      default:
        return MaterialPageRoute(builder: (_) => MyHomePage());
    }
  }
}
