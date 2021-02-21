import 'package:android_remote/pages/about.dart';
import 'package:flutter/material.dart';

const String homeRoute = '/';
const String connectionRoute = '/bluetooth_connection';
const String settingsRoute = '/settings';
const String aboutRoute = '/about';

class PageRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case homeRoute:
        //return MaterialPageRoute(builder: (_) => MyHomePage("hello"));
      case aboutRoute:
       return MaterialPageRoute(builder: (_) => AboutPage());
      default:
       // return MaterialPageRoute(builder: (_) => MyHomePage("hello"));
    }
  }
}
