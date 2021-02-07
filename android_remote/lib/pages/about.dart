import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Center(child: Text('This is the About page')),
    );
  }
}
