import 'package:flutter/material.dart';

class ConnectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Connection'),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Center(child: Text('This is bluetooth connection page.')),
    );
  }
}
