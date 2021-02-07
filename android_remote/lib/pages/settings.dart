import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Center(child: Text('This is the settings page')),
    );
  }
}
