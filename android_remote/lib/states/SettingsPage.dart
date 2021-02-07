import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class SettingsPage extends StatelessWidget {
  pushToScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MyApp()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () => pushToScreen(context),
      ),
    );
  }
}
